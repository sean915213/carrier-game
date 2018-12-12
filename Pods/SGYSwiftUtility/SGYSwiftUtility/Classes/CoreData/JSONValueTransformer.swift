//
//  JSONValueTransformer.swift
//  SGYSwiftUtility
//
//  Created by Sean G Young on 11/3/18.
//

import Foundation

public class JSONTransformer<T>: ValueTransformer where T: Codable {
    
    override public class func transformedValueClass() -> AnyObject.Type {
        return NSData.self
    }
    
    override public class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    // MARK: - Initialization
    
    public init(encoder: JSONEncoder = JSONEncoder(), decoder: JSONDecoder = JSONDecoder()) {
        self.encoder = encoder
        self.decoder = decoder
    }
    
    // MARK: - Properties
    
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    // MARK: - Methods
    
    override public func transformedValue(_ value: Any?) -> Any? {
        guard let input = value as? T else { return nil }
        return try? encoder.encode(input)
    }
    
    override public func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        return try? decoder.decode(T.self, from: data)
    }
}
