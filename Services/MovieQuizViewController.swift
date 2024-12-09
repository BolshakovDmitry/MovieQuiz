import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
  
    @IBOutlet private weak var picture: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var textLabel: UILabel!
    
    private var presenter: MovieQuizPresenter?
   
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let presenterScope = MovieQuizPresenter(viewController: self)
        self.presenter = presenterScope
        
        picture.layer.masksToBounds = true // рамки картинки
        picture.layer.borderWidth = 8
        activityIndicator.color = UIColor(white: 1.0, alpha: 1.0) // цвет и размер индикатора
        activityIndicator.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
        activityIndicator.hidesWhenStopped = true
        
        showLoadingIndicator()
    }
    
    
    func makeAlert(text: AlertModel){
        AlertPresenter.showAlert(with: text, delegate: self)
    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating() // выключаем анимацию
    }
    
    func makeButtonsDisable(toggle: Bool) { // блок кнопок
        
        if toggle {
            yesButton.isEnabled = !true
            noButton.isEnabled = !true
        } else {
            yesButton.isEnabled = true
            noButton.isEnabled = true
        }
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) { // окраска картинки в зеленый/красный цвет в зависимости от правильности ответа
        
        picture.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        textLabel.text = "загрузка..."
        guard let test = presenter?.getCurrentQuestion() else { return }
        counterLabel.text = "\(test + 2)/10"
    }

    func showPicture(question: QuizStepViewModel) { // обновляет картинку и убирает цвет рамки
         
        picture.image = UIImage(data: question.image) ?? UIImage()
        picture.layer.borderColor = UIColor.ypBackground.cgColor
        textLabel.text = question.question
    }
    
    func updateCounterLabel(){
        counterLabel.text = "1/10"
    }

    @IBAction func yesButtonClicked(_ sender: UIButton) {
        makeButtonsDisable(toggle: true) // блок клавиш на время показа рамки рехультата (1 сек
        presenter?.yesButtonClicked()
    }
    
    @IBAction func noButtonClicked(_ sender: UIButton) {
        makeButtonsDisable(toggle: true)
        presenter?.noButtonClicked()
    }
    


}

