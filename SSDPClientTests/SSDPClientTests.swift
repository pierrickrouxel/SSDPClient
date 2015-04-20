//
//  SSDPClientTests.swift
//  SSDPClientTests
//
//  Created by Pierrick Rouxel on 21/03/2015.
//  Copyright (c) 2015 Pierrick Rouxel. All rights reserved.
//

import Cocoa
import XCTest
import SSDPClient

class MockedSSDPClient: SSDPClient {
    override func onUdpSocket(sock: AsyncUdpSocket!, didSendDataWithTag tag: Int) {
        super.onUdpSocket(sock, didSendDataWithTag: tag)

        let responseMock = "HTTP/1.1 200 OK\n" +
            "CACHE-CONTROL: max-age=1800\n" +
            "DATE: Tue, 9 Jan 2007 09:41:00 GMT\n" +
            "EXT:\n" +
            "LOCATION: test\n" +
            "ST: ssdpclient:test\n\n"

        self.onUdpSocket(sock, didReceiveData: responseMock.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false), withTag: tag, fromHost: "0.0.0.0", port: 1900)
    }
}

class SSDPClientTests: XCTestCase {

    lazy var ssdpClient: SSDPClient = MockedSSDPClient(delegate: self)

    var startDiscovery: XCTestExpectation?
    var findService: XCTestExpectation?
    var endDiscovery: XCTestExpectation?

    var headers: [String: String]?

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    // The delegate should be called at the start of search
    func testStartDiscovery() {
        self.startDiscovery = self.expectationWithDescription("Start of search")

        ssdpClient.discoverForDuration("ssdp:all", duration: 1)

        self.waitForExpectationsWithTimeout(2, handler: nil)

        self.startDiscovery = nil
    }

    // The SSDP serveur should responds to the query
    func testDiscoverService() {
        self.findService = self.expectationWithDescription("Receive response")

        ssdpClient.discoverForDuration("ssdp:all", duration: 5)

        self.waitForExpectationsWithTimeout(5, handler: nil)

        XCTAssert(self.headers?["LOCATION"] == "test", "The location should be test")

        self.findService = nil
    }

    // The delegate should be called at the end of search
    func testEndDiscovery() {
        self.endDiscovery = self.expectationWithDescription("End of search")

        ssdpClient.discoverForDuration("ssdpclient:test", duration: 1)

        self.waitForExpectationsWithTimeout(2, handler: nil)

        self.endDiscovery = nil
    }

}

extension SSDPClientTests: SSDPClientDelegate {
    func ssdpClientDidStartDiscovery() {
        self.startDiscovery?.fulfill()
    }

    func ssdpClientDidFindService(headers: [String: String]) {
        self.headers = headers
        self.findService?.fulfill()
    }

    func ssdpClientDidEndDiscovery() {
        self.endDiscovery?.fulfill()
    }
}
