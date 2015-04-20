[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

# SSDPClient
This framework provides a simple way to discover SSDP devices.


## Usage
```swift
import SSDPClient
```

### Initializing
```swift
init(delegate: SSDPClientDelegate)
```
The delegate should conform to SSDPClientDelegate


### Methods
```swift
discoverForDuration(sn: String, duration: Int)
```
Search services for duration in seconds.  
`stop` is automatically called at the end of duration.  
You can use `ssdp:all` to browse all services.

```swift
stop()
```
Stop the search.

### Delegate (SSDPClientDelegate)
```swift
ssdpClientDidStartDiscovery()
```
The search has started.

```swift
ssdpClientDidFindService(headers: [String: String])
```
A service has responded.

```swift
ssdpClientDidEndDiscovery()
```
The search has ended.


## Header
ST: Service Type  
USN: Unique Service Name  
LOCATION: URL pointing to the service  
SERVER: Type of server


## References
SSDP specification:
http://quimby.gnus.org/internet-drafts/draft-cai-ssdp-v1-03.txt
