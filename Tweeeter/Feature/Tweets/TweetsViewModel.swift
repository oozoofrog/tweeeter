//
//  TweetsViewModel.swift
//  Tweeeter
//
//  Created by eyebookpro on 16/12/2018.
//  Copyright © 2018 ngenii. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Model

final class TweetsViewModel {

    let provider: TweetsProvidable

    let inputs: Inputs
    let outputs: Outputs

    var disposeBag: DisposeBag?

    init(provider: TweetsProvidable) {
        self.provider = provider
        self.inputs = Inputs()
        self.outputs = Outputs()
    }

    var name: String {
        return provider.screenName
    }

    @discardableResult
    func bind() -> DisposeBag {
        let disposeBag = DisposeBag()
        let provider = self.provider
        let inputs = self.inputs
        let outputs = self.outputs
        inputs.requestNextWithCount.flatMap { count -> Observable<[Tweet]> in
            let currentTweets = outputs.tweets.value
            if let lastID = currentTweets.last?.id {
                return provider.requestLessThan(id: lastID, count: count).asObservable().map { currentTweets + $0 }
            } else {
                return provider.request(count: count).asObservable()
            }
        }.bind(to: outputs.tweets).disposed(by: disposeBag)

        self.disposeBag = disposeBag
        return disposeBag
    }

    func startPlay() {
        
    }
}

extension TweetsViewModel {

    final class Inputs {
        let requestNextWithCount: PublishRelay<Int> = PublishRelay<Int>()
    }

    final class Outputs {
        let tweets: BehaviorRelay<[Tweet]> = BehaviorRelay(value: [])
    }
}
