
import Foundation

final class MovieQuizPresenter {
    
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func getCurrentQuestion() -> Int {
        return currentQuestionIndex
    }
    
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    
    func yesButtonClicked() { // сравниваем результат ответа с правильным и вызываем метод для отображения результат ответа(в виде цветной рамки вокруг картинки)
        
        //makeButtonsDisable(toggle: true) // блок клавиш на время показа рамки рехультата (1 сек)
        guard let theCurrentQuestion = currentQuestion else { return }
        let givenAnswer = true
        viewController?.showAnswerResult(isCorrect: givenAnswer == theCurrentQuestion.correctAnswer)
    }
    
    func noButtonClicked() {
        
        //makeButtonsDisable(toggle: true)
        guard let theCurrentQuestion = currentQuestion else { return }
        let givenAnswer = false
        viewController?.showAnswerResult(isCorrect: givenAnswer == theCurrentQuestion.correctAnswer)
    }
    
}
