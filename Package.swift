// swift-tools-version: 5.9
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
                "SetupCoreDataAttributes"
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
            name: "CoreDataAttributesConvenienceSetupMacro",
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
            name: "SetupCoreDataAttributes",
            dependencies: ["CoreDataAttributesConvenienceSetupMacro"]
        ),
        .testTarget(
            name: "SetupCoreDataAttributesTests",
            dependencies: [
                "CoreDataAttributesConvenienceSetupMacro",
                .product(name: "MacroTesting", package: "swift-macro-testing"),
            ]
        )
    ]
)
