# SSDPClient

![](https://img.shields.io/badge/swift-5.10-orange.svg) ![](https://img.shields.io/badge/plataforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20linux-lightgrey.svg) ![gitHub license](https://img.shields.io/badge/license-MIT-blue.svg) [![gitHub release](https://img.shields.io/badge/version-v1.0.0-brightgreen.svg)](https://github.com/pierrickrouxel/SSDPClient/releases) ![github stable](https://img.shields.io/badge/stable-true-brightgreen.svg) [![donate](https://img.shields.io/badge/donate-buy%20me%20a%20coffee-yellow?logo=buy-me-a-coffee)](https://www.buymeacoffee.com/pierrickrouxel)

[SSDP](https://en.wikipedia.org/wiki/Simple_Service_Discovery_Protocol) client for Swift using the Swift Package Manager. Works on iOS, macOS, tvOS, watchOS and Linux.

## Installation

[![GitHub spm](https://img.shields.io/badge/spm-supported-brightgreen.svg)](https://swift.org/package-manager/)

SSDPClient is available through [Swift Package Manager](https://swift.org/package-manager/). To install it, add the following line to your `Package.swift` dependencies:

```swift
.package(url: "https://github.com/pierrickrouxel/SSDPClient.git", from: "1.0.0")
```

## Usage

SSDPClient can be used to discover SSDP devices and services :

```swift
import SSDPClient

class ServiceDiscovery {
    let client = SSDPDiscovery()

    init() {
        self.client.delegate = self
        self.client.discoverService()
    }
}
```

To handle the discovery implement the `SSDPDiscoveryDelegate` protocol :

```swift
extension ServiceDiscovery: SSDPDiscoveryDelegate {
    func ssdpDiscovery(_: SSDPDiscovery, didDiscoverService: SSDPService) {
        // ...
    }
}
```

### Discovery

`SSDPDiscovery` provides two instance methods to discover services :

- `discoverService(forDuration duration: TimeInterval = 10, searchTarget: String = "ssdp:all")` - Discover SSDP services for a duration.

- `stop()` - Stop the discovery before the end.

### Delegate

The `SSDPDiscoveryDelegate` protocol defines delegate methods that you should implement when using `SSDPDiscovery` discover tasks :

- `func ssdpDiscovery(_ discovery: SSDPDiscovery, didDiscoverService service: SSDPService)` - Tells the delegate a requested service has been discovered.

- `func ssdpDiscovery(_ discovery: SSDPDiscovery, didFinishWithError error: Error)` - Tells the delegate that the discovery ended due to an error.

- `func ssdpDiscoveryDidStart(_ discovery: SSDPDiscovery)` - Tells the delegate that the discovery has started.

- `func ssdpDiscoveryDidFinish(_ discovery: SSDPDiscovery)` - Tells the delegate that the discovery has finished.

### Service

`SSDPService` is the discovered service. It contains the following attributes :

- `host: String` - The host of service
- `location: String?` - The value of `LOCATION` header
- `server: String?` - The value of `SERVER` header
- `searchTarget: String?` - The value of `ST` header
- `uniqueServiceName: String?` - The value of `USN` header
- `responseHeaders: [String: String]?` - Key-Value pairs of all original response headers

## Test

Run test:

```swift
swift test
```

## Troubleshooting

### The application crash with error code `-9982 Bad file descriptor`

You probably run a security issue. You should grant the local network authorization access.

You can handle this error using the following code:

```swift
let authorization = LocalNetworkAuthorization()
authorization.requestAuthorization { granted in
    if granted {
        print("Permission Granted")
        let discovery = ServiceDiscovery(delegate: self)
        discovery.start()
    } else {
        print("Permission denied")
    }
}
```
