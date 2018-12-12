//
//  CodableURL.swift
//  SGYSwiftUtility
//
//  Created by Sean G Young on 6/8/18.
//

import Foundation

struct CodableURL: SingleValueCodable {
    
    public init?(rawValue: String) {
        guard let url = URL(string: rawValue) else { return nil }
        self.url = url
    }
    
    public init(url: URL) {
        self.url = url
    }
    
    public var url: URL
    public var rawValue: String { return url.absoluteString }
}

extension CodableURL: CustomStringConvertible {
    public var description: String { return rawValue }
}
