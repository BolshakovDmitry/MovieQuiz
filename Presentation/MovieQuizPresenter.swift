import Foundation
import UIKit

final class MovieQuizPresenter {
    
    private var viewController: MovieQuizViewControllerProtocol?       // убрал прайваты - еадо вернуть
    private var statisticService: StatisticServiceProtocol?
    private var questionFactory: QuestionFactoryProtocol?
    private var viewModel: QuizStepViewModel?
    private var currentQuestion: QuizQuestion?
    private let questionsAmount: Int = 10
    private var correctAnswers: Int = 0 // make private
    private var currentQuestionIndex: Int = 0
    
    init(viewController: MovieQuizViewControllerProtocol){
        
        self.viewController = viewController
        self.statisticService = StatisticService()
        self.statisticService?.delegate = self
        self.questionFactory = QuestionFactory()
        self.questionFactory?.delegate = self
        questionFactory?.loadData()
        self.viewController?.showLoadingIndicator()
    }
    
    func getCurrentQuestion() -> Int {
        return currentQuestionIndex
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    private func increaseCorrectAnswearCount() {
        correctAnswers += 1
    }
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 2
    }
    
    private func resetCorrectAnswers() {
        correctAnswers = 0
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    private func didAnswer(isYes: Bool) {
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        viewController?.showLoadingIndicator()
        
        let givenAnswer = isYes
        
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        
        if (isCorrect) {
            correctAnswers+=1
        }
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            proceedToNextQuestionOrResults()
            viewController?.hideLoadingIndicator()
            viewController?.makeButtonsDisable(toggle: false)
        }
    }
    
    private func proceedToNextQuestionOrResults() {
        
        if isLastQuestion() { // конец квиза - записываем результат в userdefauls, который потом вызывает алерту
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
        }
        else { // не конец, показывем след картинку
            viewController?.showLoadingIndicator()
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        
        return QuizStepViewModel(
            image: model.image,
            question: model.text
        )
    }
}

// MARK: - Реализация протокола фабрики вопросов


extension MovieQuizPresenter: QuestionFactoryDelegate{
    
    func didLoadDataFromServer() {
        
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: String) {
        
        let failToDownloadText = AlertModel(title: error, text: "невозможно загрузить данные", buttonText: "Попробовать еще раз", completion:{
            self.questionFactory?.loadData() // пробуем по новой
            self.currentQuestionIndex = 0 // обнуляем поля для нового квиза
            self.viewController?.updateCounterLabel()
            self.viewController?.hideLoadingIndicator()}
        )
        
        viewController?.makeAlert(text: failToDownloadText) // возьмём в качестве сообщения описание ошибки
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        
        currentQuestion = question
        
        guard let currentQuestion = question else { return }
        
        let viewModel = convert(model: currentQuestion)
        
        viewController?.showPicture(question: viewModel) // отображение картинки из текущего вопроса
    }
}

// MARK: - Реализация протокола статистики (лучшая игра/время/текущий счет)

extension MovieQuizPresenter: StatisticServiceDelegate{
    
    func didReceiveAlertText(text: String)  {
        let textForAlert = AlertModel(title: "Этот раунд окончен!", text: text, buttonText: "Сыграть ещё раз", completion:{
            self.questionFactory?.loadData()
            self.correctAnswers = 0
            self.currentQuestionIndex = 0
            self.viewController?.updateCounterLabel()
        })
        
        viewController?.makeAlert(text: textForAlert)
    }
}























