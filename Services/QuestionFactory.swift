
import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    
    private var movies: [MostPopularMovie] = []
    private let moviesLoader = MoviesLoader()
    weak var delegate: QuestionFactoryDelegate?
    
    func loadData() {
       
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    print(error)
                    if error as? NetworkError  == NetworkError.clientError {
                        self.delegate?.didFailToLoadData(with: "неверный или просроченный API ключ")
                    } else {
                        self.delegate?.didFailToLoadData(with: "что-то пошло не так(") }
                }
            }
        }
    }
    
    func requestNextQuestion() {
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
           
            guard let movie = self.movies[safe: index] else { return print("returning from requestNextQuestion from QuestionFactory ") }
            
            var imageData = Data()
           
           do {
                imageData = try Data(contentsOf: movie.imageURL)
            } catch {
                self.delegate?.didFailToLoadData(with: "ошибка зазрузки фото")
            }
            
            let rating = Float(movie.rating) ?? 0
            
            let text = "Рейтинг этого фильма больше чем 7?"
            let correctAnswer = rating > 7
            
            let question = QuizQuestion(image: imageData,
                                         text: text,
                                         correctAnswer: correctAnswer)
         
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}
