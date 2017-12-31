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
    public func enclose(left: Doc, right: Doc) -> Doc {
        return left <> self <> right
    }
    
    public var squotes: Doc {
        return enclose(left: .squote, right: .squote)
    }
    
    public var dquotes: Doc {
        return enclose(left: .dquote, right: .dquote)
    }
    
    public var braces: Doc {
        return enclose(left: .lbrace, right: .rbrace)
    }
    
    public var parens: Doc {
        return enclose(left: .lparen, right: .rparen)
    }
    
    public var angles: Doc {
        return enclose(left: .langle, right: .rangle)
    }
    
    public var brackets: Doc {
        return enclose(left: .lbracket, right: .rbracket)
    }
    
    public static let squote: Doc = .char("'")
    public static let dquote: Doc = .char("\"")
    public static let lbrace: Doc = .char("{")
    public static let rbrace: Doc = .char("}")
    public static let lparen: Doc = .char("(")
    public static let rparen: Doc = .char(")")
    public static let langle: Doc = .char("<")
    public static let rangle: Doc = .char(">")
    public static let lbracket: Doc = .char("[")
    public static let rbracket: Doc = .char("]")
    
    public static let space: Doc = .char(" ")
    public static let dot: Doc = .char(".")
    public static let comma: Doc = .char(",")
    public static let semi: Doc = .char(";")
    public static let backslash: Doc = .char("\\")
    public static let equals: Doc = .char("=")
}
