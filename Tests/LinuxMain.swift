import XCTest
@testable import SSDPDiscoveryTests
@testable import SSDPServiceTests

XCTMain([
    testCase(SSDPDiscoveryTests.allTests),
    testCase(SSDPServiceTests.allTests),
])
