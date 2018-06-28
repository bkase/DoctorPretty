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

extension Doc {
    public func renderPrettyDefault() -> SimpleDoc {
        return renderPretty(ribbonFrac: 0.4, pageWidth: 100)
    }
    
    public func renderPretty(ribbonFrac: Float, pageWidth: Width) -> SimpleDoc {
        return renderFits(compareStrategy: Doc.nicest1, ribbonFrac: ribbonFrac, pageWidth: pageWidth)
    }
    
    func renderFits(compareStrategy: @escaping CompareStrategy, ribbonFrac: Float, pageWidth: Width) -> SimpleDoc {
        let rounded = round(Float(pageWidth) * ribbonFrac)
        let ribbonChars: RibbonWidth = max(0, min(pageWidth, Width(rounded)))

        func best(
            currNesting: IndentLevel,
            currColumn: ColumnCount,
            // This parameter is only used during annotation, but I'm
            // keeping it here to simplify adding the annotation case
            // in doc if that ever happens
            z: @escaping (IndentLevel, ColumnCount) -> SimpleDoc,
            indentationDocs: Docs
        ) -> SimpleDoc {
            switch indentationDocs {
            case .Nil: return z(currNesting, currColumn)
            case let .Cons(head, rest):
                let (indent, doc) = head
                
                switch doc {
                case .empty:
                    return best(currNesting: currNesting, currColumn: currColumn, z: z, indentationDocs: rest)
                case let ._char(c):
                    let newColumn = currColumn + 1
                    return SimpleDoc.char(c, best(currNesting: currNesting, currColumn: newColumn, z: z, indentationDocs: rest))
                case let ._text(length, str):
                    let newColumn = currColumn + length
                    return SimpleDoc.text(length: length, str, best(currNesting: currNesting, currColumn: newColumn, z: z, indentationDocs: rest))
                case ._line:
                    return SimpleDoc.line(indent: indent, { best(currNesting: indent, currColumn: indent, z: z, indentationDocs: rest) })
                case let .flatAlt(primary, whenFlattened: _):
                    return best(currNesting: currNesting, currColumn: currColumn, z: z, indentationDocs: .Cons((indent, primary), rest))
                case let .concat(d1, d2):
                    return best(currNesting: currNesting, currColumn: currColumn, z: z, indentationDocs: .Cons((indent, d1), .Cons((indent, d2), rest)))
                case let .nest(indent_, d):
                    let newIndent = indent + indent_
                    return best(currNesting: currNesting, currColumn: currColumn, z: z, indentationDocs: .Cons((newIndent, d), rest))
                case let .union(longerLines, shorterLines):
                    return compareStrategy(
                        currNesting,
                        currColumn,
                        pageWidth,
                        ribbonChars
                    )(
                        best(currNesting: currNesting, currColumn: currColumn, z: z, indentationDocs: .Cons((indent, longerLines), rest)),
                        /// Laziness is needed here to prevent horrible performance!
                        { () in best(currNesting: currNesting, currColumn: currColumn, z: z, indentationDocs: .Cons((indent, shorterLines), rest)) }
                    )
                case let .column(f):
                    return best(currNesting: currNesting, currColumn: currColumn, z: z, indentationDocs: .Cons((indent, f(currColumn)), rest))
                case let .nesting(f):
                    return best(currNesting: currNesting, currColumn: currColumn, z: z, indentationDocs: .Cons((indent, f(indent)), rest))
                case let .columns(f):
                    return best(currNesting: currNesting, currColumn: currColumn, z: z, indentationDocs: .Cons((indent, f(.some(pageWidth))), rest))
                case let .ribbon(f):
                    return best(currNesting: currNesting, currColumn: currColumn, z: z, indentationDocs: .Cons((indent, f(.some(ribbonChars))), rest))
                }
            }
        }
        
        return best(currNesting: 0, currColumn: 0, z: { _, _ in SimpleDoc.empty }, indentationDocs: .Cons((0, self), .Nil))
    }
    
    /// Compares the first two lines of the documents
    static func nicest1(nesting: IndentLevel, column: ColumnCount, pageWidth: Width, ribbonWidth: RibbonWidth) -> (SimpleDoc, () -> SimpleDoc) -> SimpleDoc {
        return { d1, d2 in
            let wid = min(pageWidth - column, ribbonWidth - column + nesting)

            func fits(prefix: Int, w: Int, doc: SimpleDoc) -> Bool {
                var _w = w
                var _doc = doc

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

            if fits(prefix: min(nesting, column), w: wid, doc: d1) {
                return d1
            } else {
                return d2()
            }
        }
    }
}
