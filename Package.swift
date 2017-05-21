// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "DoctorPretty",
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/bkase/Algebra.git", majorVersion: 0, minor: 2),
        .Package(url: "https://github.com/bkase/Swiftx.git", majorVersion: 0, minor: 5)
    ]
)
