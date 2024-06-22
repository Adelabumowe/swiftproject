// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "SampleSwiftProject",
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/sqlite-kit.git", from: "4.0.0"),
    ],
    targets: [
        .target(
            name: "SampleSwiftProject",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "SQLiteKit", package: "sqlite-kit"),
            ]
        ),
    ]
)
