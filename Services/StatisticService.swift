
import Foundation

final class StatisticService: StatisticServiceProtocol {
    
    weak var delegate: StatisticServiceDelegate?
    
    private var userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        case currentCount
        case totalAccuracy
        case bestCorrectAnswears
        case totalGamesPlayed
        case totalCorrectAnswears
    }
   
    var currentCount: Int {
        get {
            return userDefaults.integer(forKey: Keys.currentCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.currentCount.rawValue)
        }
    }
    
    var totalCorrectAnswears: Int {
        get {
            return userDefaults.integer(forKey: Keys.totalCorrectAnswears.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.totalCorrectAnswears.rawValue)
        }
    }

    var totalAccuracy: Double {
        get {
            return userDefaults.double(forKey: Keys.totalAccuracy.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.totalAccuracy.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let bestCorrectAnswears = userDefaults.integer(forKey: Keys.bestCorrectAnswears.rawValue)
            let totalGamesPlayed = userDefaults.integer(forKey: Keys.totalGamesPlayed.rawValue)
            let date = userDefaults.object(forKey: "date") as? Date ?? Date()
            
            return GameResult(correctAnswears: bestCorrectAnswears, totalGamesPlayed: totalGamesPlayed, date: date)
        }
        set(newBestGame) {
            userDefaults.set(newBestGame.correctAnswears, forKey: Keys.bestCorrectAnswears.rawValue)
            userDefaults.set(newBestGame.totalGamesPlayed, forKey: Keys.totalGamesPlayed.rawValue)
            userDefaults.set(newBestGame.date, forKey: "date")
        }
    }
        
    func store(correct count: Int, total questionsQuantity: Int) {
        
        print("in the statistic service")
        
        self.totalCorrectAnswears += count
        
        self.currentCount = count
        
        if count >= bestGame.correctAnswears {
            
            print("in the store")
            
            bestGame.correctAnswears = count
            bestGame.date = Date()
        }
        
        bestGame.totalGamesPlayed+=1
        
        let newTotalAccuracy = ((Double(totalCorrectAnswears) / Double(10 * bestGame.totalGamesPlayed))) * 100
        totalAccuracy = newTotalAccuracy
        
        if totalCorrectAnswears != 0 {
        let textResult = """
        Ваш результат: \(currentCount)/10
        Количество сыгранных квизов: \(bestGame.totalGamesPlayed)
        Рекорд: \(bestGame.correctAnswears)/10 (\(bestGame.date.dateTimeString))
        Средняя точность: \(totalAccuracy.formatWithTwoDecimalPlaces())%
        """
            
            delegate?.didReceiveAlertText(text: textResult)
        } else {
            let texFailure = "Ни одного правильного ответа("
            delegate?.didReceiveAlertText(text: texFailure)
        }
    }
    
    func clearUserDefaults() {
        UserDefaults.standard.removeObject(forKey: Keys.currentCount.rawValue)
        UserDefaults.standard.removeObject(forKey: Keys.totalAccuracy.rawValue)
        UserDefaults.standard.removeObject(forKey: Keys.bestCorrectAnswears.rawValue)
        UserDefaults.standard.removeObject(forKey: Keys.totalGamesPlayed.rawValue)
        UserDefaults.standard.removeObject(forKey: Keys.totalCorrectAnswears.rawValue)
        UserDefaults.standard.removeObject(forKey: "date")
    }
}

    

    
    

