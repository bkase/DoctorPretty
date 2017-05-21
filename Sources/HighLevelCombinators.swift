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
    
    /// Puts a line between x and y that can be flattened
    static func <&>(x: Doc, y: Doc) -> Doc {
        return x <> .line <> y
    }
    
    /// Puts a line between x and y undconditionally
    static func <&&>(x: Doc, y: Doc) -> Doc {
        return x <> .linebreak <> y
    }
}

extension Doc {
    /// Concat all horizontally if it fits, but if not
    /// all vertical
    static func sep<S: Sequence>(_ docs: S) -> Doc where S.Iterator.Element == Doc {
        return vsep(docs).grouped
    }
    
    /// Concats all horizontally until end of page
    /// then puts a line and repeats
    static func fillSep<S: Sequence>(_ docs: S) -> Doc where S.Iterator.Element == Doc {
        return fold(docs: docs, combine: <%>)
    }
    
    /// Concats all horizontally with spaces in between
    static func hsep<S: Sequence>(_ docs: S) -> Doc where S.Iterator.Element == Doc {
        return fold(docs: docs, combine: <+>)
    }
    
    /// Concats all vertically, if a group undoes, concat with space
    static func vsep<S: Sequence>(_ docs: S) -> Doc where S.Iterator.Element == Doc {
        return fold(docs: docs, combine: <&>)
    }
    
    /// Concats all horizontally no spaces if fits
    /// Otherwise all vertically
    static func cat<S: Sequence>(_ docs: S) -> Doc where S.Iterator.Element == Doc {
        return vcat(docs).grouped
    }
    
    /// Concats all horizontally until end of page
    /// then puts a linebreak and repeats
    static func fillCat<S: Sequence>(_ docs: S) -> Doc where S.Iterator.Element == Doc {
        return fold(docs: docs, combine: <%%>)
    }
    
    /// Concats all horizontally with no spaces
    static func hcat<S: Sequence>(_ docs: S) -> Doc where S.Iterator.Element == Doc {
        return fold(docs: docs, combine: <>)
    }
    
    /// Concats all vertically, if a group undoes, concat with no space
    static func vcat<S: Sequence>(_ docs: S) -> Doc where S.Iterator.Element == Doc {
        return fold(docs: docs, combine: <&&>)
    }
    
    static func fold<S: Sequence>(docs: S, combine: (Doc, Doc) -> Doc) -> Doc where S.Iterator.Element == Doc {
        return docs.reduce(Doc.zero, <>)
    }
}
