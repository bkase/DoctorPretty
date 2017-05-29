//
//  Atoms.swift
//  DoctorPretty
//
//  Created by Brandon Kase on 5/20/17.
//
//

import Foundation
import Operadics

extension Doc {
    /// Enclose a doc between left and right
    func enclose(left: Doc, right: Doc) -> Doc {
        return left <> self <> right
    }
    
    var squotes: Doc {
        return enclose(left: .squote, right: .squote)
    }
    
    var dquotes: Doc {
        return enclose(left: .dquote, right: .dquote)
    }
    
    var braces: Doc {
        return enclose(left: .lbrace, right: .rbrace)
    }
    
    var parens: Doc {
        return enclose(left: .lparen, right: .rparen)
    }
    
    var angles: Doc {
        return enclose(left: .langle, right: .rangle)
    }
    
    var brackets: Doc {
        return enclose(left: .lbracket, right: .rbracket)
    }
    
    static let squote: Doc = .char("'")
    static let dquote: Doc = .char("\"")
    static let lbrace: Doc = .char("{")
    static let rbrace: Doc = .char("}")
    static let lparen: Doc = .char("(")
    static let rparen: Doc = .char(")")
    static let langle: Doc = .char("<")
    static let rangle: Doc = .char(">")
    static let lbracket: Doc = .char("[")
    static let rbracket: Doc = .char("]")
    
    static let space: Doc = .char(" ")
    static let dot: Doc = .char(".")
    static let comma: Doc = .char(",")
    static let semi: Doc = .char(";")
    static let backslash: Doc = .char("\\")
    static let equals: Doc = .char("=")
}
