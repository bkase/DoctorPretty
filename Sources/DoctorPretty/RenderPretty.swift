//
//  RenderPretty.swift
//  DoctorPretty
//
//  Created by Brandon Kase on 5/20/17.
//
//

import Foundation

typealias CompareStrategy = (IndentLevel, ColumnCount, Width, RibbonWidth) -> (SimpleDoc, () -> SimpleDoc) -> SimpleDoc

indirect enum List<T> {
    case Nil
    case Cons(T, List<T>)
}

// TODO: Tune this datastructure to increase render performance
//       Good properties:
//              fast prepend
//              fast (head, rest) decomposition
//              shared substructure
//       The obvious choice is a linked list, but maybe a clever sequence
//       could be better. Also, perhaps not using the enum-list will speed
//       things up more.
typealias Docs = List<(Int, Doc)>

extension SimpleDoc {
    func fits(nesting: IndentLevel, column: ColumnCount, pageWidth: Width, ribbonWidth: RibbonWidth) -> Bool {
        let prefix = min(nesting, column)
        let w = min(pageWidth - column, ribbonWidth - column + nesting)
        
        var _w = w
        var _doc = self
        
        while true {
            switch (_w, _doc) {
            case (_, _) where _w < 0:
                return false
                
            case (_, .empty):
                return true
                
            case let (w, .char(_, x)):
                _w = w - 1
                _doc = x
                continue
                
            case let (w, .text(length, _, x)):
                _w = w - length
                _doc = x
                continue
                
            case (_, _):
                return true
            }
        }
    }
}

indirect enum Cont {
    case ret
    case wrapChar(Character, Cont)
    case wrapText(length: Int, String, Cont)
    case wrapLine(indent: Int, Cont)
    case checkFits(nesting: IndentLevel, column: ColumnCount, pageWidth: Width, ribbonWidth: RibbonWidth, shorterLines: Doc,             z: (IndentLevel, ColumnCount) -> SimpleDoc, indent: Int, rest: Docs, Cont)
    
    func apply(_ doc: SimpleDoc) -> SimpleDoc {
        switch self {
        case .ret:
            return doc
        case let .wrapChar(c, cont):
            return cont.apply(SimpleDoc.char(c, doc))
        case let .wrapText(length, text, cont):
            return cont.apply(SimpleDoc.text(length: length, text, doc))
        case let .wrapLine(indent, cont):
            return cont.apply(SimpleDoc.line(indent: indent, doc))
        case let .checkFits(nesting, column, pageWidth, ribbonWidth, shorterLines, z, indent, rest, cont):
            if doc.fits(nesting: nesting, column: column, pageWidth: pageWidth, ribbonWidth: ribbonWidth) {
                return cont.apply(doc)
            } else {
                return Doc.best(ribbonChars: ribbonWidth, pageWidth: pageWidth, currNesting: nesting, currColumn: column, z: z, indentationDocs: .Cons((indent, shorterLines), rest), k: cont)
            }
        }
    }
}

extension Doc {
    public func renderPrettyDefault() -> SimpleDoc {
        return renderPretty(ribbonFrac: 0.4, pageWidth: 100)
    }
    
    public func renderPretty(ribbonFrac: Float, pageWidth: Width) -> SimpleDoc {
        return renderFits(ribbonFrac: ribbonFrac, pageWidth: pageWidth)
    }
    
    static func best(
        ribbonChars: RibbonWidth,
        pageWidth: Width,
        currNesting: IndentLevel,
        currColumn: ColumnCount,
        // This parameter is only used during annotation, but I'm
        // keeping it here to simplify adding the annotation case
        // in doc if that ever happens
        z: @escaping (IndentLevel, ColumnCount) -> SimpleDoc,
        indentationDocs: Docs,
        k: Cont
    ) -> SimpleDoc {
        switch indentationDocs {
        case .Nil: return k.apply(z(currNesting, currColumn))
        case let .Cons(head, rest):
            let (indent, doc) = head
            
            switch doc {
            case .empty:
                return best(ribbonChars: ribbonChars, pageWidth: pageWidth, currNesting: currNesting, currColumn: currColumn, z: z, indentationDocs: rest, k: k)
            case let ._char(c):
                let newColumn = currColumn + 1
                return best(ribbonChars: ribbonChars, pageWidth: pageWidth, currNesting: currNesting, currColumn: newColumn, z: z, indentationDocs: rest, k: Cont.wrapChar(c, k))
            case let ._text(length, str):
                let newColumn = currColumn + length
                return best(ribbonChars: ribbonChars, pageWidth: pageWidth, currNesting: currNesting, currColumn: newColumn, z: z, indentationDocs: rest, k: .wrapText(length: length, str, k))
            case ._line:
                return best(ribbonChars: ribbonChars, pageWidth: pageWidth, currNesting: indent, currColumn: indent, z: z, indentationDocs: rest, k: .wrapLine(indent: indent, k))
            case let .flatAlt(primary, whenFlattened: _):
                return best(ribbonChars: ribbonChars, pageWidth: pageWidth, currNesting: currNesting, currColumn: currColumn, z: z, indentationDocs: .Cons((indent, primary), rest), k: k)
            case let .concat(d1, d2):
                return best(ribbonChars: ribbonChars, pageWidth: pageWidth, currNesting: currNesting, currColumn: currColumn, z: z, indentationDocs: .Cons((indent, d1), .Cons((indent, d2), rest)), k: k)
            case let .nest(indent_, d):
                let newIndent = indent + indent_
                return best(ribbonChars: ribbonChars, pageWidth: pageWidth, currNesting: currNesting, currColumn: currColumn, z: z, indentationDocs: .Cons((newIndent, d), rest), k: k)
            case let .union(longerLines, shorterLines):
                
                return best(ribbonChars: ribbonChars, pageWidth: pageWidth, currNesting: currNesting, currColumn: currColumn, z: z, indentationDocs: .Cons((indent, longerLines), rest), k: .checkFits(nesting: currNesting, column: currColumn, pageWidth: pageWidth, ribbonWidth: ribbonChars, shorterLines: shorterLines, z: z, indent: indent, rest: rest, k))
            case let .column(f):
                return best(ribbonChars: ribbonChars, pageWidth: pageWidth, currNesting: currNesting, currColumn: currColumn, z: z, indentationDocs: .Cons((indent, f(currColumn)), rest), k: k)
            case let .nesting(f):
                return best(ribbonChars: ribbonChars, pageWidth: pageWidth, currNesting: currNesting, currColumn: currColumn, z: z, indentationDocs: .Cons((indent, f(indent)), rest), k: k)
            case let .columns(f):
                return best(ribbonChars: ribbonChars, pageWidth: pageWidth, currNesting: currNesting, currColumn: currColumn, z: z, indentationDocs: .Cons((indent, f(.some(pageWidth))), rest), k: k)
            case let .ribbon(f):
                return best(ribbonChars: ribbonChars, pageWidth: pageWidth, currNesting: currNesting, currColumn: currColumn, z: z, indentationDocs: .Cons((indent, f(.some(ribbonChars))), rest), k: k)
            }
        }
    }
    
    func renderFits(ribbonFrac: Float, pageWidth: Width) -> SimpleDoc {
        let rounded = round(Float(pageWidth) * ribbonFrac)
        let ribbonChars: RibbonWidth = max(0, min(pageWidth, Width(rounded)))

        return Doc.best(ribbonChars: ribbonChars, pageWidth: pageWidth, currNesting: 0, currColumn: 0, z: { _, _ in SimpleDoc.empty }, indentationDocs: .Cons((0, self), .Nil), k: .ret)
    }
}
