
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
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return print("returning from requestNextQuestion from QF ") }
            
            var imageData = Data()
           
           do {
                imageData = try Data(contentsOf: movie.imageURL)
            } catch {
                print("Failed to load image")
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
    
    //    private let questions: [QuizQuestion] = [
    //       QuizQuestion(
    //           image: "The Godfather",
    //           rating: 9.2,
    //           correctAnswer: true),
    //       QuizQuestion(
    //           image: "The Dark Knight",
    //           rating: 9,
    //           correctAnswer: true),
    //       QuizQuestion(
    //           image: "Kill Bill",
    //           rating: 8.1,
    //           correctAnswer: true),
    //       QuizQuestion(
    //           image: "The Avengers",
    //           rating: 8,
    //           correctAnswer: true),
    //       QuizQuestion(
    //           image: "Deadpool",
    //           rating: 8,
    //           correctAnswer: true),
    //       QuizQuestion(
    //           image: "The Green Knight",
    //           rating: 6.6,
    //           correctAnswer: true),
    //       QuizQuestion(
    //           image: "Old",
    //           rating: 5.8,
    //           correctAnswer: false),
    //       QuizQuestion(
    //           image: "The Ice Age Adventures of Buck Wild",
    //           rating: 4.3,
    //           correctAnswer: false),
    //       QuizQuestion(
    //           image: "Tesla",
    //           rating: 5.1,
    //           correctAnswer: false),
    //       QuizQuestion(
    //           image: "Vivarium",
    //           rating: 5.8,
    //           correctAnswer: false)
    //    ]
        
}
