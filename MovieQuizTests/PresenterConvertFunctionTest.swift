
import XCTest
@testable import MovieQuiz // импортируем приложение для тестирования

final class PresenterConvertFunctionTest: MovieQuizViewControllerProtocol {
    
    func makeAlert(text: MovieQuiz.AlertModel) {}
    
    func viewController() {}
    
    func showLoadingIndicator() {}
    
    func hideLoadingIndicator() {}
    
    func highlightImageBorder(isCorrectAnswer: Bool) {}
    
    func makeButtonsDisable(toggle: Bool) {}
    
    func updateCounterLabel() {}
    
    func showPicture(question: MovieQuiz.QuizStepViewModel) {}
}

final class ConvertFunctionTest: XCTestCase {
    
    func convertTest () throws {
        
        let viewController = PresenterConvertFunctionTest()
        let presenter = MovieQuizPresenter(viewController: viewController)
        
        let emptyData = Data()
        let testQuestion = QuizQuestion(image: emptyData, text: "тест", correctAnswer: true)
        
        let testModel = presenter.convert(model: testQuestion)
        
        XCTAssertNil(testModel.image)
        XCTAssertEqual(testModel.question, "error")
        
    }
    
    func testExample() throws {
        let viewController = PresenterConvertFunctionTest()
        let presenter = MovieQuizPresenter(viewController: viewController)
        
        
        
        
        if let image = UIImage(named: "Deadpool") {
            // Преобразование UIImage в Data
            if let imageData = image.pngData() {
                // Создание экземпляра структуры
                let testQuestion = QuizQuestion(image: imageData,
                                                text: "тест",
                                                correctAnswer: true)
                
                print("проверка картинки на пустоту = ", testQuestion.image)
                
                let testModel = presenter.convert(model: testQuestion)
                
                XCTAssertNotNil(testModel.image)
                XCTAssertEqual(testModel.question, "тест")
            }
            
        }
        
//        if let image = UIImage(named: "Deadpool") {
//            // Преобразование UIImage в Data
//            if let imageData = image.pngData() {
//                // Создание экземпляра структуры
//                let testQuestion = QuizQuestion(image: imageData,
//                                                text: "тест",
//                                                correctAnswer: true)
//                
//                print("проверка картинки на пустоту = ", testQuestion.image)
//                
//                let testModel = presenter.convert(model: testQuestion)
//                
//                XCTAssertNotNil(testModel.image)
//                XCTAssertEqual(testModel.question, "тест")
//            }
//            
//        }
        
        
    }
    
}
