// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ReelsVideoPlayer",
    platforms: [.iOS(.v17)], // Define minimum iOS version
    products: [
        .library(
            name: "ReelsVideoPlayer",
            targets: ["ReelsVideoPlayer"]
        ),
    ],
    targets: [
        .target(
            name: "ReelsVideoPlayer"
        )
    ]
)
