//
//  SimpleDoc.swift
//  DoctorPretty
//
//  Created by Brandon Kase on 5/20/17.
//
//

import Foundation
import Algebra
import Operadics

/// A post-render IR that is used to dump to a String or a File or process
/// in some other way
public indirect enum SimpleDoc {
    case empty
    case char(Character, SimpleDoc)
    case text(length: Int, String, SimpleDoc)
    case line(indent: Int, () -> SimpleDoc)
    
    public func display<M: Additive>(readString: (String) -> M) -> M {
        switch self {
        case .empty: return M.zero
        case let .char(c, rest): return readString(String(c)) <> rest.display(readString: readString)
        case let .text(_, s, rest): return readString(s) <> rest.display(readString: readString)
        case let .line(indent, rest):
            return readString("\n" + spaces(indent)) <> rest().display(readString: readString)
        }
    }
    
    public func displayString() -> String {
        return display{ [$0] }.joined()
    }
}
