//
//  APIConfiguration.swift
//  Tweeeter
//
//  Created by eyebookpro on 15/12/2018.
//  Copyright © 2018 ngenii. All rights reserved.
//

import Foundation

public class APIConfiguration {

    static let `default`: APIConfiguration = APIConfiguration(accessTokenProvider: AccessTokenProvider())

    let accessTokenProvider: AccessTokenProvidable
    let clientCredential: ClientCredential
    let requestAccessTokenIfNeeded: Bool

    init(accessTokenProvider: AccessTokenProvidable,
         requestAccessTokenIfNeeded: Bool = true,
         clientCredential: ClientCredential = ClientCredential()) {
        self.accessTokenProvider = accessTokenProvider
        self.requestAccessTokenIfNeeded = requestAccessTokenIfNeeded
        self.clientCredential = clientCredential
    }

}
