import UIKit

class MovieQuizViewController: UIViewController {
    
    struct QuizQuestion {
        let image: String
        let rating: Double
        let correctAnswer: Bool
    }
    
    var bestResultModelArray: [bestResultModel] = []
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var gamesPlayed = 0
    private var record = 0
    
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
 
    override func viewDidLoad() {
        super.viewDidLoad()
        showPicture()
    }
    
    @IBOutlet private weak var picture: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!

    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        let currentQuestion = questions[currentQuestionIndex] // 1
        let givenAnswer = true // 2
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        let currentQuestion = questions[currentQuestionIndex] // 1
        let givenAnswer = false // 2
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        picture.layer.masksToBounds = true
        picture.layer.borderWidth = 8
        picture.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        if isCorrect { // 1
            correctAnswers += 1 // 2
        }
        showNextQuestionOrResults()
        
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 { // 1
            gamesPlayed += 1
            if correctAnswers > record {
                record = correctAnswers
            }
            let date = Date()
            let percentage = Double(correctAnswers) / Double(questions.count) * 100
            print(percentage)
            let resultModel = bestResultModel(record: record,
                                              timeWhenFinished: date)
            let text = "Ваш результат: \(correctAnswers)/10 \n Количество сыгранных квизов: \(gamesPlayed) \n Рекорд: \(calculateBestResult(resultModel: resultModel)) \n Средняя точность: \(percentage.formatWithTwoDecimalPlaces())%"
            let viewModel = QuizResultsViewModel( // 2
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            showResults(quiz: viewModel)
        } else { // 2
            counterLabel.text = "\(currentQuestionIndex + 2)/10"
            currentQuestionIndex += 1
            showPicture()
        }
        
    }
    
    private func showResults(quiz result: QuizResultsViewModel) {
        
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.showPicture()
            self.counterLabel.text = "1/10"
            
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    struct QuizResultsViewModel {
        let title: String
        let text: String
        let buttonText: String
    }
    
    private func showPicture() {
        picture.image = UIImage(named: questions[currentQuestionIndex].image) ?? UIImage()
        
    }
    
    struct bestResultModel{
        let record: Int
        let timeWhenFinished: Date
    }
    
    private func calculateBestResult(resultModel: bestResultModel) -> String {
        if bestResultModelArray.isEmpty == true {
            bestResultModelArray.append(resultModel)
            return "\(resultModel.record): \(resultModel.timeWhenFinished.dateTimeString)"
        }
        if resultModel.record > bestResultModelArray[0].record {
            return "\(resultModel.record): \(resultModel.timeWhenFinished.dateTimeString)"
        } else { return "\(bestResultModelArray[0].record): \(bestResultModelArray[0].timeWhenFinished.dateTimeString)"
        }
    }
    
}
