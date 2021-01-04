import Vapor

// This code is heavily based on code from here:
// https://github.com/vapor/vapor/issues/2337#issuecomment-740675655

extension Authenticatable {
    static func basicAuthMiddleware(_ configuration: BasicAuthConfig) -> BasicAuthenticator {
        return UserAuthenticator(realm: configuration.realm, username: configuration.username, password: configuration.password)
    }
}

struct User: Authenticatable { }

struct UserAuthenticator: BasicAuthenticator {
    
    let realm: String
    let username: String
    let password: String

    func authenticate(basic: BasicAuthorization, for request: Request) -> EventLoopFuture<Void> {
        if basic.username == username && basic.password == password {
            request.auth.login(User())
        }
        return request.eventLoop.makeSucceededFuture(())
    }

    private let headerName = "WWW-Authenticate"
    private var headerValue: String {
        let x = realm.unicodeScalars.reduce(into: "") { $0 += $1.escaped(asASCII: false) }
        return "Basic realm=\"\(x)\", charset=\"UTF-8\""
    }

    public func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        return self.authenticate(request: request).flatMap {
            next.respond(to: request).flatMap { response in
                if response.status == .unauthorized && !response.headers.contains(name: self.headerName) {
                    response.headers.replaceOrAdd(name: self.headerName, value: self.headerValue)
                }
                return response.encodeResponse(for: request)
            }.flatMapErrorThrowing { error in
                switch error {
                case let abort as AbortError where abort.status == .unauthorized:
                    request.logger.report(error: error)
                    let response = Response(status: .unauthorized, headers: [:])
                    response.headers.replaceOrAdd(name: self.headerName, value: self.headerValue)
                    return response
                default:
                    throw error
                }
            }
        }
    }
}
