//
//  SSDPClient.swift
//  SSDPClient
//
//  Created by Pierrick Rouxel on 21/03/2015.
//  Copyright (c) 2015 Pierrick Rouxel. All rights reserved.
//

import Foundation

public protocol SSDPClientDelegate {
    func didStartSearch()
    func didReceiveResponse(response: String)
    func didEndSearch()
}

public class SSDPClient: NSObject {
    
    private var delegate: SSDPClientDelegate?
    
    private var udpSocket: GCDAsyncUdpSocket?
    
    private var responses: [String]?
    
    public init(delegate: SSDPClientDelegate) {
        self.delegate = delegate
    }
    
    public func discoverForDuration(sn: String, duration: Int) {
        println("Start SSDP discovery for \(duration) seconds...")
        self.search(sn)
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW, Int64(duration * Int(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(),
            {
                self.stopSearch()
            }
        )
    }
    
    func search(sn: String) {
        var message = "M-SEARCH * HTTP/1.1\r\n" +
            "MAN: \"ssdp:discover\"\r\n" +
            "HOST: 239.255.255.250:1900\r\n" +
            "ST: \"\(sn)\"\r\n" +
            "MX: 5\r\n\r\n"
        
        self.udpSocket = self.createSocket()
        var messageData = message.dataUsingEncoding(NSUTF8StringEncoding)
        self.udpSocket!.sendData(messageData, toHost: "239.255.255.250", port: 1900, withTimeout: -1, tag:0)
        
        // Call delegate
        self.delegate!.didStartSearch()
        println("SSDP Discovery started")
    }
    
    public func stopSearch() {
        self.udpSocket!.close()
        self.udpSocket = nil
        
        // Call delegate
        self.delegate!.didEndSearch()
        println("SSDP Discovery stoped")
    }
    
    private func createSocket() -> GCDAsyncUdpSocket {
        var socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        var error: NSError?
        
        if (!socket.bindToPort(0, error: &error)) {
            println("Error binding: \(error!.description)")
        }
        
        if (!socket.beginReceiving(&error)) {
            println("Error receiving: \(error!.description)")
        }
        
        socket.enableBroadcast(true, error:&error)
        
        if (error != nil) {
            println("Error enabling broadcast: \(error!.description)")
        }
        
        return socket
    }
    
}

 extension SSDPClient: GCDAsyncUdpSocketDelegate {
    
    // Get network responses
    public func udpSocket(sock: GCDAsyncUdpSocket, didReceiveData data: NSData, fromAddress address: NSData, withFilterContext filterContext: AnyObject) {
        var response = NSString(data: data, encoding: NSUTF8StringEncoding)
        if response != nil {
            if let delegate = self.delegate {
                delegate.didReceiveResponse(response!)
            }
        }
    }
    
}