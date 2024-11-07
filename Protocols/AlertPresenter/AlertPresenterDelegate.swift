
import UIKit

protocol AlertPresenterDelegate: AnyObject {               // 1
    func presentAlert(alert: UIAlertController)    // 2
}
