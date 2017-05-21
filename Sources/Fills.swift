//
//  Fills.swift
//  DoctorPretty
//
//  Created by Brandon Kase on 5/20/17.
//
//

import Foundation
import Operadics

extension Doc {
    /// Render doc then fill until width == i
    /// If too large, put in a line-break and then pad
    func fillBreak(_ i: IndentLevel) -> Doc {
        return width { w in w > i ? .nest(i, .linebreak) : .text(spaces(i - w)) }
    }
    
    /// Render doc then fill until width == i
    func fill(_ i: IndentLevel) -> Doc {
        return width { w in w >= i ? .zero : .text(spaces(i - w)) }
    }
    
    func width(_ f: @escaping (IndentLevel) -> Doc) -> Doc {
        return .column { k1 in self <> .column { k2 in f(k2 - k1) } }
    }
}
