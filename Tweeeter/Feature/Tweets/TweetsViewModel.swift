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

    let inputs: Inputs
    let outputs: Outputs

    var disposeBag: DisposeBag?

    init() {
        self.inputs = Inputs()
        self.outputs = Outputs()
    }

    @discardableResult
    func bind() -> DisposeBag {
        let disposeBag = DisposeBag()
        let inputs = self.inputs
        let outputs = self.outputs

        var isLoading: Bool = false
        inputs.requestNextWithCount
            .filter({ count in count > 0 })
            .throttle(0.5, scheduler: MainScheduler.asyncInstance)
            .filter { _ in isLoading == false }
            .flatMapLatest { count -> Observable<[Tweet]> in
                let name = inputs.screenName.value
                let provider = TweetsProvider.init(screenName: name)
                isLoading = true
                let currentTweets = outputs.tweets.value
                if let last = currentTweets.last, last.user.screenName == name {
                    return provider
                        .requestLessThan(id: last.id, count: count)
                        .asObservable()
                        .map { currentTweets + $0 }
                        .catchError({ _ -> Observable<[Tweet]> in
                            isLoading = false
                            return .never()
                        })
                } else {
                    return provider.request(count: count)
                        .asObservable()
                        .catchError({ _ -> Observable<[Tweet]> in
                            isLoading = false
                            return .never()
                        })
                }
            }
            .do(onNext: { _ in isLoading = false }, onError: { _ in isLoading = false })
            .bind(to: outputs.tweets)
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

        let screenName: BehaviorRelay<String> = BehaviorRelay<String>(value: "neko")

        let requestNextWithCount: BehaviorRelay<Int> = BehaviorRelay<Int>(value: 0)
        let startPlay: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    }

    final class Outputs {
        let tweets: BehaviorRelay<[Tweet]> = BehaviorRelay(value: [])
        let showNext: PublishRelay<Void> = PublishRelay()
    }
}
