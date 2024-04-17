// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Frameworks",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "Models", targets: ["Models"]),
        .library(name: "Tools", targets: ["Tools"]),
        .library(name: "UITools", targets: ["UITools"]),
        .library(name: "Conversations", targets: ["Tools"]),
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
        .target(name: "UITools",
                dependencies: ["Models", "Tools"],
                path: "./2-UITools/Sources"),
        .target(name: "Conversations",
                dependencies: ["Factory", "Tools", "Models", "UITools"],
                path: "./3-Conversations/Sources"),
        .target(name: "Authentification",
                dependencies: ["Factory", "Tools", "Models", "Conversations", "UITools"],
                path: "./4-Authentification/Sources")
    ]
)
