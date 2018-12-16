//
//  UserTimeline.swift
//  Model
//
//  Created by eyebookpro on 16/12/2018.
//  Copyright © 2018 ngenii. All rights reserved.
//

import Foundation

public struct UserTimeline: Encodable {
    let screenName: String
    let count: Int
    let maxID: UInt64?

    public init(_ screenName: String, count: Int, maxID: UInt64? = nil) {
        self.screenName = screenName
        self.count = count
        self.maxID = maxID
    }
}
