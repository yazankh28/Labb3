import SwiftUI

struct ResultView: View {
    @ObservedObject var viewModel: QuizViewModel

    var body: some View {
        VStack(spacing: 30) {

            Spacer()

            Text(resultEmoji)
                .font(.system(size: 80))

            Text("Quiz klart!")
                .font(.largeTitle)
                .bold()

            Text("\(viewModel.score) av \(viewModel.questions.count) rätt")
                .font(.title2)

            Text(resultMessage)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: {
                viewModel.restart()
            }) {
                Text("Spela igen")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)

            Spacer()
        }
    }

    var resultEmoji: String {
        let ratio = Double(viewModel.score) / Double(viewModel.questions.count)
        if ratio >= 0.8 { return "🏆" }
        if ratio >= 0.5 { return "👍" }
        return "📚"
    }

    var resultMessage: String {
        let ratio = Double(viewModel.score) / Double(viewModel.questions.count)
        if ratio >= 0.8 { return "Fantastiskt bra jobbat!" }
        if ratio >= 0.5 { return "Bra försök, fortsätt öva!" }
        return "Öva lite mer och försök igen!"
    }
}
