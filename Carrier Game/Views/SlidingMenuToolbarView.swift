//
//  SlidingMenuToolbarView.swift
//  Carrier Game
//
//  Created by Sean G Young on 3/3/19.
//  Copyright © 2019 Sean G Young. All rights reserved.
//

import UIKit

private let animationDuration: TimeInterval = 0.3

class SlidingMenuToolbarView: UIView {

    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    var selectionColor: UIColor = .red
    
    var toolbarItems = [UIBarButtonItem]() {
        didSet { updateItems() }
    }
    
    private(set) var selectedItem: UIBarButtonItem? {
        didSet {
            // Update selection colors
            oldValue?.tintColor = toolbar.tintColor
            selectedItem?.tintColor = selectionColor
        }
    }
    
    private lazy var toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        return toolbar
    }()
    
    private lazy var slidingMenuView: SlidingMenuView = {
        let menuView = SlidingMenuView(translatesAutoresizingMask: false)
        return menuView
    }()
    
    private lazy var menuPositionConstraint: NSLayoutConstraint = {
        return slidingMenuView.topAnchor.constraint(equalTo: toolbar.topAnchor)
    }()
    
    private lazy var heightConstraint: NSLayoutConstraint = {
        return heightAnchor.constraint(equalToConstant: 0)
    }()
    
    // MARK: - Methods
    
    private func setup() {
        heightConstraint.activate()
        // Add menu item view then toolbar
        addSubviews(slidingMenuView, toolbar)
        // Constrain menu item view
        NSLayoutConstraint.constraintsPinningView(slidingMenuView, axis: .horizontal).activate()
        menuPositionConstraint.activate()
        // Constrain toolbar
        NSLayoutConstraint.constraintsPinningView(toolbar, axis: .horizontal).activate()
        toolbar.bottomAnchor.constraint(equalTo: bottomAnchor).activate()
    }
    
    override func updateConstraints() {
        // Start with toolbar height
        var height = toolbar.intrinsicContentSize.height
        // Assign before finishing
        defer {
            heightConstraint.constant = height
            super.updateConstraints()
        }
        // If no item then only toolbar
        guard selectedItem != nil else { return }
        // Calculate sliding menu view's height
        var size = UIView.layoutFittingCompressedSize
        size.width = bounds.width
        let menuSize = slidingMenuView.systemLayoutSizeFitting(size, withHorizontalFittingPriority: .defaultHigh, verticalFittingPriority: .fittingSizeLevel)
        height += menuSize.height
    }
    
    func showOrUpdateSlidingMenu(for barButton: UIBarButtonItem, with views: [UIView]) {
        assert(toolbar.items?.contains(barButton) == true)
        // Assign/change selected item when we're done
        defer { selectedItem = barButton }
        // Assign new items
        setExpandedViews(views)
        // If already displayed then animate change of items
        guard selectedItem == nil else {
            // Animate the layout change
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: animationDuration, delay: 0, options: [], animations: {
                self.slidingMenuView.layoutIfNeeded()
            }, completion: nil)
            return
        }
        // Otherwise change items immediately
        slidingMenuView.layoutIfNeeded()
        // Animate in the menu
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: animationDuration, delay: 0, options: .curveEaseIn, animations: {
            self.menuPositionConstraint.deactivate()
            self.menuPositionConstraint = self.slidingMenuView.bottomAnchor.constraint(equalTo: self.toolbar.topAnchor).activate()
            self.layoutIfNeeded()
        }, completion: { _ in self.setNeedsUpdateConstraints() })
    }
    
    func hideSlidingMenuIfDisplayed() {
        // Hide only if displayed
        guard selectedItem != nil else { return }
        selectedItem = nil
        // Animate out
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: animationDuration, delay: 0, options: .curveEaseOut, animations: {
            // Animate out
            self.menuPositionConstraint.deactivate()
            self.menuPositionConstraint = self.slidingMenuView.topAnchor.constraint(equalTo: self.toolbar.topAnchor).activate()
            self.layoutIfNeeded()
        }) { _ in
            // Remove current views when completed
            self.setExpandedViews([])
        }
    }
    
    private func updateItems() {
        toolbar.setItems(toolbarItems, animated: true)
        hideSlidingMenuIfDisplayed()
        setNeedsUpdateConstraints()
    }
    
    private func setExpandedViews(_ views: [UIView]) {
        // Remove current items
        slidingMenuView.stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        // Add new ones
        for view in views { slidingMenuView.stackView.addArrangedSubview(view) }
    }
}
