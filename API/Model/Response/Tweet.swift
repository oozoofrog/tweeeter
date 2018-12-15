//
//  Tweet.swift
//  Tweeeter
//
//  Created by eyebookpro on 15/12/2018.
//  Copyright © 2018 ngenii. All rights reserved.
//

import Foundation

public struct Tweet: Codable {
    let idStr: String
    let id: Date
    let text: String
    let createdAt: String
    let truncated: Bool
}
