import SwiftUI
import Combine

struct TriviaQuestion: Codable {
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
    
    var allAnswers: [String] {
        (incorrect_answers + [correct_answer]).shuffled()
    }
}

struct TriviaResponse: Codable {
    let results: [TriviaQuestion]
}

class QuizViewModel: ObservableObject {
    @Published var questions: [TriviaQuestion] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var currentIndex = 0
    @Published var score = 0
    @Published var selectedAnswer: String? = nil
    @Published var quizFinished = false
    @Published var quizStarted = false
    
    var currentQuestion: TriviaQuestion? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }
    
    var progress: Double {
        guard questions.count > 0 else { return 0 }
        return Double(currentIndex + 1) / Double(questions.count)
    }
    
    func fetchQuestions() {
        isLoading = true
        errorMessage = nil
        
        let url = URL(string: "https://opentdb.com/api.php?amount=10&type=multiple")!
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                guard let data = data else { return }
                if let decoded = try? JSONDecoder().decode(TriviaResponse.self, from: data) {
                    self.questions = decoded.results
                }
            }
        }.resume()
    }
    
    func selectAnswer(_ answer: String) {
        selectedAnswer = answer
        if answer == currentQuestion?.correct_answer {
            score += 1
        }
    }
    
    func nextQuestion() {
        if currentIndex + 1 < questions.count {
            currentIndex += 1
            selectedAnswer = nil
        } else {
            quizFinished = true
        }
    }
    
    func restart() {
        currentIndex = 0
        score = 0
        selectedAnswer = nil
        quizFinished = false
        quizStarted = false
    }
}

struct ContentView: View {
    @StateObject var viewModel = QuizViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            if !viewModel.quizStarted {
                Spacer()
                Text("🧠")
                    .font(.system(size: 100))
                Text("Pop Quiz")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Testa dina kunskaper!")
                    .foregroundColor(.gray)
                Spacer()
                Button("Starta Quiz") {
                    viewModel.quizStarted = true
                    viewModel.fetchQuestions()
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.purple)
                .cornerRadius(12)
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            } else if viewModel.isLoading {
                ProgressView("Laddar frågor...")
            } else if let error = viewModel.errorMessage {
                VStack(spacing: 16) {
                    Text("Något gick fel")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(error)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    Button("Försök igen") {
                        viewModel.fetchQuestions()
                    }
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
            } else if viewModel.quizFinished {
                VStack(spacing: 24) {
                    Text(viewModel.score >= 7 ? "🏆" : viewModel.score >= 4 ? "🎉" : "😅")
                        .font(.system(size: 80))
                    Text("Quiz klart!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Du fick \(viewModel.score) av \(viewModel.questions.count) rätt")
                        .font(.title3)
                        .foregroundColor(.gray)
                    HStack(spacing: 20) {
                        Label("\(viewModel.score) rätt", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Label("\(viewModel.questions.count - viewModel.score) fel", systemImage: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    Button("Spela igen") {
                        viewModel.restart()
                    }
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
            } else if let question = viewModel.currentQuestion {
                VStack(spacing: 20) {
                    Text("Fråga \(viewModel.currentIndex + 1) av \(viewModel.questions.count)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    ProgressView(value: viewModel.progress)
                        .accentColor(.purple)
                        .padding(.horizontal)
                    Text(question.question)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding()
                    ForEach(question.allAnswers, id: \.self) { answer in
                        Button(action: {
                            if viewModel.selectedAnswer == nil {
                                viewModel.selectAnswer(answer)
                            }
                        }) {
                            HStack {
                                Text(answer)
                                Spacer()
                                if let selected = viewModel.selectedAnswer {
                                    if answer == question.correct_answer {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    } else if answer == selected {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(answerColor(answer: answer, question: question))
                            .cornerRadius(10)
                        }
                        .foregroundColor(.primary)
                        .disabled(viewModel.selectedAnswer != nil)
                    }
                    .padding(.horizontal)
                    if viewModel.selectedAnswer != nil {
                        Button(viewModel.currentIndex + 1 == viewModel.questions.count ? "Se resultat" : "Nästa fråga") {
                            viewModel.nextQuestion()
                        }
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
    }
    
    func answerColor(answer: String, question: TriviaQuestion) -> Color {
        guard let selected = viewModel.selectedAnswer else {
            return Color(.systemGray6)
        }
        if answer == question.correct_answer {
            return Color.green.opacity(0.2)
        } else if answer == selected {
            return Color.red.opacity(0.2)
        }
        return Color(.systemGray6)
    }
}
