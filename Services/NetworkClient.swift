
import Foundation

struct NetworkClient {
    
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Проверяем, пришла ли ошибка
            if let error = error {
                handler(.failure(error))
                return
            }
            
            // Проверяем, что нам пришёл успешный код ответа
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(NetworkError.codeError))
                return
            }
            
            guard let errorData = data else { return }
            print(errorData)
            do {
                let clientError = try JSONDecoder().decode(ClientError.self, from: errorData)
                if clientError.items.isEmpty{
                    handler(.failure(NetworkError.clientError))
                }
            } catch {
            
            }
        
            // Возвращаем данные
            guard let resultData = data else { return }
            handler(.success(resultData))
        }
        
        task.resume()
    }
}
