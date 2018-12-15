//
//  Tweet.swift
//  Tweeeter
//
//  Created by eyebookpro on 15/12/2018.
//  Copyright © 2018 ngenii. All rights reserved.
//

import Foundation

public struct Tweet: Codable, Equatable {

    public let id: UInt64

    public let user: User

    public let favoriteCount: UInt64?

    public let text: String
    public let createdAt: String

}

public struct User: Codable, Equatable {

    public let id: UInt64
    public let profileImageUrlHttps: URL?

    public let url: URL?
    public let name: String
    public let screenName: String
    public let description: String

}
