import Vapor
import XCTest

@testable import App

class MessageControllerTests: XCTestCase {
    
    private var application: Application!
    private var repository: TwilioMockRepository!
    
    override func setUp() {
        let eventLoop = EmbeddedEventLoop()
        
        application = Application(.testing)
        repository = TwilioMockRepository(eventLoop: eventLoop)
        
        let controller = MessageController(application: application, repository: repository)
        let renderer = TestRenderer(eventLoop: eventLoop)
        application.views.use { app -> ViewRenderer in
            return renderer
        }
        application.get(use: controller.get(request:))
    }
    
    override func tearDown() {
        application.shutdown()
    }
    
    func testLatestMessageThatIsNotOld() throws {
        repository.message = Message(body: "Testing a new message", sent: Date().addingTimeInterval(-10))
        try application.test(.GET, "/") { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(response.body.string, #"{"message":"Testing a new message"}"#)
        }
    }
    
    func testLastestMessageThatIsOld() throws {
        repository.message = Message(body: "Testing an old message", sent: Date().addingTimeInterval(-130))
        try application.test(.GET, "/") { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(response.body.string, #"{"message":"(no message to show)"}"#)
        }
    }
    
}

private class TwilioMockRepository: TwilioRepository {
    
    let eventLoop: EventLoop
    var message: Message?

    init(eventLoop: EventLoop) {
        self.eventLoop = eventLoop
    }
    
    func latestMessage() -> EventLoopFuture<Message?> {
        return eventLoop.future(message)
    }
    
}

private struct TestRenderer: ViewRenderer {
    
    let eventLoop: EventLoop
    
    func render<E>(_ name: String, _ context: E) -> EventLoopFuture<View> where E : Encodable {
        let json = try! JSONEncoder().encode(context)
        return eventLoop.future(View(data: ByteBuffer(data: json)))
    }
    
    func `for`(_ request: Request) -> ViewRenderer {
        return self
    }
    
}
