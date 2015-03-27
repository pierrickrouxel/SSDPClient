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
    
    var startDiscovery: XCTestExpectation?
    var findService: XCTestExpectation?
    var endDiscovery: XCTestExpectation?
    
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
    // This test only works if ans SSDP server responds to the query
    func testDiscoveryService() {
        self.findService = self.expectationWithDescription("Receive response")
            
        ssdpClient.discoverForDuration("ssdp:all", duration: 5)
        
        self.waitForExpectationsWithTimeout(5, handler: nil)
        
        self.findService = nil
    }
    
    // The delegate should be called at the end of search
    func testEndDiscovery() {
        self.endDiscovery = self.expectationWithDescription("End of search")
        
        ssdpClient.discoverForDuration("ssdp:all", duration: 1)
        
        self.waitForExpectationsWithTimeout(2, handler: nil)
        
        self.endDiscovery = nil
    }
    
}

extension SSDPClientTests: SSDPClientDelegate {
    func ssdpClientDidStartDiscovery() {
        self.startDiscovery?.fulfill()
    }
    
    func ssdpClientDidFindService(headers: [String: String]) {
        self.findService?.fulfill()
    }
    
    func ssdpClientDidEndDiscovery() {
        self.endDiscovery?.fulfill()
    }
}
