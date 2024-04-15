// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Frameworks",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "Models", targets: ["Models"]),
        .library(name: "Tools", targets: ["Tools"]),
        .library(name: "Authentification", targets: ["Authentification"]),
    ],
    dependencies: [
            .package(url: "https://github.com/hmlongco/Factory.git", from: "2.3.0")
    ],
    targets: [
        .target(name: "Models",
                path: "./0-Models/Sources"),
        .target(name: "Tools",
                dependencies: ["Models"],
                path: "./1-Tools/Sources"),
        .target(name: "Authentification",
                dependencies: ["Factory", "Tools", "Models"],
                path: "./2-Authentification/Sources")
    ]
)
