import App
import Vapor

var environment = try Environment.detect()
try LoggingSystem.bootstrap(from: &environment)
let application = Application(environment)
defer { application.shutdown() }
try configure(application)
try application.run()
