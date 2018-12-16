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

        var isLoading: Bool = false
        inputs.requestNextWithCount
            .throttle(0.5, scheduler: MainScheduler.asyncInstance)
            .filter { _ in isLoading == false }
            .flatMap { count -> Observable<[Tweet]> in
                isLoading = true
                let currentTweets = outputs.tweets.value
                if let lastID = currentTweets.last?.id {
                    return provider.requestLessThan(id: lastID, count: count).asObservable().map { currentTweets + $0 }
                } else {
                    return provider.request(count: count).asObservable()
                }
            }
            .bind(to: outputs.tweets)
            .disposed(by: disposeBag)

        outputs.tweets
            .distinctUntilChanged()
            .subscribe { _ in
                isLoading = false
            }
            .disposed(by: disposeBag)

        inputs.startPlay
            .distinctUntilChanged()
            .flatMapLatest { start -> Observable<Void> in
                if start {
                    return Observable<Int>.interval(1, scheduler: MainScheduler.asyncInstance).map { _ in }
                } else {
                    return .never()
                }
            }
            .bind(to: outputs.showNext)
            .disposed(by: disposeBag)

        self.disposeBag = disposeBag
        return disposeBag
    }

    func startPlay() {
        inputs.startPlay.accept(true)
    }

    func stopPlay() {
        inputs.startPlay.accept(false)
    }

    var isPlaying: Bool {
        return inputs.startPlay.value
    }
}

extension TweetsViewModel {

    final class Inputs {
        let requestNextWithCount: PublishRelay<Int> = PublishRelay<Int>()
        let startPlay: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    }

    final class Outputs {
        let tweets: BehaviorRelay<[Tweet]> = BehaviorRelay(value: [])
        let showNext: PublishRelay<Void> = PublishRelay()
    }
}
