//
//  CDPoint2.swift
//  Carrier Game
//
//  Created by Sean G Young on 11/14/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import UIKit
import Foundation
import GameKit

extension NSValueTransformerName {
    static let point2Transformer = NSValueTransformerName("CDPoint2Transformer")
    static let point2SetTransformer = NSValueTransformerName("CDPoint2SetTransformer")
}

class CDPoint2: NSObject, Codable {
    
    static func registerTransformers() {
        ValueTransformer.setValueTransformer(JSONTransformer<CDPoint2>(), forName: .point2Transformer)
        ValueTransformer.setValueTransformer(JSONTransformer<Set<CDPoint2>>(), forName: .point2SetTransformer)
    }
    
    init(x: CGFloat, y: CGFloat) {
        self.x = x
        self.y = y
        super.init()
    }
    
    var x: CGFloat
    var y: CGFloat

    // TODO: MOVE
    
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(x)
        hasher.combine(y)
        return hasher.finalize()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? CDPoint2 else { return false }
        return x == object.x && y == object.y
    }
}

extension CDPoint2 {
    
    class func map(from rect: CGRect) -> [CDPoint2] {
        var points = [CDPoint2]()
        for x in Int(rect.minX)..<Int(rect.maxX) {
            for y in Int(rect.minY)..<Int(rect.maxY) {
                points.append(CDPoint2(x: CGFloat(x), y: CGFloat(y)))
            }
        }
        return points
    }
    
    convenience init(_ point: CGPoint) {
        self.init(x: point.x, y: point.y)
    }
    
    override var description: String {
        return "{\(x), \(y)}"
    }
    
    override var debugDescription: String {
        return description
    }
}

extension CGPoint {
    init(_ point: CDPoint2) {
        self.init(x: point.x, y: point.y)
    }
}

extension vector_int2 {
    init(_ point: CDPoint2) {
        self = [Int32(point.x), Int32(point.y)]
    }
}

extension Array where Element == vector_int2 {
    init(_ vectors: [CDPoint2]) {
        self = vectors.map { vector_int2($0) }
    }
}

extension Set where Element == vector_int2 {
    init(_ vectors: Set<CDPoint2>) {
        self.init(vectors.map { vector_int2($0) })
    }
}

// MARK: - Operator Overrides

func +(lhs: CDPoint2, rhs: CDPoint2) -> CDPoint2 {
    return CDPoint2(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}
