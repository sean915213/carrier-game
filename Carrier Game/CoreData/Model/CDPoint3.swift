//
//  CDPoint3.swift
//  Carrier Game
//
//  Created by Sean G Young on 12/6/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import GameplayKit
import SGYSwiftUtility

extension NSValueTransformerName {
    static let point3Transformer = NSValueTransformerName("CDPoint3Transformer")
    static let point3SetTransformer = NSValueTransformerName("CDPoint3SetTransformer")
}

class CDPoint3: NSObject, Codable {
    
    static func registerTransformers() {
        ValueTransformer.setValueTransformer(JSONValueTransformer<CDPoint3>(), forName: .point3Transformer)
        ValueTransformer.setValueTransformer(JSONValueTransformer<Set<CDPoint3>>(), forName: .point3SetTransformer)
    }
    
    init(x: Float, y: Float, z: Float) {
        self.x = x
        self.y = y
        self.z = z
        super.init()
    }
    
    var x: Float
    var y: Float
    var z: Float
}

extension CDPoint3 {

    convenience init(_ point: float3) {
        self.init(x: point.x, y: point.y, z: point.z)
    }
    
    override var description: String {
        return "{\(x), \(y), \(z)}"
    }
    
    override var debugDescription: String {
        return description
    }
}

extension float3 {
    init(_ point: CDPoint3) {
        self.init(x: point.x, y: point.y, z: point.z)
    }
}

extension Array where Element == float3 {
    init(_ vectors: [CDPoint3]) {
        self = vectors.map { float3($0) }
    }
}

extension Set where Element == float3 {
    init(_ vectors: Set<CDPoint3>) {
        self.init(vectors.map { float3($0) })
    }
}

// MARK: - Operator Overrides

//func +(lhs: CDPoint3, rhs: CDPoint2) -> CDPoint2 {
//    return CDPoint2(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
//}
