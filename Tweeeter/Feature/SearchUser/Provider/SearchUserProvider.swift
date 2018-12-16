//
//  SearchUserProvider.swift
//  Tweeeter
//
//  Created by eyebookpro on 17/12/2018.
//  Copyright © 2018 ngenii. All rights reserved.
//

import Foundation
import API
import Model
import RxSwift

struct SearchUserProvider {
    let screenName: String

    func request() -> Single<[User]> {
        return APIRequestBuilder(path: "users/lookup.json", parameters: ["screen_name": screenName])
            .rx
            .request([User].self)
    }
}
