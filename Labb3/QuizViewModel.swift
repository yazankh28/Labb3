import Foundation
import SwiftUI
import Combine


enum QuizState {
    case start
    case loading
    case playing
    case result
    case error(String)
}

@MainActor
class QuizViewModel: ObservableObject {

    @Published var state: QuizState = .start
    @Published var questions: [Question] = []
    @Published var currentIndex: Int = 0
    @Published var score: Int = 0
    @Published var selectedAnswer: String? = nil
    @Published var previousResults: [QuizResult] = []

   
    @Published var timeLeft: Int = 15
    private var timer: Timer?

    var currentQuestion: Question? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentIndex) / Double(questions.count)
    }

    
    func fetchQuestions() async {
        state = .loading

        let urlString = "https://opentdb.com/api.php?amount=10&type=multiple&encode=url3986"

        guard let url = URL(string: urlString) else {
            state = .error("Ogiltig URL")
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(APIResponse.self, from: data)

           
            questions = decoded.results.map { q in
                Question(
                    category: q.category.removingPercentEncoding ?? q.category,
                    difficulty: q.difficulty.removingPercentEncoding ?? q.difficulty,
                    questionText: q.questionText.removingPercentEncoding ?? q.questionText,
                    correctAnswer: q.correctAnswer.removingPercentEncoding ?? q.correctAnswer,
                    incorrectAnswers: q.incorrectAnswers.map {
                        $0.removingPercentEncoding ?? $0
                    }
                )
            }

            currentIndex = 0
            score = 0
            selectedAnswer = nil
            state = .playing
            startTimer()

        } catch {
            state = .error("Kunde inte hämta frågor: \(error.localizedDescription)")
        }
    }

    
    func selectAnswer(_ answer: String) {
        guard selectedAnswer == nil else { return }
        selectedAnswer = answer

        if answer == currentQuestion?.correctAnswer {
            score += 1
        }

        
        timer?.invalidate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.nextQuestion()
        }
    }

    func nextQuestion() {
        selectedAnswer = nil
        if currentIndex + 1 < questions.count {
            currentIndex += 1
            timeLeft = 15
            startTimer()
        } else {
            timer?.invalidate()
            saveResult()
            state = .result
        }
    }

    func startTimer() {
        timer?.invalidate()
        timeLeft = 15
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if self.timeLeft > 0 {
                    self.timeLeft -= 1
                } else {
                    self.timer?.invalidate()
                    self.nextQuestion()
                }
            }
        }
    }
    func saveResult() {
        let result = QuizResult(score: score, total: questions.count, date: Date())
        previousResults.insert(result, at: 0)
        // Spara max 5 resultat
        if previousResults.count > 5 {
            previousResults = Array(previousResults.prefix(5))
        }
    }

    func restart() {
        timer?.invalidate()
        state = .start
    }
}
