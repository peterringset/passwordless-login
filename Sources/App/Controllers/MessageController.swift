import Vapor

struct MessageController {
    
    let application: Application
    let repository: TwilioRepository
    
    func get(request: Request) throws -> EventLoopFuture<View> {
        _ = try request.auth.require(User.self)
        
        return repository.latestMessage().optionalMap { message -> Message? in
            if message.sent < Date().addingTimeInterval(-120) {
                return nil
            }
            return message
        }.flatMap { message -> EventLoopFuture<View> in
            return request.view.render("index", ["message": "\(message?.body ?? "(no message to show)")"])
        }
    }
    
}

