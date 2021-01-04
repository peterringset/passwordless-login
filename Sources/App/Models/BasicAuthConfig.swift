import Vapor

struct BasicAuthConfig {
    let realm: String
    let username: String
    let password: String
}

extension BasicAuthConfig {
    static func fromEnvironment() -> Self? {
        guard let realm = Environment.process.BASIC_AUTH_REALM,
              let username = Environment.process.BASIC_AUTH_USERNAME,
              let password = Environment.process.BASIC_AUTH_PASSWORD else {
            return nil
        }
        return Self(realm: realm, username: username, password: password)
    }
}
