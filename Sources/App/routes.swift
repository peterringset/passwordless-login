import Vapor

func routes(_ application: Application, twilioConfig: TwilioConfig) throws {
    let twilioRepository = TwilioAPIRepository(client: application.client, twilioConfig: twilioConfig)
    let messageController = MessageController(application: application, repository: twilioRepository)
    application.get(use: messageController.get(request:))
}
