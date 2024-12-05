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
        currentQuestionIndex == questionsAmount - 2
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
        
        viewController?.showLoadingIndicator()
        
        let givenAnswer = isYes
        
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
       
        if(isCorrect){
            correctAnswers+=1
        }

        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
    
    
    
    
    func proceedToNextQuestionOrResults() {
        print(currentQuestionIndex)
        if isLastQuestion() { // конец квиза и логика для отображения алерты с результатми
            print("in the end")
            statisticService?.store(correct: correctAnswers, total: questionsAmount) // statisticService?.store(correct: correctAnswers, total: questionsAmount) не работает
        }
        else { // не конец, показывем след картинку
            print("in the presenter showNextQuestionOrResults ")
            viewController?.showLoadingIndicator()
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
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
            
            let failToDownloadText = AlertModel(title: error, text: "невозможно загрузить данные", buttonText: "Попробовать еще раз", completion:{
                self.questionFactory?.loadData() // пробуем по новой
                self.resetQuestionIndex() // обнуляем поля для нового квиза
                self.viewController?.updateCounterLabel()
                self.viewController?.hideLoadingIndicator()}
            )
            
            AlertPresenter.showAlert(with: failToDownloadText, delegate: self.viewController) // возьмём в качестве сообщения описание ошибки
        }
        
        func didReceiveNextQuestion(question: QuizQuestion?) {
            currentQuestion = question
            
    //        // получение вопроса из фабрики вопросов
    //        // проверка, что вопрос не nil
    //        guard let question = question else { return }
    //        currentQuestion = question
            viewController?.showPicture(question: currentQuestion) // отображение картинки из текущего вопроса
            
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
        
        AlertPresenter.showAlert(with: textForAlert, delegate: self.viewController)
    }
}



    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
