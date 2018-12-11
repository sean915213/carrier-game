//
//  CodableURL.swift
//  SGYSwiftUtility
//
//  Created by Sean G Young on 6/8/18.
//

import Foundation

struct CodableURL: SingleValueCodable {
    
    init?(rawValue: String) {
        guard let url = URL(string: rawValue) else { return nil }
        self.url = url
    }
    
    init(url: URL) {
        self.url = url
    }
    
    var url: URL
    var rawValue: String { return url.absoluteString }
}

extension CodableURL: CustomStringConvertible {
    var description: String { return rawValue }
}
