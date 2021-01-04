import Leaf
import Vapor

// configures your application
public func configure(_ application: Application) throws {
    application.views.use(.leaf)

    // register routes
    guard let twilioConfig = TwilioConfig.fromEnvironment() else {
        preconditionFailure("Cannot read twilio config from environment")
    }
    guard let basicAuthConfig = BasicAuthConfig.fromEnvironment() else {
        preconditionFailure("Cannor read basic auth config from environment")
    }
    try routes(application, basicAuthConfig: basicAuthConfig, twilioConfig: twilioConfig)
}
