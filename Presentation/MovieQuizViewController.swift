import UIKit

class MovieQuizViewController: UIViewController {
    
    @IBOutlet private weak var picture: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServiceProtocol?
   
    private let questionsAmount: Int = 10
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var textForAlert = QuizResultsViewModel(title: "", text: "", buttonText: "", completion:{})
    
    override func viewDidLoad() {
        
    super.viewDidLoad()
        
    let qf = QuestionFactory() // экземпляр фабрики Вопросов
    qf.delegate = self
    self.questionFactory = qf
    
    let ap = AlertPresenter() // экземпляр алерты
    ap.delegate = self
    self.alertPresenter = ap
        
    let ss = StatisticService() // экземпляр класса-обработчика данных для показа алерты
    ss.delegate = self
    self.statisticService = ss
        
    questionFactory?.requestNextQuestion() // запрос вопроса для показа картинки и начала квиза
}
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) { //сравниваем результат ответа с правильным из массива и вызываем метод для отображения результат ответа(в виде цветной рамки вокруг картинки)
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
    
    private func makeButtonsDisable(toggle: Bool) {
        if toggle {
            yesButton.isEnabled = !true
            noButton.isEnabled = !true
        } else {
            yesButton.isEnabled = true
            noButton.isEnabled = true
        }
    }
    
    private func showAnswerResult(isCorrect: Bool) { // окраска картинки в зеленый/красный цвет в зависимости от правильности ответа
        picture.layer.masksToBounds = true
        picture.layer.borderWidth = 8
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
            alertPresenter?.showAlert(with: textForAlert)
        } else { // не конец, показывем след картинку
            currentQuestionIndex += 1
            counterLabel.text = "\(currentQuestionIndex + 1)/10"
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showPicture(question: QuizQuestion?) { // обновляет картинку и убирает цвет рамки
        guard let theQuestion = question else { return }
        picture.image = UIImage(named: theQuestion.image) ?? UIImage()
        picture.layer.borderWidth = 0
    }
}

// MARK: - Реализация протокола фабрики вопросов

extension MovieQuizViewController: QuestionFactoryDelegate{
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
        textForAlert = QuizResultsViewModel(title: "Этот раунд окончен!", text: text, buttonText: "Сыграть ещё раз", completion:
        {
            self.questionFactory?.requestNextQuestion()
            self.currentQuestionIndex = 0 // обнуляем поля для нового квиза
            self.correctAnswers = 0
            self.counterLabel.text = "1/10" }
        )
    }
}
