// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "Lista",
    products: [
        .library(
            name: "Lista",
            targets: ["Lista"]),
    ],
    dependencies: [
        // other dependencies
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "Lista"),
        .testTarget(
            name: "ListaTests",
            dependencies: ["Lista"]),
    ]
)
