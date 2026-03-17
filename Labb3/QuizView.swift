import SwiftUI

struct QuizView: View {
    @ObservedObject var viewModel: QuizViewModel

    var body: some View {
        VStack(spacing: 20) {

            
            HStack {
                Text("Fråga \(viewModel.currentIndex + 1)/\(viewModel.questions.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

             
                Text("⏱ \(viewModel.timeLeft)s")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(viewModel.timeLeft <= 5 ? .red : .primary)
            }
            .padding(.horizontal)

        
            ProgressView(value: viewModel.progress)
                .padding(.horizontal)

            Spacer()

            if let question = viewModel.currentQuestion {

                
                VStack(spacing: 4) {
                    Text(question.category)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(question.difficulty.capitalized)
                        .font(.caption)
                        .foregroundColor(difficultyColor(question.difficulty))
                }


                Text(question.questionText)
                    .font(.title3)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()

             
                VStack(spacing: 12) {
                    ForEach(question.allAnswers, id: \.self) { answer in
                        AnswerButton(
                            answer: answer,
                            selected: viewModel.selectedAnswer,
                            correct: question.correctAnswer
                        ) {
                            viewModel.selectAnswer(answer)
                        }
                    }
                }
                .padding(.horizontal)
            }

            Spacer()
        }
        .padding(.top)
    }

    func difficultyColor(_ difficulty: String) -> Color {
        switch difficulty {
        case "easy": return .green
        case "medium": return .orange
        case "hard": return .red
        default: return .secondary
        }
    }
}


struct AnswerButton: View {
    let answer: String
    let selected: String?
    let correct: String
    let action: () -> Void

    var backgroundColor: Color {
        guard let selected = selected else {
            return Color(.systemGray6)
        }
        if answer == correct {
            return .green
        }
        if answer == selected {
            return .red
        }
        return Color(.systemGray6)
    }

    var body: some View {
        Button(action: action) {
            Text(answer)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding()
                .background(backgroundColor)
                .cornerRadius(10)
        }
        .disabled(selected != nil)
        .animation(.easeInOut(duration: 0.3), value: selected)
    }
}
