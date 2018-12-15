//
//  APIRequestBuilder+Rx.swift
//  Tweeeter
//
//  Created by eyebookpro on 16/12/2018.
//  Copyright © 2018 ngenii. All rights reserved.
//

import RxSwift
import API

extension APIRequestBuilder: ReactiveCompatible {}

extension Reactive where Base: APIRequestBuilder {

    func request<Result: Decodable>(_ type: Result.Type) -> Single<Result> {
        return Single.create(subscribe: { event -> Disposable in

            self.base.requestResult(Result.self, completion: { (result, error) in
                if let error = error {
                    event(.error(error))
                } else if let result = result {
                    event(.success(result))
                } else {
                    event(.error(APIRequestError.unknown))
                }
            })

            return Disposables.create()
        })
    }

}
