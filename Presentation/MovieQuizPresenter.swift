import Foundation

final class MovieQuizPresenter {
    
     var viewController: MovieQuizViewController?       // убрал прайваты - еадо вернуть
     var statisticService: StatisticServiceProtocol?
     var questionFactory: QuestionFactoryProtocol?
    
    init(viewController: MovieQuizViewController){
        
        self.viewController = viewController
        
        self.statisticService = StatisticService()
        self.statisticService?.delegate = self
        
        self.questionFactory = QuestionFactory()
        self.questionFactory?.delegate = self
        
        questionFactory?.loadData()
        self.viewController?.showLoadingIndicator()
        
    }
      
    var currentQuestion: QuizQuestion?
    let questionsAmount: Int = 10
    var correctAnswers: Int = 0 // make private
    private var currentQuestionIndex: Int = 0
    
    
    func increaseCorrectAnswearCount() {
        correctAnswers += 1
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func resetCorrectAnswers() {
        correctAnswers = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
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
    
    private func didAnswer(isYes: Bool) {
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    
    func showNextQuestionOrResults() {
        print(currentQuestionIndex)
        if isLastQuestion() { // конец квиза и логика для отображения алерты с результатми
            print("in the end")
            viewController?.statisticService?.store(correct: correctAnswers, total: questionsAmount) // statisticService?.store(correct: correctAnswers, total: questionsAmount) не работает
        }
        else { // не конец, показывем след картинку
            print("in the presenter showNextQuestionOrResults ")
            switchToNextQuestion()
            viewController?.showLoadingIndicator()
            viewController?.questionFactory?.requestNextQuestion()
        }
    }
    
    
    
    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.showPicture(question: self?.currentQuestion)
        }
    }
    
}
    
    // MARK: - Реализация протокола фабрики вопросов


    extension MovieQuizPresenter: QuestionFactoryDelegate{
        
        func didLoadDataFromServer() {
            viewController?.hideLoadingIndicator()
            questionFactory?.requestNextQuestion()
        }
        
        func didFailToLoadData(with error: String) {
            viewController?.showNetworkError(message: error) // возьмём в качестве сообщения описание ошибки
        }
        
        func didReceiveNextQuestion(question: QuizQuestion?) {
            currentQuestion = question
            
    //        // получение вопроса из фабрики вопросов
    //        // проверка, что вопрос не nil
    //        guard let question = question else { return }
    //        currentQuestion = question
    //        showPicture(question: currentQuestion) // отображение картинки из текущего вопроса
            viewController?.hideLoadingIndicator()
        }
    }

// MARK: - Реализация протокола статистики (лучшая игра/время/текущий счет)

extension MovieQuizPresenter: StatisticServiceDelegate{
    
    func didReceiveAlertText(text: String)  {
        let textForAlert = AlertModel(title: "Этот раунд окончен!", text: text, buttonText: "Сыграть ещё раз", completion:{
            self.questionFactory?.loadData()
            self.correctAnswers = 0
            self.currentQuestionIndex = 0
        })
        
        AlertPresenter.showAlert(with: textForAlert, delegate: self.viewController)
    }
}



    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    