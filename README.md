# SSDPClient
This framework provides a simple way to discover SSDP devices.


## Usage
```swift
import SSDPClient
```

### Initializing
init(delegate:)
The delegate shoud conform to SSDPClientDelegate

### Methods
```swift
search(st)
```
Start the search for a service type.
You can use `ssdp:all` to browse all services.

```swift
searchForDuration(sn, duration)
```
Search services for duration in seconds.
`stopSearch` is automatically called at the end of duration.

```swift
stopSearch()
```
Stop the search.

### Delegate (SSDPClientDelegate)
```swift
didStartSearch()
```
The search has started.

```swift
didReceiveResponse(headers)
```
A service has responded.

```swift
didEndSearch()
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
