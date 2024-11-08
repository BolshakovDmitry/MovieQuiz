
import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    
    weak var delegate: QuestionFactoryDelegate?
    
    private let questions: [QuizQuestion] = [
       QuizQuestion(
           image: "The Godfather",
           rating: 9.2,
           correctAnswer: true),
       QuizQuestion(
           image: "The Dark Knight",
           rating: 9,
           correctAnswer: true),
       QuizQuestion(
           image: "Kill Bill",
           rating: 8.1,
           correctAnswer: true),
       QuizQuestion(
           image: "The Avengers",
           rating: 8,
           correctAnswer: true),
       QuizQuestion(
           image: "Deadpool",
           rating: 8,
           correctAnswer: true),
       QuizQuestion(
           image: "The Green Knight",
           rating: 6.6,
           correctAnswer: true),
       QuizQuestion(
           image: "Old",
           rating: 5.8,
           correctAnswer: false),
       QuizQuestion(
           image: "The Ice Age Adventures of Buck Wild",
           rating: 4.3,
           correctAnswer: false),
       QuizQuestion(
           image: "Tesla",
           rating: 5.1,
           correctAnswer: false),
       QuizQuestion(
           image: "Vivarium",
           rating: 5.8,
           correctAnswer: false)
    ]
    
    func requestNextQuestion() {
        guard let index = (0..<questions.count).randomElement() else {
            delegate?.didReceiveNextQuestion(question: nil)
            return
        }

        let question = questions[safe: index]
        delegate?.didReceiveNextQuestion(question: question)
    }
}
