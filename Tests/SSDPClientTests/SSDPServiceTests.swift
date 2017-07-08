import XCTest

@testable import SSDPClient

let response = "HTTP/1.1 200 OK\r\n" +
    "CACHE-CONTROL: max-age=120\r\n" +
    "ST: upnp:rootdevice\r\n" +
    "USN: uuid:45de27fb-36fd-4c24-a7da-3506f0109bf4::upnp:rootdevice\r\n" +
    "EXT:\r\n" +
    "SERVER: neufbox/neufbox UPnP/1.1 MiniUPnPd/1.8\r\n" +
    "LOCATION: http://192.168.1.1:49152/rootDesc.xml\r\n" +
    "OPT: \"http://schemas.upnp.org/upnp/1/0/\"; ns=01\r\n\r\n"

class SSDPServiceTests: XCTestCase {
    func testParse() {

    }

    static var allTests = [
        ("testParse", testParse),
    ]
}
