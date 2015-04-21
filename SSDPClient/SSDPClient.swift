//
//  SSDPClient.swift
//  SSDPClient
//
//  Created by Pierrick Rouxel on 21/03/2015.
//  Copyright (c) 2015 Pierrick Rouxel. All rights reserved.
//

import Foundation

public protocol SSDPClientDelegate {
    // The discovery is started
    func ssdpClientDidStartDiscovery()
    
    // A service was found
    func ssdpClientDidFindService(headers: [String: String])
    
    // The discrovery is ended
    func ssdpClientDidEndDiscovery()
}

public class SSDPClient: NSObject {
    
    private var delegate: SSDPClientDelegate?
    private lazy var socket: AsyncUdpSocket = AsyncUdpSocket(delegate: self)

    public init(delegate: SSDPClientDelegate) {
        self.delegate = delegate
    }
    
    // Discover SSDP services for a duration in secons
    public func discoverForDuration(ST: String, duration: Int) {
        println("Start SSDP discovery for \(duration) seconds...")
        
        var error: NSError?
        
        if (!self.socket.bindToPort(0, error: &error)) {
            println("Error binding: \(error!.description)")
        }
        
        self.socket.enableBroadcast(true, error:&error)
        if (error != nil) {
            println("Error enabling broadcast: \(error!.description)")
        }
        
        self.socket.receiveWithTimeout(NSTimeInterval(duration), tag: 0)
        
        var message = "M-SEARCH * HTTP/1.1\r\n" +
            "MAN: \"ssdp:discover\"\r\n" +
            "HOST: 239.255.255.250:1900\r\n" +
            "ST: \"\(ST)\"\r\n" +
        "MX: 5\r\n\r\n"
        var messageData = message.dataUsingEncoding(NSUTF8StringEncoding)
        self.socket.sendData(messageData, toHost: "239.255.255.250", port: 1900, withTimeout: -1, tag: 0)
    }
    
    // Stop discovery
    public func stop() {
        if !self.socket.isClosed() {
            self.socket.close()
        }
    }
    
    // Parse response to dictionary of headers
    private func parseResponse(response: String) -> [String: String] {
        var headers = [String: String]()
        let lines = response.componentsSeparatedByString("\n")
        
        for line in lines {
            var line = line.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            
            if let colon = line.rangeOfString(":")?.startIndex {
                var key = line.substringToIndex(colon)
                var value = line.substringFromIndex(colon.successor())
                key = key.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                value = value.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                
                // If key found append value to dictionary
                if count(key) > 0 {
                    headers[key] = value
                }
            }
        }
        
        return headers
    }
    
}

 extension SSDPClient: AsyncUdpSocketDelegate {
    
    public func onUdpSocket(sock: AsyncUdpSocket!, didSendDataWithTag tag: Int) {
        // Call delegate
        self.delegate!.ssdpClientDidStartDiscovery()
        
        println("SSDP discovery started")
    }
    
    // Get network responses
    public func onUdpSocket(sock: AsyncUdpSocket!, didReceiveData data: NSData!, withTag tag: Int, fromHost host: String!, port: UInt16) -> Bool {
        var response = NSString(data: data, encoding: NSUTF8StringEncoding)
        var headers = self.parseResponse(response! as String)
        self.delegate?.ssdpClientDidFindService(headers)
        return true
    }
    
    // The socket is closed
    public func onUdpSocketDidClose(sock: AsyncUdpSocket!) {
        // Call delegate
        self.delegate!.ssdpClientDidEndDiscovery()
        
        println("SSDP discovery stopped")
    }
    
    // Close the socket when it stops to listen for response
    public func onUdpSocket(sock: AsyncUdpSocket!, didNotReceiveDataWithTag tag: Int, dueToError error: NSError!) {
        self.stop()
    }
    
}