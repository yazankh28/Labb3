import SwiftUI

struct StartView: View {
    @ObservedObject var viewModel: QuizViewModel

    var body: some View {
        VStack(spacing: 30) {

            Spacer()

            Text("🎯")
                .font(.system(size: 80))

            Text("Pop Quiz")
                .font(.largeTitle)
                .bold()

            Text("10 frågor • 15 sekunder per fråga")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Button(action: {
                Task {
                    await viewModel.fetchQuestions()
                }
            }) {
                Text("Starta quiz")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)

           
            if !viewModel.previousResults.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tidigare resultat")
                        .font(.headline)
                        .padding(.horizontal)

                    ForEach(viewModel.previousResults) { result in
                        HStack {
                            Text(result.dateString)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(result.score)/\(result.total)")
                                .font(.subheadline)
                                .bold()
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
            }

            Spacer()
        }
    }
}
