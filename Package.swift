// swift-tools-version: 6.0
import CompilerPluginSupport
import PackageDescription

internal let package = Package(
    name: "FoundationMacros",
    platforms: [.iOS(.v17), .macOS(.v10_15)],
    products: [
        .library(
            name: "FoundationMacros",
            targets: [
                "Init",
                "SetupModelAttributes"
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", .upToNextMajor(from: "510.0.1")),
        .package(
            url: "https://github.com/pointfreeco/swift-macro-testing.git",
            .upToNextMajor(from: "0.3.0")
        )
    ],
    targets: [
        .macro(
            name: "InitMacro",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .macro(
            name: "SetupModelAttributesMacro",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "Init",
            dependencies: ["InitMacro"]
        ),
        .target(
            name: "SetupModelAttributes",
            dependencies: ["SetupModelAttributesMacro"]
        ),
        .testTarget(
            name: "SetupModelAttributesTests",
            dependencies: [
                "SetupModelAttributesMacro",
                .product(name: "MacroTesting", package: "swift-macro-testing"),
            ]
        )
    ]
)
