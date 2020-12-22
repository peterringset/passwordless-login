import Foundation

struct MessageList: Codable {
    let messages: [Message]
}

struct Message: Codable {
    let body: String
    let sent: Date
    
    private enum CodingKeys: String, CodingKey {
        case body
        case sent = "date_sent"
    }
}
