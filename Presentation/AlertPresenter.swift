
import UIKit

final class AlertPresenter: AlertPresenterProtocol {
    
    weak var delegate: AlertPresenterDelegate?
    
    static func showAlert(with resultViewModel: QuizResultsViewModel, delegate: AlertPresenterDelegate?){
        let alert = UIAlertController(
            title: resultViewModel.title,
            message: resultViewModel.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: resultViewModel.buttonText, style: .default) { _ in
            resultViewModel.completion()
        }
        
        alert.addAction(action)
        
        delegate?.presentAlert(alert: alert)
    }
}
