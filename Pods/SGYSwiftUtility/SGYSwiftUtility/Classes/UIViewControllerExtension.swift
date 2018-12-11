//
//  UIViewControllerExtension.swift
//  Pods-SGYSwiftUtility_Tests
//
//  Created by Sean G Young on 9/24/18.
//

import Foundation

extension UIViewController {
    
    public func addChild(_ child: UIViewController, withConfigureViewBlock configureBlock: (UIView, () -> Void) -> Void) {
        addChild(child)
        configureBlock(child.view, { child.didMove(toParent: self) })
    }
    
    public func removeFromParent(withRemoveViewBlock removeBlock: (() -> Void) -> Void) {
        willMove(toParent: nil)
        removeBlock({ removeFromParent() })
    }
}
