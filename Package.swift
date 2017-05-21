// swift-tools-version:3.1

import PackageDescription
import Foundation

// HACK from https://github.com/ReactiveCocoa/ReactiveSwift/blob/master/Package.swift
var isSwiftPMTest: Bool {
    return ProcessInfo.processInfo.environment["SWIFTPM_TEST_DoctorPretty"] == "YES"
}

let package = Package(
    name: "DoctorPretty",
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/typelift/Algebra.git", majorVersion: 0, minor: 2),
        .Package(url: "https://github.com/bkase/Swiftx.git", majorVersion: 0, minor: 5)
    ] + (isSwiftPMTest ?
      [.Package(url: "https://github.com/typelift/SwiftCheck.git", versions: Version(0,6,0)..<Version(1,0,0))] :
      [])

)
