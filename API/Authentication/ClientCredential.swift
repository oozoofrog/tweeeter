//
//  Credential.swift
//  Tweeeter
//
//  Created by eyebookpro on 15/12/2018.
//  Copyright © 2018 ngenii. All rights reserved.
//

import Foundation

public struct ClientCredential {
    private let consumerAPIKey: String
    private let consumerAPISecretKey: String

    var bearerToken: String {
        return "\(consumerAPIKey):\(consumerAPISecretKey)".data(using: .utf8)?.base64EncodedString() ?? ""
    }

    init(consumerAPIKey: String = "Tsib7UFrgIDFI4Ifoa1AWCA7H",
         consumerAPISecretKey: String = "5sD33AEgmkFWD8HN6yhubb3vOn6uluiX3A759sdBexOSgw0D4B") {
        self.consumerAPIKey = consumerAPIKey
        self.consumerAPISecretKey = consumerAPISecretKey
    }

}
