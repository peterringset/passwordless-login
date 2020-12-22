import Vapor

protocol TwilioRepository {
    func latestMessage() -> EventLoopFuture<Message?>
}

struct TwilioAPIRepository: TwilioRepository {
    let client: Client
    let twilioConfig: TwilioConfig
    
    private var uri: URI {
        let phoneNumber = twilioConfig.phoneNumber
            .addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!
        let query = ["PageSize": "1", "To": phoneNumber]
            .map({ "\($0)=\($1)"}).joined(separator: "&")
        let path = "/2010-04-01/Accounts/\(twilioConfig.accountSID)/Messages.json"
        return URI(scheme: "https", host: "api.twilio.com", path: path, query: query)
    }
    
    private var headers: HTTPHeaders {
        var headers = HTTPHeaders()
        headers.basicAuthorization = BasicAuthorization(username: twilioConfig.accountSID, password: twilioConfig.authToken)
        return headers
    }
    
    func latestMessage() -> EventLoopFuture<Message?> {
        let request = ClientRequest(method: .GET, url: uri, headers: headers)
        return client.send(request).flatMapThrowing { response -> Message? in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            
            let decoded = try response.content.decode(MessageList.self, using: decoder)
            return decoded.messages.first
        }
    }
}

private extension CharacterSet {
    static let rfc3986Unreserved = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~")
}
