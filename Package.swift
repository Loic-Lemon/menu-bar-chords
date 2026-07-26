// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "Chords",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .target(
            name: "ChordsLib",
            path: "Sources/ChordsLib",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .executableTarget(
            name: "Chords",
            dependencies: ["ChordsLib"],
            path: "Sources/Chords"
        ),
        // .testTarget(
        //     name: "ChordsTests",
        //     dependencies: ["ChordsLib"],
        //     path: "Tests"
        // )
    ]
)
