import Vapor

func routes(_ application: Application, basicAuthConfig: BasicAuthConfig, twilioConfig: TwilioConfig) throws {
    let authenticators = [
        User.basicAuthMiddleware(basicAuthConfig),
        User.guardMiddleware()
    ]
    let twilioRepository = TwilioAPIRepository(client: application.client, twilioConfig: twilioConfig)
    let messageController = MessageController(application: application, repository: twilioRepository)

    let authenticatedRouter = application.grouped(authenticators)
    authenticatedRouter.get(use: messageController.get(request:))
}
