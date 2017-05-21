//
//  Alignment.swift
//  DoctorPretty
//
//  Created by Brandon Kase on 5/20/17.
//
//

import Foundation
import Operadics

// Alignment and Indentation
extension Doc {
    /// Indent all lines of the doc by `i`
    func indent(_ i: IndentLevel) -> Doc {
        return (.text(spaces(i)) <> self).hang(i)
    }
    
    /// Hanging indentation
    func hang(_ i: IndentLevel) -> Doc {
        return (Doc.nest(i, self)).align()
    }
    
    /// Align this document with the nesting level set to the current column
    func align() -> Doc {
        return .column { k in
            .nesting { i in .nest(k - i, self) }
        }
    }
}

