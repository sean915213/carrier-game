//
//  AutoLayoutExtensions.swift
//  SGYSwiftUtility
//
//  Created by Sean G Young on 2/13/16.
//
//

import UIKit

// No constant is exposed for the "aqua" space between siblings so calculate one on the fly
private let siblingAquaSpacing: CGFloat = {
    let container = UIView()
    let sibling1 = UIView()
    let sibling2 = UIView()
    container.addSubviews([sibling1, sibling2])
    return NSLayoutConstraint.constraints(withVisualFormat: "H:[sibling1]-[sibling2]", options: [], metrics: nil, views: ["sibling1": sibling1, "sibling2": sibling2]).first!.constant
}()

extension NSLayoutConstraint {
    
    public class var systemSiblingSpacing: CGFloat {
        return siblingAquaSpacing
    }
    
    /**
     Creates and returns an array of `NSLayoutConstraint` objects constructed to pin the provided view on all sides within its superview.  The applied margins are zero on all sides.
     
     - parameter view: The view to create the layout constraints for.
     
     - returns: An array of `NSLayoutConstraint` objects pinning the view.
     */
    public class func constraintsPinningView(_ view: UIView, toMargins: Bool = false) -> [NSLayoutConstraint] {
        if toMargins {
            let hConstraints = constraintsPinningView(view, axis: .horizontal, toMargins: toMargins)
            let vConstraints = constraintsPinningView(view, axis: .vertical, toMargins: toMargins)
            return hConstraints + vConstraints
        } else {
            return constraintsPinningView(view, insets: UIEdgeInsets())
        }
    }
    
    /**
     Creates and returns an array of `NSLayoutConstraint` objects constructed to pin the provided view on all sides within its superview.  The provided `insets` determine the margins.
     
     - parameter view:   The view to create the layout constraints for.
     - parameter insets: A `UIEdgeInsets` value describing the margins to apply.
     
     - returns: An array of `NSLayoutConstraint` objects pinning the view.
     */
    public class func constraintsPinningView(_ view: UIView, insets: UIEdgeInsets) -> [NSLayoutConstraint] {
        let hConstraints = NSLayoutConstraint.constraintsPinningView(view, axis: .horizontal, leadMargin: insets.left, trailingMargin: insets.right)
        let vConstraints = NSLayoutConstraint.constraintsPinningView(view, axis: .vertical, leadMargin: insets.top, trailingMargin: insets.bottom)
        return hConstraints + vConstraints
    }
    
    /**
     Creates and returns an array of `NSLayoutConstraint` objects constructed to pin the provided `views` to their respective superviews along the provided `axis`.  The leading and trailing margins are both zero.
     
     - parameter views: An array of views to create the layout constraints for.
     - parameter axis:  The axis along which to pin `views`.
     
     - returns: An array of `NSLayoutConstraint` objects pinning `views` along `axis`.
     */
    public class func constraintsPinningViews(_ views: [UIView], axis: NSLayoutConstraint.Axis, toMargins: Bool = false) -> [NSLayoutConstraint] {
        if toMargins {
            return views.flatMap { self.constraintsPinningView($0, axis: axis, toMargins: toMargins) }
        } else {
            return constraintsPinningViews(views, axis: axis, leadMargin: 0, trailingMargin: 0)
        }
    }
    
    /**
     Creates and returns an array of `NSLayoutConstraint` objects constructed to pin `views` to their respective superviews along the provided `axis`.
     
     - parameter views:          An array of views to create the layout constraints for.
     - parameter axis:           The axis along which to pin `views`.
     - parameter leadMargin:     The leading margin to apply to each view.
     - parameter trailingMargin: The trailing margin to apply to each view.
     
     - returns: An array of `NSLayoutConstraint` objects pinning `views` along `axis`.
     */
    public class func constraintsPinningViews(_ views: [UIView], axis: NSLayoutConstraint.Axis, leadMargin: CGFloat, trailingMargin: CGFloat) -> [NSLayoutConstraint] {
        return views.flatMap { self.constraintsPinningView($0, axis: axis, leadMargin: leadMargin, trailingMargin: trailingMargin) }
    }
    
    /**
     Creates and returns an array of `NSLayoutConstraint` objects constructed to pin `view` to its respective superview along the provided `axis`. The applied leading and trailing padding is zero.
     
     - parameter view: The view to create the layout constraints for.
     - parameter axis: The axis along which to pin `view`.
     
     - returns: An array of `NSLayoutConstraint` objects pinning `view` along `axis`.
     */
    public class func constraintsPinningView(_ view: UIView, axis: NSLayoutConstraint.Axis, toMargins: Bool = false) -> [NSLayoutConstraint] {
        if toMargins {
            
            let prefixString = axis == .horizontal ? "H:" : "V:"
            let layoutString = prefixString + "|-[view]-|"
            
            return NSLayoutConstraint.constraints(withVisualFormat: layoutString, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["view" : view])
        } else {
            return constraintsPinningView(view, axis: axis, leadMargin: 0, trailingMargin: 0)
        }
    }
    
    /**
     Creates and returns an array of `NSLayoutConstraint` objects constructed to pin `view` to its respective superview along the provided `axis`. The view is given margins determined by `leadMargin` and `trailingMargin`.
     
     - parameter view:           The view to create the layout constraints for.
     - parameter axis:           The axis along which to pin `view`.
     - parameter leadMargin:     The leading margin to apply to the constraints.
     - parameter trailingMargin: The trailing margin to apply to the constraints.
     
     - returns: An array of `NSLayoutConstraint` objects pinning `view` along `axis`.
     */
    public class func constraintsPinningView(_ view: UIView, axis: NSLayoutConstraint.Axis, leadMargin: CGFloat, trailingMargin: CGFloat) -> [NSLayoutConstraint] {
        
        let layoutViews = ["view" : view]
        let layoutMetrics = ["lead" : leadMargin, "trailing" : trailingMargin]
        
        let prefixString = axis == .horizontal ? "H:" : "V:"
        let layoutString = prefixString + "|-lead-[view]-trailing-|"
        
        return NSLayoutConstraint.constraints(withVisualFormat: layoutString, options: NSLayoutConstraint.FormatOptions(), metrics: layoutMetrics, views: layoutViews)
    }
    
    @discardableResult
    public func activate() -> NSLayoutConstraint {
        isActive = true
        return self
    }
    
    @discardableResult
    public func deactivate() -> NSLayoutConstraint {
        isActive = false
        return self
    }
}

extension Sequence where Element: NSLayoutConstraint {
    /// Activates each `NSLayoutConstraint` object.
    @discardableResult
    public func activate() -> Self {
        forEach { $0.isActive = true }
        return self
    }
    /// Deactivates each `NSLayoutConstraint` object.
    @discardableResult
    public func deactivate() -> Self {
        forEach { $0.isActive = false }
        return self
    }
    /// Sets the priority of each `NSLayoutConstraint` object.
    @discardableResult
    public func setPriority(_ priority: UILayoutPriority) -> Self {
        forEach { $0.priority = priority }
        return self
    }
}

