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
import RxSwift
import RxCocoa
import RxTest
import Model
import API
@testable import Tweeeter

class TweeeterTests: QuickSpec {

    override func spec() {
        continueAfterFailure = false

        let bundle = Bundle(for: TweeeterTests.self)
        let path = bundle.url(forResource: "user_timeline", withExtension: "json")!
        let data = try! Data(contentsOf: path)
        let tweets = try! Tweet.jsonDecoder.decode([Tweet].self, from: data)

        let count = 2
        let provider: TweetsProvidable = MockTweetsProvider(tweets)
        var viewModel: TweetsViewModel!

        var scheduler: TestScheduler!
        var observer: TestableObserver<[Tweet]>!

        var disposeBag: DisposeBag!

        beforeEach {
            disposeBag = DisposeBag()
            viewModel = TweetsViewModel(provider: provider)
            viewModel.bind()
            scheduler = TestScheduler(initialClock: 0)
            observer = scheduler.createObserver([Tweet].self)
            viewModel.outputs.tweets.bind(to: observer).disposed(by: disposeBag)
        }
        context("처음 요청을 하면") {
            it("\(count)개의 트윗을 가져온다.") {
                scheduler.scheduleAt(100, action: {
                    viewModel.inputs.requestNext.accept(count)
                })
                scheduler.start()

                let expectedResults = [next(0, []), next(100, Array(tweets[0..<count]))]
                XCTAssertEqual(observer.events, expectedResults)
            }
        }
        context("두 번 요청을 하면") {
            it("\(count * 2)개의 트윗을 가져온다.") {
                scheduler.scheduleAt(100, action: {
                    viewModel.inputs.requestNext.accept(count)
                })
                scheduler.scheduleAt(200, action: {
                    viewModel.inputs.requestNext.accept(count)
                })
                scheduler.start()

                let expectedResults = [next(0, []), next(100, Array(tweets[0..<count])), next(200, Array(tweets[0..<count * 2]))]
                XCTAssertEqual(observer.events, expectedResults)
            }
        }
    }

}

struct MockTweetsProvider: TweetsProvidable {

    let screenName: String = "twitterapi"
    let tweets: [Tweet]

    init(_ tweets: [Tweet]) {
        self.tweets = tweets
    }

    func request(count: Int) -> Single<[Tweet]> {
        return Single.just(Array(tweets[0..<count]))
    }

    func requestLessThan(id: UInt64, count: Int) -> Single<[Tweet]> {
        guard let lasts = tweets.split(whereSeparator: { $0.id == id }).last else { return .just([]) }
        let count = min(count, lasts.count)
        guard count > 0 else { return .just([]) }
        return Single.just(Array(Array(lasts)[0..<count]))
    }

}
