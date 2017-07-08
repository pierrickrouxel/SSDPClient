import XCTest
@testable import SSDPClient

let timeout: TimeInterval = 5

class SSDPDiscoveryTests: XCTestCase {
    let client = SSDPDiscovery()

    var discoverServiceExpectation: XCTestExpectation?
    var startExpectation: XCTestExpectation?
    var stopExpectation: XCTestExpectation?
    var errorExpectation: XCTestExpectation?

    override func setUp() {
        super.setUp()

        self.errorExpectation = expectation(description: "Error")
        self.errorExpectation!.isInverted = true
        self.client.delegate = self
    }

    override func tearDown() {
        super.tearDown()
    }

    func testDiscoverService() {
        self.startExpectation = expectation(description: "Start")
        self.discoverServiceExpectation = expectation(description: "DiscoverService")

        self.client.discoverService(type: "ssdp:all", timeout: timeout)

        wait(for: [self.errorExpectation!, self.startExpectation!, self.discoverServiceExpectation!], timeout: timeout)
    }

    func testStop() {
        self.stopExpectation = expectation(description: "Stop")
        self.client.discoverService()
        self.client.stop()
        wait(for: [self.errorExpectation!, self.stopExpectation!], timeout: timeout)
    }

    static var allTests = [
        ("testDiscoverService", testDiscoverService),
        ("testStop", testStop),
    ]
}

extension SSDPDiscoveryTests: SSDPDiscoveryDelegate {
    func ssdpDiscovery(_: SSDPDiscovery, didDiscoverService: SSDPService) {
        self.discoverServiceExpectation?.fulfill()
        self.discoverServiceExpectation = nil
    }

    func ssdpDiscoveryDidStart(_: SSDPDiscovery) {
        self.startExpectation?.fulfill()
    }

    func ssdpDiscoveryDidFinish(_: SSDPDiscovery) {
        self.stopExpectation?.fulfill()
    }

    func ssdpDiscovery(_: SSDPDiscovery, didFinishWithError: Error) {
        self.errorExpectation?.fulfill()
    }
}
