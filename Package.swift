// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "iap-entitlement-engine",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "IAPEntitlementEnginee",
            targets: ["IAPEntitlementEngine"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.36.2"),
        .package(url: "https://github.com/vapor/apns.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.1.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "IAPEntitlementEngine",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "APNS", package: "apns"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver")
            ]
        ),
        .testTarget(
            name: "IAPEntitlementEngineTests",
            dependencies: ["IAPEntitlementEngine"]),
    ]
)
