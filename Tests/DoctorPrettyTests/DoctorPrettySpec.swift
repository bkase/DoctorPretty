//
//  DoctorPrettySpec.swift
//  DoctorPretty
//
//  Created by Brandon Kase on 5/21/17.
//
//

import Foundation
@testable import DoctorPretty
import SwiftCheck
import XCTest
import Operadics

// mostly from https://github.com/bmjames/scala-optparse-applicative/blob/master/src/test/scala/net/bmjames/opts/test/DocSpec.scala

extension Doc {
    func equals(underPageWidth pageWidth: Width, doc: Doc) -> Bool {
        return
            self.renderPretty(ribbonFrac: 1.0, pageWidth: pageWidth).displayString() ==
	        doc.renderPretty(ribbonFrac: 1.0, pageWidth: pageWidth).displayString()
    }
}

extension Doc: Arbitrary {
    public static var arbitrary: Gen<Doc> {
		let stringDocGen: Gen<Doc> = String.arbitrary.map{ Doc.text($0) }
		let lineOrEmptyGen: Gen<Doc> = Gen<[Doc]>.fromElements(of: [ Doc.line, Doc.empty ])
		return Gen<Doc>.frequency([
		        (3, stringDocGen),
		        (1, lineOrEmptyGen)
		    ]).proliferate(withSize: 10)
              .map{ ds in Doc.cat(ds) }
    }
}

class DocSpecs: XCTestCase {
    func testSpecs() {
        let posNum = Int.arbitrary.suchThat{ $0 > 0 }
		property("text append is concat") <- forAll(posNum, String.arbitrary, String.arbitrary) { (width: Int, s1: String, s2: String) in
		    return Doc.text(s1 + s2).equals(underPageWidth: width, doc: .text(s1) <> .text(s2))
		}

        property("nesting law") <- forAll(posNum, posNum, posNum, Doc.arbitrary) { (x: Int, y: Int, z: Int, doc: Doc) in
            let xs = [x, y, z].sorted()
            let (nest1, nest2, width) = (xs[0], xs[1], xs[2])

            return Doc.nest(nest1 + nest2, doc)
                .equals(underPageWidth: width,
                        doc: Doc.nest(nest1, Doc.nest(nest2, doc)))
        }

        property("zero nesting is id") <- forAll(posNum, Doc.arbitrary) { (width: Int, doc: Doc) in
            return doc.equals(underPageWidth: width,
                              doc: Doc.nest(0, doc))
        }

        property("nesting distributes") <- forAll(posNum, posNum, Doc.arbitrary, Doc.arbitrary) { (x: Int, y: Int, doc1: Doc, doc2: Doc) in
            let xs = [x, y].sorted()
            let (nest, width) = (xs[0], xs[1])

            return Doc.nest(nest, doc1 <> doc2)
                .equals(underPageWidth: width,
                        doc: Doc.nest(nest, doc1) <> Doc.nest(nest, doc2))
        }

        property("nesting single line is noop") <- forAll(posNum, posNum, String.arbitrary) { (x: Int, y: Int, str: String) in
            let xs = [x, y].sorted()
            let (nest, width) = (xs[0], xs[1])
            let noNewlines = String(str.characters.filter { $0 != "\n" })

            return Doc.nest(nest, .text(noNewlines))
                .equals(underPageWidth: width,
                        doc: .text(noNewlines))
        }
    }
}
