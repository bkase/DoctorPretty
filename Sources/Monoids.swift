//
//  Monoids.swift
//  DoctorPretty
//
//  Created by Brandon Kase on 5/20/17.
//
//

// TODO: Remove this file when Algebra gets these definitions from Swiftz

import Foundation
import Algebra
import Operadics

extension Array: Additive {
    public static var zero: Array { return [] }
    
    public static func <>(x: Array, y: Array) -> Array {
        return x + y
    }
}
