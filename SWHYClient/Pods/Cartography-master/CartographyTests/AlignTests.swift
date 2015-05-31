//
//  AlignTests.swift
//  Cartography
//
//  Created by Robert Böhnke on 17/02/15.
//  Copyright (c) 2015 Robert Böhnke. All rights reserved.
//

import Cartography
import XCTest

class AlignTests: XCTestCase {
    var superview: View!
    var viewA: View!
    var viewB: View!
    var viewC: View!

    override func setUp() {
        superview = View(frame: CGRectMake(0, 0, 400, 400))

        viewA = View(frame: CGRectZero)
        superview.addSubview(viewA)

        viewB = View(frame: CGRectZero)
        superview.addSubview(viewB)

        viewC = View(frame: CGRectZero)
        superview.addSubview(viewC)

        constrain(viewA) { view in
            view.height == 200
            view.width == 200

            view.top  == view.superview!.top  + 10
            view.left == view.superview!.left + 10
        }
    }

    func testAlignEdges() {
        layout(viewA, viewB, viewC) { viewA, viewB, viewC in
            align(top: viewA, viewB, viewC)
            align(right: viewA, viewB, viewC)
            align(bottom: viewA, viewB, viewC)
            align(left: viewA, viewB, viewC)
        }

        XCTAssertEqual(viewA.frame, viewB.frame, "It should align the edges")
        XCTAssertEqual(viewA.frame, viewC.frame, "It should align the edges")

        XCTAssertFalse(viewA.car_translatesAutoresizingMaskIntoConstraints)
        XCTAssertFalse(viewB.car_translatesAutoresizingMaskIntoConstraints)
        XCTAssertFalse(viewC.car_translatesAutoresizingMaskIntoConstraints)
    }

    func testAlignCenter() {
        layout(viewA, viewB, viewC) { viewA, viewB, viewC in
            viewA.size == viewB.size
            viewB.size == viewC.size

            align(centerX: viewA, viewB, viewC)
            align(centerY: viewA, viewB, viewC)
        }

        XCTAssertEqual(viewA.frame, viewB.frame, "It should align the edges")
        XCTAssertEqual(viewA.frame, viewC.frame, "It should align the edges")

        XCTAssertFalse(viewA.car_translatesAutoresizingMaskIntoConstraints)
        XCTAssertFalse(viewB.car_translatesAutoresizingMaskIntoConstraints)
        XCTAssertFalse(viewC.car_translatesAutoresizingMaskIntoConstraints)
    }
}
