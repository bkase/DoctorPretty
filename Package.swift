// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "DoctorPretty",
    products: [
        .library(
            name: "DoctorPretty",
            targets: ["DoctorPretty"]),
    ],
    dependencies: [
        .package(url: "https://github.com/typelift/Algebra.git", .exact("0.2.0")),
        .package(url: "https://github.com/typelift/Swiftx.git", .exact("0.6.0")),
        .package(url: "https://github.com/typelift/SwiftCheck.git", .exact("0.9.1"))
    ],
    targets: [
        .target(name: "DoctorPretty", dependencies: ["Algebra", "Swiftx"]),
        .testTarget(name: "DoctorPrettyTests", dependencies: ["DoctorPretty", "SwiftCheck"]),
        ]
)
