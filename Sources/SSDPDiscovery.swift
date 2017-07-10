import Foundation
import HeliumLogger
import LoggerAPI
import Socket

// MARK: Protocols

/// Delegate for service discovery
public protocol SSDPDiscoveryDelegate {
    /// Tells the delegate a requested service has been discovered.
    func ssdpDiscovery(_ discovery: SSDPDiscovery, didDiscoverService service: SSDPService)

    /// Tells the delegate that the discovery ended due to an error.
    func ssdpDiscovery(_ discovery: SSDPDiscovery, didFinishWithError error: Error)

    /// Tells the delegate that the discovery has started.
    func ssdpDiscoveryDidStart(_ discovery: SSDPDiscovery)

    /// Tells the delegate that the discovery has finished.
    func ssdpDiscoveryDidFinish(_ discovery: SSDPDiscovery)
}

extension SSDPDiscoveryDelegate {
    func ssdpDiscovery(_ discovery: SSDPDiscovery, didDiscoverService service: SSDPService) {}

    func ssdpDiscovery(_ discovery: SSDPDiscovery, didFinishWithError error: Error) {}

    func ssdpDiscoveryDidStart(_ discovery: SSDPDiscovery) {}

    func ssdpDiscoveryDidFinish(_ discovery: SSDPDiscovery) {}
}

/// SSDP discovery for UPnP devices on the LAN
public class SSDPDiscovery {

    /// The UDP socket
    private var socket: Socket?

    /// Delegate for service discovery
    var delegate: SSDPDiscoveryDelegate?

    /// The client is discovering
    var isDiscovering: Bool {
        get {
            return self.socket != nil && self.socket!.isConnected
        }
    }

    // MARK: Initialisation

    init() {
        HeliumLogger.use()
    }

    deinit {
        self.stop()
    }

    // MARK: Private functions

    /// Read responses.
    private func readResponses() {
        do {
            var data = Data()
            let (bytesRead, _) = try self.socket!.readDatagram(into: &data)

            if bytesRead > 0 {
                let response = String(data: data, encoding: .utf8)
                Log.debug("Received: \(response!)")
                self.delegate?.ssdpDiscovery(self, didDiscoverService: SSDPService(response: response!))
            }

        } catch let error {
            Log.error("Socket error: \(error)")
            self.forceStop()
            self.delegate?.ssdpDiscovery(self, didFinishWithError: error)
        }
    }

    /// Read responses with timeout.
    private func readResponses(forDuration duration: TimeInterval) {
        let queue = DispatchQueue.global()

        queue.async() {
            repeat {
                self.readResponses()
            } while self.isDiscovering
        }

        queue.asyncAfter(deadline: .now() + duration) { [unowned self] in
            self.stop()
        }
    }

    /// Force stop discovery closing the socket.
    private func forceStop() {
        if self.isDiscovering {
            self.socket!.close()
        }
        self.socket = nil
    }

    // MARK: Public functions

    /**
        Discover SSDP services for a duration.
        - Parameters:
            - duration: The amount of time to wait.
            - searchTarget: The type of the searched service.
    */
    open func discoverService(forDuration duration: TimeInterval = 10, searchTarget: String = "ssdp:all") {
        Log.info("Start SSDP discovery for \(Int(duration)) duration...")
        self.delegate?.ssdpDiscoveryDidStart(self)

        let message = "M-SEARCH * HTTP/1.1\r\n" +
            "MAN: \"ssdp:discover\"\r\n" +
            "HOST: 239.255.255.250:1900\r\n" +
            "ST: \(searchTarget)\r\n" +
            "MX: \(Int(duration))\r\n\r\n"

        do {
            self.socket = try Socket.create(type: .datagram, proto: .udp)
            try self.socket!.listen(on: 0)

            self.readResponses(forDuration: duration)

            Log.debug("Send: \(message)")
            try self.socket?.write(from: message, to: Socket.createAddress(for: "239.255.255.250", on: 1900)!)

        } catch let error {
            Log.error("Socket error: \(error)")
            self.forceStop()
            self.delegate?.ssdpDiscovery(self, didFinishWithError: error)
        }
    }

    /// Stop the discovery before the timeout.
    open func stop() {
        if self.socket != nil {
            Log.info("Stop SSDP discovery")
            self.forceStop()
            self.delegate?.ssdpDiscoveryDidFinish(self)
        }
    }
}
