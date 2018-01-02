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
    
    func apply(_ _doc: SimpleDoc) -> SimpleDoc {
        var doc = _doc
        var next = self

        repeat {
        switch next {
        case .ret:
            return doc
        case let .wrapChar(c, cont):
            doc = SimpleDoc.char(c, doc)
            next = cont
            continue
        case let .wrapText(length, text, cont):
            doc = SimpleDoc.text(length: length, text, doc)
            next = cont
            continue
        case let .wrapLine(indent, cont):
            doc = SimpleDoc.line(indent: indent, doc)
            next = cont
            continue
        case let .checkFits(nesting, column, pageWidth, ribbonWidth, shorterLines, z, indent, rest, cont):
            if doc.fits(nesting: nesting, column: column, pageWidth: pageWidth, ribbonWidth: ribbonWidth) {
                next = cont
                continue
            } else {
                return Doc.best(ribbonChars: ribbonWidth, pageWidth: pageWidth, currNesting: nesting, currColumn: column, z: z, indentationDocs: .Cons((indent, shorterLines), rest), k: cont)
            }
        }
        } while (true)
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
        ribbonChars _ribbonChars: RibbonWidth,
        pageWidth _pageWidth: Width,
        currNesting _currNesting: IndentLevel,
        currColumn _currColumn: ColumnCount,
        // This parameter is only used during annotation, but I'm
        // keeping it here to simplify adding the annotation case
        // in doc if that ever happens
        z _z: @escaping (IndentLevel, ColumnCount) -> SimpleDoc,
        indentationDocs _indentationDocs: Docs,
        k _k: Cont
    ) -> SimpleDoc {
        var ribbonChars = _ribbonChars
        var pageWidth = _pageWidth
        var currNesting = _currNesting
        var currColumn = _currColumn
        var z = _z
        var indentationDocs = _indentationDocs
        var k = _k
        
        repeat {
        switch indentationDocs {
        case .Nil: return k.apply(z(currNesting, currColumn))
        case let .Cons(head, rest):
            let (indent, doc) = head
            
            switch doc {
            case .empty:
                indentationDocs = rest
                continue
            case let ._char(c):
                currColumn = currColumn + 1
                k = .wrapChar(c, k)
                indentationDocs = rest
                continue
            case let ._text(length, str):
                currColumn = currColumn + length
                k = .wrapText(length: length, str, k)
                indentationDocs = rest
                continue
            case ._line:
                currColumn = indent
                currNesting = indent
                k = .wrapLine(indent: indent, k)
                indentationDocs = rest
                continue
            case let .flatAlt(primary, whenFlattened: _):
                indentationDocs = .Cons((indent, primary), rest)
                continue
            case let .concat(d1, d2):
                indentationDocs = .Cons((indent, d1), .Cons((indent, d2), rest))
                continue
            case let .nest(indent_, d):
                let newIndent = indent + indent_
                indentationDocs = .Cons((newIndent, d), rest)
                continue
            case let .union(longerLines, shorterLines):
                indentationDocs = .Cons((indent, longerLines), rest)
                k = .checkFits(nesting: currNesting, column: currColumn, pageWidth: pageWidth, ribbonWidth: ribbonChars, shorterLines: shorterLines, z: z, indent: indent, rest: rest, k)
                continue
            case let .column(f):
                indentationDocs = .Cons((indent, f(currColumn)), rest)
                continue
            case let .nesting(f):
                indentationDocs = .Cons((indent, f(indent)), rest)
                continue
            case let .columns(f):
                indentationDocs = .Cons((indent, f(.some(pageWidth))), rest)
                continue
            case let .ribbon(f):
                indentationDocs = .Cons((indent, f(.some(ribbonChars))), rest)
                continue
            }
        }
        } while (true)
    }
    
    func renderFits(ribbonFrac: Float, pageWidth: Width) -> SimpleDoc {
        let rounded = round(Float(pageWidth) * ribbonFrac)
        let ribbonChars: RibbonWidth = max(0, min(pageWidth, Width(rounded)))

        return Doc.best(ribbonChars: ribbonChars, pageWidth: pageWidth, currNesting: 0, currColumn: 0, z: { _, _ in SimpleDoc.empty }, indentationDocs: .Cons((0, self), .Nil), k: .ret)
    }
}
