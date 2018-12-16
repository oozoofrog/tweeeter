//
//  UserTimelineRequestBuilder.swift
//  API
//
//  Created by eyebookpro on 16/12/2018.
//  Copyright © 2018 ngenii. All rights reserved.
//

import Foundation
import Model

public final class UserTimelineRequestBuilder: APIRequestBuilder {

    public convenience init(request: UserTimeline) throws {
        try self.init(method: .get, path: "statuses/user_timeline.json", request: request)
    }

}
