
import Foundation

struct AlertModel {
    var title: String
    var text: String
    var buttonText: String
    var completion: (() -> Void)
}
