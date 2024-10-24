import UIKit


final class MovieQuizViewController: UIViewController {
    
    @IBOutlet private weak var picture: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var gamesPlayed = 0
    private var record = 0
    private var resultBase = bestResultModel(record: 0, timeWhenFinished: Date())

    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showPicture() // показ первой картинки для старта квиза
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) { //сравниваем результат ответа с правильным из массива и вызываем метод для отображения результат ответа(в виде цветной рамки вокруг картинки)
        yesButton.isEnabled = false // блок клавиши на время показа рамки рехультата (1 сек)
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        noButton.isEnabled = false
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func showAnswerResult(isCorrect: Bool) { // окраска картинки в зеленый/красный цвет в завимиости от правильности ответа
        picture.layer.masksToBounds = true
        picture.layer.borderWidth = 8
        picture.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        if isCorrect {
            correctAnswers += 1 // если ответ корректный инкрементируем correctAnswers
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
            self.yesButton.isEnabled = true
            self.noButton.isEnabled = true
           }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 { // конец квиза и логика для отобрадения алерты с результатми
            gamesPlayed += 1
            let date = Date()
            if gamesPlayed == 1 {
                resultBase.record = correctAnswers
                resultBase.timeWhenFinished = date
                record = correctAnswers
            }
            if correctAnswers > record {
                record = correctAnswers
                resultBase.record = correctAnswers
                resultBase.timeWhenFinished = date
            }
            let winPercentage = Double(correctAnswers) / Double(questions.count) * 100
            let text = "Ваш результат: \(correctAnswers)/10 \n Количество сыгранных квизов: \(gamesPlayed) \n Рекорд: \(resultBase.record)/10 (\(resultBase.timeWhenFinished.dateTimeString)) \n Средняя точность: \(winPercentage.formatWithTwoDecimalPlaces())%"
            let viewModel = QuizResultsViewModel( // 2
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            showResults(quiz: viewModel)
        } else { // показывем след картинку
            currentQuestionIndex += 1
            counterLabel.text = "\(currentQuestionIndex + 1)/10"
            showPicture()
        }
    }
    
    private func showResults(quiz result: QuizResultsViewModel) { // показывает алерту
        
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            self.currentQuestionIndex = 0 // обнуляем поля для нового квиза
            self.correctAnswers = 0
            self.showPicture()
            self.counterLabel.text = "1/10"
            
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showPicture() { // обновляет картинку и убирает цвет рамки
        picture.image = UIImage(named: questions[currentQuestionIndex].image) ?? UIImage()
        picture.layer.borderWidth = 0
        
    }
}
