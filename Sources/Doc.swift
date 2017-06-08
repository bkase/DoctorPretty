import Swiftx
import Operadics

public typealias Width = Int
// TODO: What does this int mean, really
public typealias ColumnCount = Int
public typealias IndentLevel = Int
/// The ribbon width is the maximal amount of non-indentation characters on a line
public typealias RibbonWidth = Int

public indirect enum Doc {
    case empty
    /// Invariant: char != '\n'
    case _char(Character)
    /// Invariant: '\n' ∉ text
    case _text(length: Int, String)
    case _line
    /// If flattened then whenFlattened else primary
    case flatAlt(primary: Doc, whenFlattened: Doc)
    case concat(Doc, Doc)
    /// Renders Doc with an increased indent level
    /// Note: This only affects line after the first newline
    case nest(IndentLevel, Doc)
    /// Invariant: longerLines.firstLine.count >= shorterLines.firstLine.count
    case union(longerLines: Doc, shorterLines: Doc) 
    // No support for Annotations for now, I don't think Swift's generics would take kindly to a Doc<A>
    // case annotate(A, Doc)
    case column((ColumnCount) -> Doc)
    case nesting((IndentLevel) -> Doc)
    case columns((ColumnCount?) -> Doc)
    case ribbon((RibbonWidth?) -> Doc)
    
    public static func char(_ c: Character) -> Doc {
        return c == "\n" ? ._line : ._char(c)
    }
    
    public static func text(_ str: String) -> Doc {
        return str == "" ? .empty : ._text(length: str.characters.count, str)
    }
    
    public static var line: Doc {
        return .flatAlt(primary: ._line, whenFlattened: .space)
    }
    
    public static var linebreak: Doc {
        return .flatAlt(primary: ._line, whenFlattened: .zero)
    }
    
    public static var hardline: Doc {
        return ._line
    }
    
    /// Used to specify alternative layouts
    /// `doc.grouped` removes all line breaks in `doc`. The resulting line
    /// is added if it fits on the page. If it doesn't, it's rendered as is
    public var grouped: Doc {
        return .union(longerLines: flattened, shorterLines: self)
    }
    
    public var flattened: Doc {
        switch self {
        case .empty: return self
        case ._char(_): return self
        case ._text(length: _, _): return self
        case ._line: return self
        case let .flatAlt(_, whenFlattened): return whenFlattened
        case let .concat(x, y): return .concat(x.flattened, y.flattened)
        case let .nest(i, x): return .nest(i, x.flattened)
        case let .union(x, _): return x.flattened
        case let .column(f): return .column { f($0).flattened }
        case let .nesting(f): return .nesting { f($0).flattened }
        case let .columns(f): return .columns { f($0).flattened }
        case let .ribbon(f): return .ribbon { f($0).flattened }
        }
    }
}

