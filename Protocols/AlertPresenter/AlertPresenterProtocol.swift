
import Foundation

protocol AlertPresenterProtocol {
    static func showAlert(with resultViewModel: AlertModel, delegate: AlertPresenterDelegate?)
}
