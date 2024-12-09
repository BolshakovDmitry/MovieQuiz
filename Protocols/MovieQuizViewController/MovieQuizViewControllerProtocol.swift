import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    
    func showPicture(question: QuizStepViewModel)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func highlightImageBorder(isCorrectAnswer: Bool)
    func makeButtonsDisable(toggle: Bool)
    func updateCounterLabel()
    func makeAlert(text: AlertModel)
}
