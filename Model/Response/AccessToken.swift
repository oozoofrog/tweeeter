//
//  AccessToken.swift
//  Tweeeter
//
//  Created by eyebookpro on 15/12/2018.
//  Copyright © 2018 ngenii. All rights reserved.
//

import Foundation

public struct AccessToken: Decodable {
    public enum TokenType: String, Decodable {
        case bearer
    }

    public var tokenType: TokenType
    public var accessToken: String
}
