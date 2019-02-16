//
//  SemanticVersion.swift
//  SGYSwiftUtility
//
//  Created by Sean G Young on 1/30/19.
//

import Foundation

public struct SemanticVersion: SingleValueCodable {
    
    public init?(rawValue: String) {
        let split = rawValue.split(separator: ".")
        // Require <= 3 parts
        guard split.count <= 3 else { return nil }
        // Require major
        guard let vMajor = Int(split[0]) else { return nil }
        major = vMajor
        // If minor exists require it can be converted
        if split.count > 1 {
            guard let vMinor = Int(split[1]) else { return nil }
            minor = vMinor
        }
        // If patch exists require it can be converted
        if split.count > 2 {
            guard let vPatch = Int(split[2]) else { return nil }
            patch = vPatch
        }
    }
    
    public init(major: Int, minor: Int, patch: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }
    
    public var rawValue: String { return "\(major).\(minor).\(patch)"  }
    
    public var major: Int = 0
    public var minor: Int = 0
    public var patch: Int = 0
}

extension SemanticVersion: Comparable {
    public static func < (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        if lhs.major != rhs.major {
            return lhs.major < rhs.major
        } else if lhs.minor != rhs.minor {
            return lhs.minor < rhs.minor
        } else {
            return lhs.patch < rhs.patch
        }
    }
}

extension SemanticVersion: CustomStringConvertible {
    public var description: String { return rawValue }
}
