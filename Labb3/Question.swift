import Foundation


struct APIResponse: Codable {
    let responseCode: Int
    let results: [Question]

    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case results
    }
}

struct Question: Codable, Identifiable {
    let id = UUID()
    let category: String
    let difficulty: String
    let questionText: String
    let correctAnswer: String
    let incorrectAnswers: [String]

    enum CodingKeys: String, CodingKey {
        case category
        case difficulty
        case questionText = "question"
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }

   
    var allAnswers: [String] {
        var answers = incorrectAnswers
        answers.append(correctAnswer)
        return answers.shuffled()
    }
}


struct QuizResult: Identifiable {
    let id = UUID()
    let score: Int
    let total: Int
    let date: Date

    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
