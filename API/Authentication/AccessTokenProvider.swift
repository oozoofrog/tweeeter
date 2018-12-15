//
//  AccessTokenProvider.swift
//  Tweeeter
//
//  Created by eyebookpro on 15/12/2018.
//  Copyright © 2018 ngenii. All rights reserved.
//

import Foundation

public protocol AccessTokenProvidable {
    var accessToken: String? { get }
    func setAccessToken(_ token: String)
}

public final class AccessTokenProvider: AccessTokenProvidable {

    public var accessToken: String? {
        get {
            return UserDefaults.standard.string(forKey: "AccessToken")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "AccessToken")
            UserDefaults.standard.synchronize()
        }
    }

    public func setAccessToken(_ token: String) {
        accessToken = token
    }

}
