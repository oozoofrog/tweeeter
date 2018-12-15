//
//  DefaultDecoderUsable.swift
//  Tweeeter
//
//  Created by eyebookpro on 15/12/2018.
//  Copyright © 2018 ngenii. All rights reserved.
//

import Foundation

extension Decodable {
    static var jsonDecoder: JSONDecoder {
        let decoder: JSONDecoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}
