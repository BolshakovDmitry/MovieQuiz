
import Foundation

protocol StatisticServiceDelegate: AnyObject {               // 1
    func didReceiveAlerttext(text: String)   // 2
}
