
import Foundation

class StatisticService: StatisticServiceProtocol {
    
    weak var delegate: StatisticServiceDelegate?
    
    private var userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        case currentCount
        case totalAccuracy
        case bestCorrectAnswears
        case totalGamesPlayed
    }
   
    var currentCount: Int {
        get {
            return userDefaults.integer(forKey: Keys.currentCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.currentCount.rawValue)
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
        
        self.currentCount = count
        
        if count >= bestGame.correctAnswears {
            
            print("in the store")
            
            bestGame.correctAnswears = count
            bestGame.date = Date()
            
        }
        
        let newTotalAccuracy = (Double(count) / Double(questionsQuantity)) * 100
        totalAccuracy = newTotalAccuracy
        
        bestGame.totalGamesPlayed+=1
        
        let textResult = "Ваш результат: \(currentCount)/10 \n Количество сыгранных квизов: \(bestGame.totalGamesPlayed) \n Рекорд: \(bestGame.correctAnswears)/10 (\(bestGame.date.dateTimeString)) \n Средняя точность: \(totalAccuracy.formatWithTwoDecimalPlaces())%"
        
        delegate?.didReceiveAlerttext(text: textResult)
    }
    
    func clearUserDefaults() {
        UserDefaults.standard.removeObject(forKey: Keys.currentCount.rawValue)
        UserDefaults.standard.removeObject(forKey: Keys.totalAccuracy.rawValue)
        UserDefaults.standard.removeObject(forKey: Keys.bestCorrectAnswears.rawValue)
        UserDefaults.standard.removeObject(forKey: Keys.totalGamesPlayed.rawValue)
        UserDefaults.standard.removeObject(forKey: "date")
    }
}

    

    
    

