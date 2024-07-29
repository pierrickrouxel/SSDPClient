import Foundation

private let HeaderRegex = try! NSRegularExpression(pattern: "^([^\r\n:]+): (.*)$", options: [.anchorsMatchLines])

public class SSDPService {
    /// The host of service
    public internal(set) var host: String
    /// The headers of the original response
    public internal(set) var responseHeaders: [String: String]?
    /// The value of `LOCATION` header
    public internal(set) var location: String?
    /// The value of `SERVER` header
    public internal(set) var server: String?
    /// The value of `ST` header
    public internal(set) var searchTarget: String?
    /// The value of `USN` header
    public internal(set) var uniqueServiceName: String?

    // MARK: Initialisation

    /**
        Initialize the `SSDPService` with the discovery response.

        - Parameters:
            - host: The host of service
            - response: The discovery response.
    */
    init(host: String, response: String) {
        self.host = host
        
        let headers = self.parse(response)
        self.responseHeaders = headers
        
        self.location = headers["LOCATION"]
        self.server = headers["SERVER"]
        self.searchTarget = headers["ST"]
        self.uniqueServiceName = headers["USN"]
    }

    // MARK: Private functions
    
    /**
        Parse the discovery response.
     
        - Parameters:
            - response: The discovery response.
     */
    private func parse(_ response: String) -> [String: String] {
        var result = [String: String]()
        
        let matches = HeaderRegex.matches(in: response, range: NSRange(location: 0, length: response.utf16.count))
        for match in matches {
            let keyCaptureGroupIndex = match.range(at: 1)
            let key = (response as NSString).substring(with: keyCaptureGroupIndex)
            let valueCaptureGroupIndex = match.range(at: 2)
            let value = (response as NSString).substring(with: valueCaptureGroupIndex)
            result[key.uppercased()] = value
        }
        
        return result
    }
}
