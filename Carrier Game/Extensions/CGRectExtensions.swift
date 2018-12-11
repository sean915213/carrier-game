//
//  CGRectExtensions.swift
//  Carrier Game
//
//  Created by Sean G Young on 11/6/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import Foundation
import CoreGraphics

extension CGRect {
    
    init(x: Int32, y: Int32, width: Int32, height: Int32) {
        self.init(x: CGFloat(x), y: CGFloat(y), width: CGFloat(width), height: CGFloat(height))
    }
}
