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

class SSDPClientTests: XCTestCase {
    
    lazy var ssdpClient: SSDPClient = SSDPClient(delegate: self)
    
    var startSearch: XCTestExpectation?
    var receiveResponse: XCTestExpectation?
    var endSearch: XCTestExpectation?
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testStartDiscovery() {
        self.startSearch = self.expectationWithDescription("Start of search")
        
        ssdpClient.discoverForDuration("ssdp:all", duration: 1)
        
        self.waitForExpectationsWithTimeout(2, handler: nil)
        
        self.startSearch = nil
    }
    
    // The SSDP serveur should responds to the query
    // This test only works if ans SSDP server responds to the query
    func testDiscoveryResponse() {
        self.receiveResponse = self.expectationWithDescription("Receive response")
            
        ssdpClient.discoverForDuration("ssdp:all", duration: 5)
        
        self.waitForExpectationsWithTimeout(5, handler: nil)
        
        self.receiveResponse = nil
    }
    
    // The delegate should be called at the end of search
    func testEndDiscovery() {
        self.endSearch = self.expectationWithDescription("End of search")
        
        ssdpClient.discoverForDuration("ssdp:all", duration: 1)
        
        self.waitForExpectationsWithTimeout(2, handler: nil)
        
        self.endSearch = nil
    }
    
}

extension SSDPClientTests: SSDPClientDelegate {
    func didStartSearch() {
        self.startSearch?.fulfill()
    }
    
    func didReceiveResponse(response: String) {
        self.receiveResponse?.fulfill()
    }
    
    func didEndSearch() {
        self.endSearch?.fulfill()
    }
}
