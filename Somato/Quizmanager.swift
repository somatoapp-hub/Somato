import Combine
import SwiftUI

struct Question: Identifiable {
    let id = UUID()
    let category: String
    let prompt: String
    let answers: [String]
    let correctIndex: Int
    let explanation: String?
}

@MainActor
class QuizManager: ObservableObject {
    @Published var questions: [Question] = []
    @Published var currentQuestionIndex = 0
    @Published var isAnswered = false
    @Published var selectedAnswerIndex: Int? = nil
    @Published var timeRemaining = 30
    var timer: Timer?

    var currentQuestion: Question? {
        questions.isEmpty ? nil : questions[currentQuestionIndex]
    }

    // MARK: - Logik
    func loadQuestions(for category: String) {
        // Hier legst du deinen Fragenpool an (später können wir das aus JSON laden)
        let allQuestions: [Question] = [
            Question(category: "Physiologie",
                     prompt: "Wie hoch ist die normale Körperkerntemperatur?",
                     answers: ["36°C", "37°C", "38°C", "39°C"],
                     correctIndex: 1,
                     explanation: "Die normale Körperkerntemperatur liegt bei etwa 37°C."),
            
            Question(category: "Zellphysiologie",
                     prompt: "Welches Organell ist für die Energieproduktion zuständig?",
                     answers: ["Mitochondrium", "Golgi-Apparat", "Ribosom", "Peroxisom"],
                     correctIndex: 0,
                     explanation: "Das Mitochondrium produziert ATP über die Atmungskette."),
            
            Question(category: "Neurophysiologie",
                     prompt: "Welcher Neurotransmitter ist hauptsächlich im parasympathischen System aktiv?",
                     answers: ["Noradrenalin", "Acetylcholin", "Serotonin", "Dopamin"],
                     correctIndex: 1,
                     explanation: "Im parasympathischen System wirkt Acetylcholin an muskarinischen Rezeptoren."),
            
            Question(category: "Biochemie",
                     prompt: "Welches Molekül ist die primäre Energiequelle der Zelle?",
                     answers: ["Glukose", "ATP", "GTP", "Pyruvat"],
                     correctIndex: 1,
                     explanation: "ATP (Adenosintriphosphat) ist der universelle Energieträger der Zelle.")
        ]

        // Filter nach Kategorie
        questions = allQuestions.filter { $0.category == category }
        currentQuestionIndex = 0
        isAnswered = false
        selectedAnswerIndex = nil
        startTimer()
    }

    func answerQuestion(with index: Int) {
        selectedAnswerIndex = index
        isAnswered = true
        stopTimer()
    }

    func nextQuestion() {
        if currentQuestionIndex + 1 < questions.count {
            currentQuestionIndex += 1
            isAnswered = false
            selectedAnswerIndex = nil
            startTimer()
        } else {
            stopTimer()
            questions = []
        }
    }

    func buttonColor(for index: Int) -> Color {
        guard isAnswered, let current = currentQuestion else { return .blue }
        if index == current.correctIndex { return .green }
        if index == selectedAnswerIndex { return .red }
        return .blue
    }

    // MARK: - Timer
    func startTimer() {
        timeRemaining = 30
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.isAnswered = true
                self.stopTimer()
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

