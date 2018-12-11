//
//  SingleValueCodable.swift
//  SGYSwiftUtility
//
//  Created by Sean G Young on 6/8/18.
//

import Foundation

// Protocol largely taken from:
// http://www.russbishop.net/singlevaluecodable

protocol SingleValueCodable: Codable, RawRepresentable where RawValue: Codable { }

extension SingleValueCodable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(RawValue.self)
        guard let value = Self.init(rawValue: rawValue) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unable to decode \(Self.self) from \(rawValue).")
        }
        self = value
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}
