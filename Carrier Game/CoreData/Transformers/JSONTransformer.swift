//
//  JSONTransformer.swift
//  Carrier Game
//
//  Created by Sean G Young on 11/3/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import Foundation

class JSONTransformer<T>: ValueTransformer where T: Codable {
    
    override class func transformedValueClass() -> AnyObject.Type {
        return NSData.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    // MARK: - Initialization
    
    init(encoder: JSONEncoder = JSONEncoder(), decoder: JSONDecoder = JSONDecoder()) {
        self.encoder = encoder
        self.decoder = decoder
    }
    
    // MARK: - Properties
    
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    // MARK: - Methods
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let input = value as? T else { return nil }
        return try? encoder.encode(input)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        return try? decoder.decode(T.self, from: data)
    }
}
