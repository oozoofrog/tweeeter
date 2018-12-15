//
//  TweeeterTests.swift
//  TweeeterTests
//
//  Created by eyebookpro on 15/12/2018.
//  Copyright © 2018 ngenii. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import Tweeeter

class TweeeterTests: QuickSpec {

    override func spec() {
        continueAfterFailure = false

        var viewModel: TweetsViewModel!

        beforeEach {
            viewModel = TweetsViewModel()
        }
    }

}
