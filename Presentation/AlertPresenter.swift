import UIKit

final class AlertPresenter {
    
    static func showAlert(with resultViewModel: AlertModel, delegate: UIViewController?){
        
        let alert = UIAlertController(
            title: resultViewModel.title,
            message: resultViewModel.text,
            preferredStyle: .alert)
        
        alert.view.accessibilityIdentifier = "Game results"
        
        let action = UIAlertAction(title: resultViewModel.buttonText, style: .default) { _ in
            resultViewModel.completion()
        }
        
        alert.addAction(action)
        
        delegate?.present(alert, animated: true, completion: {})
    }
}
