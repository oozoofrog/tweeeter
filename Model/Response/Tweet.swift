//
//  Tweet.swift
//  Tweeeter
//
//  Created by eyebookpro on 15/12/2018.
//  Copyright © 2018 ngenii. All rights reserved.
//

import Foundation

public struct Tweet: Codable {
    public let idStr: String
    public let id: Date
    public let text: String
    public let createdAt: String
    public let truncated: Bool
}
