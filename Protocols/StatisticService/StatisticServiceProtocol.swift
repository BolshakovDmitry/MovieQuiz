
import Foundation

protocol StatisticServiceProtocol {
    
    var delegate: StatisticServiceDelegate? {get set}
    
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    var currentCount: Int { get }
    
    func store(correct count: Int, total questionsQuantity: Int)
    func clearUserDefaults()

}


