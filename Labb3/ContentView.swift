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
}

struct ContentView: View {
    @StateObject var viewModel = QuizViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            if viewModel.isLoading {
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
            } else {
                Text("Pop Quiz")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("\(viewModel.questions.count) frågor hämtade")
                    .foregroundColor(.gray)
            }
        }
        .onAppear {
            viewModel.fetchQuestions()
        }
    }
}
