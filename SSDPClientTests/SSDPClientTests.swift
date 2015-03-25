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
    
    var expectation: XCTestExpectation?
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // The SSDP serveur should responds to the query
    // This test only works if ans SSDP server responds to the query
    func testDiscoveryResponse() {
        self.expectation = self.expectationWithDescription("SSDP response")
        
        ssdpClient.discoverForDuration("ssdp:all", duration: 5)
        
        self.waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    // The delegate should be called at the end of search
    func testEndDiscovery() {
        self.expectation = self.expectationWithDescription("End of search")
        
        ssdpClient.discoverForDuration("ssdp:all", duration: 1)
        
        self.waitForExpectationsWithTimeout(2, handler: nil)
    }
    
}

extension SSDPClientTests: SSDPClientDelegate {
    func didStartSearch() {
    }
    
    func didReceiveResponse(response: String) {
        if self.expectation != nil {
            self.expectation?.fulfill()
            self.expectation = nil
        }
    }
    
    func didEndSearch() {
        if self.expectation != nil {
            self.expectation?.fulfill()
            self.expectation = nil
        }
    }
}
