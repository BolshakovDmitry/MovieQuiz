import UIKit

final class MovieQuizViewController: UIViewController {
    
    @IBOutlet private weak var picture: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var textLabel: UILabel!
    
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticServiceProtocol?
    private let presenter = MovieQuizPresenter()
    
    private var correctAnswers = 0
    private var textForAlert = AlertModel(title: "", text: "", buttonText: "", completion:{})
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        presenter.viewController = self
        
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
        
        activityIndicator.hidesWhenStopped = true
    }
    
    private func showLoadingIndicator() {
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating() // выключаем анимацию
    }
    
    private func showNetworkError(message: String) {
        
        hideLoadingIndicator()
        
        let failToDownloadText = AlertModel(title: message, text: "невозможно загрузить данные", buttonText: "Попробовать еще раз", completion:{
            self.questionFactory?.loadData() // пробуем по новой
            self.presenter.resetQuestionIndex() // обнуляем поля для нового квиза
            self.correctAnswers = 0
            self.counterLabel.text = "1/10" }
        )
        
        AlertPresenter.showAlert(with: failToDownloadText, delegate: self) // вызываем алерту с ошибкой
    }
    
    @IBAction func yesButtonClicked(_ sender: UIButton) { // сравниваем результат ответа с правильным и вызываем метод для отображения результат ответа(в виде цветной рамки вокруг картинки)
        
        makeButtonsDisable(toggle: true) // блок клавиш на время показа рамки рехультата (1 сек)
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonClicked()
    }
    
    @IBAction func noButtonClicked(_ sender: UIButton) {
        
        makeButtonsDisable(toggle: true)
        presenter.currentQuestion = currentQuestion
        presenter.noButtonClicked()
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
    
    func showAnswerResult(isCorrect: Bool) { // окраска картинки в зеленый/красный цвет в зависимости от правильности ответа
        picture.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        textLabel.text = "загрузка..."
        if isCorrect {
            correctAnswers += 1 // если ответ корректный инкрементируем correctAnswers
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults() // показ либо след вопроса либо алерты и данными
            self.makeButtonsDisable(toggle: false)
        }
    }
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() { // конец квиза и логика для отображения алерты с результатми
            statisticService?.store(correct: correctAnswers, total: presenter.questionsAmount)
            AlertPresenter.showAlert(with: textForAlert, delegate: self)
        } else { // не конец, показывем след картинку
            presenter.switchToNextQuestion()
            counterLabel.text = "\(presenter.getCurrentQuestion() + 1)/10"
            showLoadingIndicator()
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showPicture(question: QuizQuestion?) { // обновляет картинку и убирает цвет рамки
        guard let theQuestion = question else { return }
        picture.image = UIImage(data: theQuestion.image) ?? UIImage()
        picture.layer.borderColor = UIColor.ypBackground.cgColor
        textLabel.text = theQuestion.text
    }
}

// MARK: - Реализация протокола фабрики вопросов


extension MovieQuizViewController: QuestionFactoryDelegate{
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: String) {
        showNetworkError(message: error) // возьмём в качестве сообщения описание ошибки
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) { // получение вопроса из фабрики вопросов
        // проверка, что вопрос не nil
        guard let question = question else { return }
        currentQuestion = question
        showPicture(question: currentQuestion) // отображение картинки из текущего вопроса
        hideLoadingIndicator()
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
    
    func didReceiveAlertText(text: String)  {
        textForAlert = AlertModel(title: "Этот раунд окончен!", text: text, buttonText: "Сыграть ещё раз", completion:{
            self.questionFactory?.requestNextQuestion()
            self.presenter.resetQuestionIndex() // обнуляем поля для нового квиза
            self.correctAnswers = 0
            self.counterLabel.text = "1/10" }
        )
    }
}
