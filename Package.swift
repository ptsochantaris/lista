// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Lista",
    products: [
        .library(
            name: "Lista",
            targets: ["Lista"]
        ),
    ],
    targets: [
        .target(
            name: "Lista"),
        .testTarget(
            name: "ListaTests",
            dependencies: ["Lista"]
        ),
    ]
)
