import Foundation
import Vapor

struct TwilioConfig {
    let accountSID: String
    let authToken: String
    let phoneNumber: String
}

extension TwilioConfig {
    static func fromEnvironment() -> Self? {
        guard let accountSID = Environment.process.TWILIO_ACCOUNT_SID,
              let authToken = Environment.process.TWILIO_AUTH_TOKEN,
              let phoneNumber = Environment.process.TWILIO_TO_NUMBER else {
            return nil
        }
        return Self(accountSID: accountSID, authToken: authToken, phoneNumber: phoneNumber)
    }
}
