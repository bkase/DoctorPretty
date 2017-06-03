## Doctor Pretty

> A Swift implementation of the [A prettier printer (Wadler 2003)](https://homepages.inf.ed.ac.uk/wadler/papers/prettier/prettier.pdf) ported from [wl-pprint-annotated](https://github.com/minad/wl-pprint-annotated/blob/master/src/Text/PrettyPrint/Annotated/WL.hs)

[![Build Status](https://travis-ci.org/bkase/DoctorPretty.svg?branch=master)](https://travis-ci.org/bkase/DoctorPretty)

## What is this

A pretty printer is the dual of a parser -- take some arbitrary AST and output it to a String. This library is a collection of combinators and a primitive called a `Doc` to describe pretty printing some data much like a parser combinator library provides combinators and primitives to describe parsing test into an AST. Interestingly, this implementation efficiently finds the _best_ pretty print. You encode your knowledge of what the _best_ means with your use of various `Doc` combinators.

For example: Let's say we have some internal structured representation of this Swift code:

```swift
func aLongFunction(foo: String, bar: Int, baz: Long) -> (String, Int, Long) {
    sideEffect()
    return (foo, bar, baz)
}
```

With this library the description that pretty prints the above at a page width of 120 characters. Also prints:

At a page-width of 40 characters:

```swift
func aLongFunction(
    foo: String, bar: Int, baz: Long
) -> (String, Int, Long) {
    sideEffect()
    return (foo, bar, baz)
}
```

and at a page-width of 20 characters:

```swift
func aLongFunction(
    foo: String,
    bar: Int,
    baz: Long
) -> (
    String,
    Int,
    Long
) {
    sideEffect()
    return (
        foo,
        bar,
        baz
    )
}
```

See the encoding of this particular document in the [`testSwiftExample` test case](Tests/DoctorPrettyTests/DoctorPrettyTests.swift).

## What would I use this for?

If you're outputting text and you care about the width of the page. Serializing to a `Doc` lets you capture your line-break logic and how your output string looks in one go.

Why would you output text and care about page width?

1. You're building a `gofmt`-type tool for Swift (Note: `gofmt` doesn't pretty-print based on a width, `refmt` (Reason) and `prettier` (JavaScript) do)
2. You're writing some sort of codegen tool to output Swift code
3. You're building a source-to-source transpiler
2. You're outputing help messages in a terminal window for some commandline app (I'm planning to use this for https://github.com/bkase/swift-optparse-applicative)

## What is this, actually

A Swift implementation of the [A prettier printer (Wadler 2003)](https://homepages.inf.ed.ac.uk/wadler/papers/prettier/prettier.pdf) paper (including generally accepted modern enhancements ala [wl-pprint-annotated](https://github.com/minad/wl-pprint-annotated/blob/master/src/Text/PrettyPrint/Annotated/WL.hs). This implementation is close to a direct port of [wl-pprint-annotated](https://github.com/minad/wl-pprint-annotated/blob/master/src/Text/PrettyPrint/Annotated/WL.hs) with some influence from [scala-optparse-applicative's Doc](https://github.com/bmjames/scala-optparse-applicative/blob/master/src/main/scala/net/bmjames/opts/types/Doc.scala) and a few extra Swiftisms.

## Basic Usage

`Doc` is very composable. First of all it's a [`monoid`](https://www.youtube.com/watch?v=6z9QjDUKkCs) with an `.empty` document and the `.concat` case which just puts two documents next to each other. We also have a primitive called `grouped`, which tries this document on a single line, but if it doesn't fit then breaks it up on new-lines. From there we build all high-level combinators up.

`x <%> y` concats x and y with a space in between if it fits, otherwise puts a line.

```swift
.text("foo") <%> .text("bar")
```

pretty-prints under a large page-width:

```
foo bar
```

but when the page-width is set to `5` prints:

```
foo
bar
```

Here are a few more combinators:

```swift
/// Concats x and y with a space in between
static func <+>(x: Doc, y: Doc) -> Doc

/// Behaves like `space` if the output fits the page
/// Otherwise it behaves like line
static var softline

/// Concats x and y together if it fits
/// Otherwise puts a line in between
static func <%%>(x: Doc, y: Doc) -> Doc

/// Behaves like `zero` if the output fits the page
/// Otherwise it behaves like line
static var softbreak: Doc

/// Puts a line between x and y that can be flattened to a space
static func <&>(x: Doc, y: Doc) -> Doc

/// Puts a line between x and y that can be flattened with no space
static func <&&>(x: Doc, y: Doc) -> Doc
```

There are also combinators for turning collections of documents into "collection"-like pretty-printed primitives such as a square-bracket separated lists:

```swift
.text("let x =") <%> [ "foo", "bar", "baz" ].map(Doc.text).list(indent: 4)
```

Pretty-prints at page-width 80 to:

```swift
let x = [foo, bar, baz]
```

and at page-width 10 to:

```swift
let x = [
    foo,
    bar,
    baz
]
```

See the source for more documentation, I have included descriptive doc-comments to explain all the operators (mostly taken from [wl-pprint-annotated](https://github.com/minad/wl-pprint-annotated/blob/master/src/Text/PrettyPrint/Annotated/WL.hs)).

## How do I actually pretty print my documents?

`Doc` has two rendering methods for now: `renderPrettyDefault` prints with a page-width of 100 and `renderPretty` lets you control the page-width.

These methods don't return `String`s directly -- they return `SimpleDoc` a low-level IR that is close to a string, but high-enough that you can efficiently output to some other output system like stdout or a file.

For now, `SimpleDoc` has `displayString()` which outputs a `String`, and:

```swift
func display<M: Monoid>(readString: (String) -> M) -> M
```

`display` takes a function that can turn a string into a monoid and then smashes everything together. Because this works for any monoid, you just need to provide a monoid instance for your output formatter (to write to stdout or to a file).

## Installation

With Swift Package Manager, put this inside your `Package.swift`:

```swift
.Package(url: "https://github.com/bkase/DoctorPretty.git",
         majorVersion: 0, minor: 2)
```

## How does it work?

Read the [A prettier printer (Wadler 2003) paper](https://homepages.inf.ed.ac.uk/wadler/papers/prettier/prettier.pdf).

`Doc` is a recursive enum that captures text and new lines. The interesting case is `.union(longerLines: Doc, shorterLines: Doc)`. This case reifies the notion of "try the longer lines first, then the shorter lines". We can build all sorts of high-level combinators that combine `Doc`s in different ways that eventually reduce to a few strategic `.union`s.

The renderer keeps a work-list and each rule removes or adds pieces of work to the list and recurses until the list is empty. The best-fit metric proceeds greedily for now, but can be swapped out easily for a more intelligent algorithm in the future.

