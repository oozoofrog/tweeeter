//
//  DefaultDecoderUsable.swift
//  Tweeeter
//
//  Created by eyebookpro on 15/12/2018.
//  Copyright © 2018 ngenii. All rights reserved.
//

import Foundation

extension Decodable {
    public static var jsonDecoder: JSONDecoder {
        let decoder: JSONDecoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }
}

extension Encodable {
    public static var jsonEncoder: JSONEncoder {
        let encoder: JSONEncoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }
}

protocol ExportContainable {
    associatedtype Element
    var element: Element { get }
}

extension ExportContainable where Element: Encodable {
    func parameter() throws -> [String: Any]? {
        let jsonData = try Element.jsonEncoder.encode(element)
        let json = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
        return json as? [String: Any]
    }
}

struct ExportContainer<Element>: ExportContainable {
    let element: Element
}

extension Encodable {
    var export: ExportContainer<Self> {
        return ExportContainer(element: self)
    }
}
