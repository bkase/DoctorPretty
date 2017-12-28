//
//  Enclosed.swift
//  DoctorPretty
//
//  Created by Brandon Kase on 5/21/17.
//
//

import Foundation
import Operadics

extension BidirectionalCollection where Iterator.Element == Doc, IndexDistance == Int {
    
    /// Intersperses punctuation inside docs
    public func punctuate(with punctuation: Doc) -> [Doc] {
        if let d = first {
            return [d] + self.dropFirst().reduce(into: [Doc]()) { acc, d2 in
                acc.append(punctuation)
                acc.append(d2)
            }
        } else {
            return []
        }
    }
    
    /// Enclose left right around docs interspersed with separator
    /// Tries horizontal, then tries vertical
    /// Indenting each element in the list by the indent level
    /// Ex:
    ///   enclose(left: [, right: ], separator: comma, indent: 4)
    ///     let x = [foo, bar, baz]
    ///   or
    ///     let x = [
    ///         foo,
    ///         bar,
    ///         baz
    ///     ]
    /// Note: The Haskell version sticks the separator at the front
    public func enclose(left: Doc, right: Doc, separator: Doc, indent: IndentLevel) -> Doc {
        if count == 0 {
            return left <> right
        }
        
        let seps = repeatElement(separator, count: count-1)
        let last = self[self.index(before: self.endIndex)]
        let punctuated = zip(self.dropLast(), seps).map(<>) <> [last]
        return (
            .nest(indent,
                  left <&&> punctuated.sep()
                ) <&&> right
            ).grouped
    }
    
    /// See @enclose
    public func list(indent: IndentLevel) -> Doc {
        return enclose(left: Doc.lbracket, right: Doc.rbracket, separator: Doc.comma, indent: indent)
    }
    
    /// See @enclose
    public func tupled(indent: IndentLevel) -> Doc {
        return enclose(left: Doc.lparen, right: Doc.rparen, separator: Doc.comma, indent: indent)
    }
    
    /// See @enclose
    public func semiBraces(indent: IndentLevel) -> Doc {
        return enclose(left: Doc.lbrace, right: Doc.rbrace, separator: Doc.semi, indent: indent)
    }
}

