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

public extension SSDPDiscoveryDelegate {
    func ssdpDiscovery(_ discovery: SSDPDiscovery, didDiscoverService service: SSDPService) {}

    func ssdpDiscovery(_ discovery: SSDPDiscovery, didFinishWithError error: Error) {}

    func ssdpDiscoveryDidStart(_ discovery: SSDPDiscovery) {}

    func ssdpDiscoveryDidFinish(_ discovery: SSDPDiscovery) {}
}

/// SSDP discovery for UPnP devices on the LAN
public class SSDPDiscovery {

    /// The UDP socket
    private var sockets: [Socket] = []

    /// Delegate for service discovery
    public var delegate: SSDPDiscoveryDelegate?

    /// The client is discovering
    public var isDiscovering: Bool {
        get {
            return self.sockets.count > 0
        }
    }
    
    // MARK: Initialisation

    public init() {
        HeliumLogger.use()
    }

    deinit {
        self.stop()
    }

    // MARK: Private functions

    /// Read responses.
    private func readResponses() {
        for socket in self.sockets {
            do {
                var data = Data()
                let (bytesRead, address) = try socket.readDatagram(into: &data)

                if bytesRead > 0 {
                    let response = String(data: data, encoding: .utf8)
                    let (remoteHost, _) = Socket.hostnameAndPort(from: address!)!
                    Log.debug("Received: \(response!) from \(remoteHost)")
                    self.delegate?.ssdpDiscovery(self, didDiscoverService: SSDPService(host: remoteHost, response: response!))
                }

            } catch let error {
                Log.error("Socket error: \(error)")
                self.forceStop()
                self.delegate?.ssdpDiscovery(self, didFinishWithError: error)
            }
        }
    }

    /// Read responses with timeout.
    private func readResponses(forDuration duration: TimeInterval) {
        let queue = DispatchQueue.global()

        queue.async() {
            while self.isDiscovering {
                self.readResponses()
            }
        }

        queue.asyncAfter(deadline: .now() + duration) { [unowned self] in
            self.stop()
        }
    }

    /// Force stop discovery closing the socket.
    private func forceStop() {
        while self.isDiscovering {
            self.sockets.removeLast().close()
        }
    }

    // MARK: Public functions

    /**
        Discover SSDP services for a duration.
        - Parameters:
            - duration: The amount of time to wait.
            - searchTarget: The type of the searched service.
    */
    open func discoverService(forDuration duration: TimeInterval = 10, searchTarget: String = "ssdp:all", port: Int32 = 1900, onInterfaces:[String?] = [nil]) {
        Log.info("Start SSDP discovery for \(Int(duration)) duration...")
        self.delegate?.ssdpDiscoveryDidStart(self)

        let message = "M-SEARCH * HTTP/1.1\r\n" +
            "MAN: \"ssdp:discover\"\r\n" +
            "HOST: 239.255.255.250:\(port)\r\n" +
            "ST: \(searchTarget)\r\n" +
            "MX: \(Int(duration))\r\n\r\n"
        
        for interface in onInterfaces {
            var socket: Socket? = nil
            do {
                socket = try Socket.create(type: .datagram, proto: .udp)
                if let socket = socket {
                    try socket.listen(on: 0, node: interface)   // node:nil means the default interface, for all others it should be the interface's IP address
                    // Use Multicast (Caution: Gets blocked by iOS 16 unless the app has the multicast entitlement!)
                    try socket.write(from: message, to: Socket.createAddress(for: "239.255.255.250", on: port)!)
                    self.sockets.append(socket)
                }
            } catch let error {
                // We ignore errors here because we get "-9980(0x-26FC), No route to host" if we're not allowed to multicast, and that's difficult to foresee.
                // Also, with multiple interfaces, some may fail, and we need to ignore that, too, or it gets too difficult to handle for the caller
                // to sort out which work and which don't.
                socket?.close();
                Log.info("Socket error: \(error) on interface \(interface ?? "default")")
            }
        }

        if !self.isDiscovering {    // Might we run into a race condition here?
            //Log.info("Failed SSDP discovery")
            self.delegate?.ssdpDiscoveryDidFinish(self)
        } else {
            self.readResponses(forDuration: duration)
        }
    }
    
    /// Stop the discovery before the timeout.
    open func stop() {
        if self.isDiscovering {
            Log.info("Stop SSDP discovery")
            self.forceStop()
            self.delegate?.ssdpDiscoveryDidFinish(self)
        }
    }
}
