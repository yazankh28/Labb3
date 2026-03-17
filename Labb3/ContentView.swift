import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = QuizViewModel()

    var body: some View {
        Group {
            switch viewModel.state {

            case .start:
                StartView(viewModel: viewModel)

            case .loading:
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Hämtar frågor...")
                        .foregroundColor(.secondary)
                }

            case .playing:
                QuizView(viewModel: viewModel)

            case .result:
                ResultView(viewModel: viewModel)

            case .error(let message):
                VStack(spacing: 20) {
                    Text("❌")
                        .font(.system(size: 60))
                    Text("Något gick fel")
                        .font(.title2)
                        .bold()
                    Text(message)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button("Försök igen") {
                        viewModel.restart()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
}
