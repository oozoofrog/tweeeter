//
//  TweetsProvider.swift
//  Tweeeter
//
//  Created by eyebookpro on 16/12/2018.
//  Copyright © 2018 ngenii. All rights reserved.
//

import Foundation
import RxSwift
import Model
import API

protocol TweetsProvidable {
    var screenName: String { get }
    func request(count: Int) -> Single<[Tweet]>
    func requestLessThan(id: UInt64, count: Int) -> Single<[Tweet]>
}

struct TweetsProvider: TweetsProvidable {
    let screenName: String

    func request(count: Int) -> Single<[Tweet]> {
        return .never()
    }

    func requestLessThan(id: UInt64, count: Int) -> Single<[Tweet]> {
        return .never()
    }

}
