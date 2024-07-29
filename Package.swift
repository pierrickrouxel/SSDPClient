// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "SSDPClient",
    products: [
        .library(name: "SSDPClient", targets: ["SSDPClient"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Kitura/BlueSocket.git", from: "1.0.200"),
        .package(url: "https://github.com/Kitura/HeliumLogger.git", from: "1.9.200"),
    ],
    targets: [
        .target(
            name: "SSDPClient",
            dependencies: [
                .product(name: "Socket", package: "BlueSocket"),
                .product(name: "HeliumLogger", package: "HeliumLogger")
            ]
        ),
        .testTarget(
            name: "SSDPClientTests",
            dependencies: ["SSDPClient"]),
    ]
)
