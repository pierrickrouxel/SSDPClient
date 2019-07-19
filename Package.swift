// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "SSDPClient",
    products: [
        .library(name: "SSDPClient", targets: ["SSDPClient"]),
    ],
    dependencies: [
        .package(url: "https://github.com/IBM-Swift/BlueSocket.git", from: "1.0.0"),
        .package(url: "https://github.com/IBM-Swift/HeliumLogger.git", from: "1.8.0"),
    ],
    targets: [
        .target(
            name: "SSDPClient",
            dependencies: ["Socket", "HeliumLogger"]),
        .testTarget(
            name: "SSDPClientTests",
            dependencies: ["SSDPClient"]),
    ]
)
