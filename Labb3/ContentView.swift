import SwiftUI

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

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Pop Quiz")
                .font(.largeTitle)
                .fontWeight(.bold)
        }
    }
}
