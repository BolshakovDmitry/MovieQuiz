
import Foundation

struct ClientError: Codable {
    let errorMessage: String
    let items: [MostPopularMovie]
}
