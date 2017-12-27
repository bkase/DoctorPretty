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
    public static func <+>(x: Doc, y: Doc) -> Doc {
        return x <> space <> y
    }
    
    /// Concats x and y with a space in between if it fits
    /// Otherwise puts a line
    public static func <%>(x: Doc, y: Doc) -> Doc {
        return x <> softline <> y
    }
    
    /// Behaves like `space` if the output fits the page
    /// Otherwise it behaves like line
    public static var softline: Doc {
        return Doc.line.grouped
    }
    
    /// Concats x and y together if it fits
    /// Otherwise puts a line in between
    public static func <%%>(x: Doc, y: Doc) -> Doc {
        return x <> softbreak <> y
    }
    
    /// Behaves like `zero` if the output fits the page
    /// Otherwise it behaves like line
    public static var softbreak: Doc {
        return Doc.linebreak.grouped
    }
    
    /// Puts a line between x and y that can be flattened to a space
    public static func <&>(x: Doc, y: Doc) -> Doc {
        return x <> .line <> y
    }
    
    /// Puts a line between x and y that can be flattened with no space
    public static func <&&>(x: Doc, y: Doc) -> Doc {
        return x <> .linebreak <> y
    }
}

extension Sequence where Iterator.Element == Doc {
    /// Concat all horizontally if it fits, but if not
    /// all vertical
    public func sep() -> Doc {
        return vsep().grouped
    }
    
    /// Concats all horizontally until end of page
    /// then puts a line and repeats
    public func fillSep() -> Doc {
        return fold(combineDocs: <%>)
    }
    
    /// Concats all horizontally with spaces in between
    public func hsep() -> Doc {
        return fold(combineDocs: <+>)
    }
    
    /// Concats all vertically, if a group undoes, concat with space
    public func vsep() -> Doc {
        return fold(combineDocs: <&>)
    }
    
    /// Concats all horizontally no spaces if fits
    /// Otherwise all vertically
    public func cat() -> Doc {
        return vcat().grouped
    }
    
    /// Concats all horizontally until end of page
    /// then puts a linebreak and repeats
    public func fillCat() -> Doc {
        return fold(combineDocs: <%%>)
    }
    
    /// Concats all horizontally with no spaces
    public func hcat() -> Doc {
        return fold(combineDocs: <>)
    }
    
    /// Concats all vertically, if a group undoes, concat with no space
    public func vcat() -> Doc {
        return fold(combineDocs: <&&>)
    }
    
    public func fold(combineDocs: (Doc, Doc) -> Doc) -> Doc {
        var iter = makeIterator()
        if let first = iter.next() {
           return IteratorSequence(iter).reduce(first, combineDocs)
        } else {
            return Doc.zero
        }
    }
}
