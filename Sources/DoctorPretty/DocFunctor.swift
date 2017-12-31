//
//  DocFunctor.swift
//  DoctorPretty
//
//  Created by Brandon Kase on 5/20/17.
//
//

// If we decide to add annotation support and make a Doc<A>
/*extension Doc /*: Functor*/ {
    func fmap<B>(_ f: @escaping (A) -> B) -> Doc<B> {
        switch self {
        case .empty: return .empty
        case let ._char(c): return ._char(c)
        case let ._text(length, str): return ._text(length: length, str)
        case ._line: return ._line
        case let .flatAlt(primary, whenFlattened):
            return .flatAlt(primary: primary.fmap(f), whenFlattened: whenFlattened.fmap(f))
        case let .cat(d1, d2):
            return .cat(d1.fmap(f), d2.fmap(f))
        case let .nest(i, d):
            return .nest(i, d.fmap(f))
        case let .union(longerLines, shorterLines):
            return .union(longerLines: longerLines.fmap(f), shorterLines: shorterLines.fmap(f))
        case let .annotate(a, d):
            return .annotate(f(a), d.fmap(f))
        case let .column(g):
            return .column { g($0).fmap(f) }
        case let .nesting(g):
            return .nesting { g($0).fmap(f) }
        case let .columns(g):
            return .columns { g($0).fmap(f) }
        case let .ribbon(g):
            return .ribbon { g($0).fmap(f) }
        }
    }
}*/
