import SwiftUI

struct QuizView: View {
    var category: String
    @StateObject private var manager = QuizManager()

    var body: some View {
        VStack(spacing: 20) {
            if let question = manager.currentQuestion {
                Text("\(category) – Frage \(manager.currentQuestionIndex + 1)")
                    .font(.headline)
                    .padding(.top, 20)

                Text(question.prompt)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .padding()

                ForEach(0..<question.answers.count, id: \.self) { i in
                    Button(action: {
                        manager.answerQuestion(with: i)
                    }) {
                        Text(question.answers[i])
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(manager.buttonColor(for: i))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                    .disabled(manager.isAnswered)
                }

                if manager.isAnswered {
                    Text(question.explanation ?? "")
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding()

                    Button("Nächste Frage") {
                        manager.nextQuestion()
                    }
                    .padding()
                }

                Spacer()

                Text("⏱ \(manager.timeRemaining)s")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)
            } else {
                Text("Quiz beendet! 🎉")
                    .font(.title2)
                    .padding()
            }
        }
        .onAppear {
            manager.loadQuestions(for: category)
        }
    }
}

