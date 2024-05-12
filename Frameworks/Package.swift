// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Frameworks",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "Models", targets: ["Models"]),
        .library(name: "SocketIO", targets: ["SocketIO"]),
        .library(name: "Tools", targets: ["Tools"]),
        .library(name: "UITools", targets: ["UITools"]),
        .library(name: "ChatConversation", targets: ["ChatConversation"]),
        .library(name: "Conversations", targets: ["Tools"]),
        .library(name: "Authentification", targets: ["Authentification"]),
    ],
    dependencies: [
        .package(url: "https://github.com/hmlongco/Factory.git", from: "2.3.0"),
        .package(url: "https://github.com/daltoniam/Starscream", exact: "4.0.6")
    ],
    targets: [
        .target(name: "Models",
                path: "./0-Models/Sources"),
        .target(name: "SocketIO",
                dependencies: ["Starscream"],
                path: "./0-SocketIO/socket.io-client-swift/Source"),
        .target(name: "Tools",
                dependencies: ["Models"],
                path: "./1-Tools/Sources"),
        .target(name: "UITools",
                dependencies: ["Models", "Tools"],
                path: "./2-UITools/Sources"),
        .target(name: "ChatConversation",
                dependencies: ["Factory", "Tools", "Models", "UITools", "SocketIO"],
                path: "./3-ChatConversation/Sources"),
        .target(name: "Conversations",
                dependencies: ["Factory", "Tools", "Models", "UITools", "ChatConversation", "SocketIO"],
                path: "./3-Conversations/Sources"),
        .target(name: "Authentification",
                dependencies: ["Factory", "Tools", "Models", "Conversations", "UITools"],
                path: "./4-Authentification/Sources")
    ]
)
