//
//  DocMonoid.swift
//  DoctorPretty
//
//  Created by Brandon Kase on 5/20/17.
//
//

import Foundation
import protocol Algebra.Additive
import Operadics

extension Doc: Additive {
    static func <>(l: Doc, r: Doc) -> Doc {
        return .concat(l, r)
    }
    
    static var zero: Doc { return .empty }
}

