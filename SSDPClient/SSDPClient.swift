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
    func didStartSearch()
    
    // A service was found
    func didFindService(response: String)
    
    // The discrovery is ended
    func didEndSearch()
}

public class SSDPClient: NSObject {
    
    private var delegate: SSDPClientDelegate?
    lazy private var socket: AsyncUdpSocket = {
        return AsyncUdpSocket(delegate: self)
    }()

    public init(delegate: SSDPClientDelegate) {
        self.delegate = delegate
    }
    
    // Discover SSDP services for a duration
    public func discoverForDuration(sn: String, duration: Int) {
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
            "ST: \"\(sn)\"\r\n" +
        "MX: 5\r\n\r\n"
        var messageData = message.dataUsingEncoding(NSUTF8StringEncoding)
        self.socket.sendData(messageData, toHost: "239.255.255.250", port: 1900, withTimeout: -1, tag: 0)
    }
    
    public func stop() {
        if !self.socket.isClosed() {
            self.socket.close()
        }
    }
    
}

 extension SSDPClient: AsyncUdpSocketDelegate {
    
    public func onUdpSocket(sock: AsyncUdpSocket!, didSendDataWithTag tag: Int) {
        // Call delegate
        self.delegate!.didStartSearch()
        
        println("SSDP discovery started")
    }
    
    // Get network responses
    public func onUdpSocket(sock: AsyncUdpSocket!, didReceiveData data: NSData!, withTag tag: Int, fromHost host: String!, port: UInt16) -> Bool {
        var response = NSString(data: data, encoding: NSUTF8StringEncoding)
        if response != nil {
            if let delegate = self.delegate {
                delegate.didFindService(response!)
            }
        }
        return true
    }
    
    // The socket is closed
    public func onUdpSocketDidClose(sock: AsyncUdpSocket!) {
        // Call delegate
        self.delegate!.didEndSearch()
        
        println("SSDP discovery stopped")
    }
    
    // Close the socket when it stops to listen for response
    public func onUdpSocket(sock: AsyncUdpSocket!, didNotReceiveDataWithTag tag: Int, dueToError error: NSError!) {
        self.stop()
    }
    
}