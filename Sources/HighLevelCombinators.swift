//
//  HighLevelCombinators.swift
//  DoctorPretty
//
//  Created by Brandon Kase on 5/20/17.
//
//

import Foundation
import Operadics

infix operator <%>: AdditionPrecedence
infix operator <%%>: AdditionPrecedence
infix operator <&>: AdditionPrecedence
infix operator <&&>: AdditionPrecedence

extension Doc {
    /// Concats x and y with a space in between
    static func <+>(x: Doc, y: Doc) -> Doc {
        return x <> space <> y
    }
    
    /// Concats x and y with a space in between if it fits
    /// Otherwise puts a line
    static func <%>(x: Doc, y: Doc) -> Doc {
        return x <> softline <> y
    }
    
    /// Behaves like `space` if the output fits the page
    /// Otherwise it behaves like line
    static var softline: Doc {
        return Doc.line.grouped
    }
    
    /// Concats x and y together if it fits
    /// Otherwise puts a line in between
    static func <%%>(x: Doc, y: Doc) -> Doc {
        return x <> softbreak <> y
    }
    
    /// Behaves like `zero` if the output fits the page
    /// Otherwise it behaves like line
    static var softbreak: Doc {
        return Doc.linebreak.grouped
    }
    
    /// Puts a line between x and y that can be flattened to a space
    static func <&>(x: Doc, y: Doc) -> Doc {
        return x <> .line <> y
    }
    
    /// Puts a line between x and y that can be flattened with no space
    static func <&&>(x: Doc, y: Doc) -> Doc {
        return x <> .linebreak <> y
    }
}

extension Sequence where Iterator.Element == Doc {
    /// Concat all horizontally if it fits, but if not
    /// all vertical
    func sep() -> Doc {
        return vsep().grouped
    }
    
    /// Concats all horizontally until end of page
    /// then puts a line and repeats
    func fillSep() -> Doc {
        return fold(combineDocs: <%>)
    }
    
    /// Concats all horizontally with spaces in between
    func hsep() -> Doc {
        return fold(combineDocs: <+>)
    }
    
    /// Concats all vertically, if a group undoes, concat with space
    func vsep() -> Doc {
        return fold(combineDocs: <&>)
    }
    
    /// Concats all horizontally no spaces if fits
    /// Otherwise all vertically
    func cat() -> Doc {
        return vcat().grouped
    }
    
    /// Concats all horizontally until end of page
    /// then puts a linebreak and repeats
    func fillCat() -> Doc {
        return fold(combineDocs: <%%>)
    }
    
    /// Concats all horizontally with no spaces
    func hcat() -> Doc {
        return fold(combineDocs: <>)
    }
    
    /// Concats all vertically, if a group undoes, concat with no space
    func vcat() -> Doc {
        return fold(combineDocs: <&&>)
    }
    
    func fold(combineDocs: (Doc, Doc) -> Doc) -> Doc {
        var iter = makeIterator()
        if let first = iter.next() {
           return IteratorSequence(iter).reduce(first, combineDocs)
        } else {
            return Doc.zero
        }
    }
}
