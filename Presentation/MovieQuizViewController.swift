import UIKit

final class MovieQuizViewController: UIViewController {
    
    @IBOutlet private weak var picture: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticServiceProtocol?
    
    private let questionsAmount: Int = 10
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var textForAlert = Alertmodel(title: "", text: "", buttonText: "", completion:{})
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        picture.layer.masksToBounds = true // рамки картинки
        picture.layer.borderWidth = 8
        activityIndicator.color = UIColor(white: 1.0, alpha: 1.0) // цвет и размер индикатора
        activityIndicator.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
        
        let qf = QuestionFactory() // экземпляр фабрики Вопросов
        qf.delegate = self
        self.questionFactory = qf
        
        let ss = StatisticService() // экземпляр класса-обработчика данных для показа алерты
        ss.delegate = self
        self.statisticService = ss
        
        showLoadingIndicator()
        questionFactory?.loadData() // запрос вопроса для показа картинки и начала квиза
    }
    
    private func showLoadingIndicator() {
        
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    private func hideLoadingIndicator() {
        
        activityIndicator.isHidden = true // скрываем индикатор загрузки
        activityIndicator.stopAnimating() // выключаем анимацию
    }
    
    private func showNetworkError(message: String) {
        
        hideLoadingIndicator()
        
        let failToDownloadText = Alertmodel(title: "что-то пошло не так(", text: "невозможно загрузить данные", buttonText: "Попробовать еще раз", completion:{
        self.questionFactory?.loadData() // пробуем по новой
        self.currentQuestionIndex = 0 // обнуляем поля для нового квиза
        self.correctAnswers = 0
        self.counterLabel.text = "1/10" }
        )
    
        AlertPresenter.showAlert(with: failToDownloadText, delegate: self) // вызываем алерту с ошибкой
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) { // сравниваем результат ответа с правильным и вызываем метод для отображения результат ответа(в виде цветной рамки вокруг картинки)
        makeButtonsDisable(toggle: true) // блок клавиш на время показа рамки рехультата (1 сек)
        guard let theCurrentQuestion = currentQuestion else { return }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == theCurrentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        
        makeButtonsDisable(toggle: true)
        guard let theCurrentQuestion = currentQuestion else { return }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == theCurrentQuestion.correctAnswer)
    }
    
    private func makeButtonsDisable(toggle: Bool) { // блок кнопок
        
        if toggle {
            yesButton.isEnabled = !true
            noButton.isEnabled = !true
        } else {
            yesButton.isEnabled = true
            noButton.isEnabled = true
        }
    }
    
    private func showAnswerResult(isCorrect: Bool) { // окраска картинки в зеленый/красный цвет в зависимости от правильности ответа
        
        picture.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        if isCorrect {
            correctAnswers += 1 // если ответ корректный инкрементируем correctAnswers
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults() // показ либо след вопроса либо алерты и данными
            self.makeButtonsDisable(toggle: false)
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 { // конец квиза и логика для отображения алерты с результатми
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
            AlertPresenter.showAlert(with: textForAlert, delegate: self)
        } else { // не конец, показывем след картинку
            currentQuestionIndex += 1
            counterLabel.text = "\(currentQuestionIndex + 1)/10"
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showPicture(question: QuizQuestion?) { // обновляет картинку и убирает цвет рамки
        guard let theQuestion = question else { return }
        picture.image = UIImage(data: theQuestion.image) ?? UIImage()
        picture.layer.borderColor = UIColor.ypBackground.cgColor
    }
}

// MARK: - Реализация протокола фабрики вопросов

extension MovieQuizViewController: QuestionFactoryDelegate{
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) { // получение вопроса из фабрики вопросов
        // проверка, что вопрос не nil
        guard let question = question else { return }
        currentQuestion = question
        showPicture(question: currentQuestion) // отображение картинки из текущего вопроса
    }
}

// MARK: - Реализация протокола алерты

extension MovieQuizViewController: AlertPresenterDelegate{
    
    func presentAlert(alert: UIAlertController) {
        self.present(alert, animated: true, completion: {})
    }
}

// MARK: - Реализация протокола данных для алерты(лучшая игра/время/текущий счет)

extension MovieQuizViewController: StatisticServiceDelegate{
    
    func didReceiveAlerttext(text: String)  {
        textForAlert = Alertmodel(title: "Этот раунд окончен!", text: text, buttonText: "Сыграть ещё раз", completion:{
        self.questionFactory?.requestNextQuestion()
        self.currentQuestionIndex = 0 // обнуляем поля для нового квиза
        self.correctAnswers = 0
        self.counterLabel.text = "1/10" }
        )
    }
}
