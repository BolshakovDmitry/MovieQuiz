
import Foundation

protocol AlertPresenterProtocol {
    static func showAlert(with resultViewModel: QuizResultsViewModel, delegate: AlertPresenterDelegate?)
}
