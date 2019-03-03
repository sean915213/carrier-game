//
//  SlidingMenuToolbarView.swift
//  Carrier Game
//
//  Created by Sean G Young on 3/3/19.
//  Copyright © 2019 Sean G Young. All rights reserved.
//

import UIKit

class MenuToolbarExpandedItem {
    
    // MARK: - Initialization
    
    init(view: UIView) {
        self.view = view
    }
    
    // MARK: - Properties
    
    let view: UIView
    var staysSelected = false
}

class MenuToolbarItem {
    
    enum Display { case system(UIBarButtonItem.SystemItem), title(String), view(UIView) }
    
    // MARK: - Initialization
    
    init(display: Display) {
        self.display = display
    }
    
    // MARK: - Properties
    
    let display: Display
    var staysSelected = true
    
    fileprivate private(set) lazy var barButton: UIBarButtonItem = {
        switch display {
        case .system(let systemItem):
            return UIBarButtonItem(barButtonSystemItem: systemItem, target: nil, action: nil)
        case .title(let title):
            return UIBarButtonItem(title: title, style: .plain, target: nil, action: nil)
        case .view(let view):
            return UIBarButtonItem(customView: view)
        }
    }()
}

private let animationDuration: TimeInterval = 0.3

protocol SlidingMenuToolbarViewDelegate: AnyObject {
    
    func slidingMenuToolbarView(_ view: SlidingMenuToolbarView, didSelectItem item: MenuToolbarItem)
    func slidingMenuToolbarView(_ view: SlidingMenuToolbarView, didUnselectItem item: MenuToolbarItem)
    func slidingMenuToolbarView(_ view: SlidingMenuToolbarView, expandedItemsFor item: MenuToolbarItem) -> [MenuToolbarExpandedItem]?
}

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
    
    weak var delegate: SlidingMenuToolbarViewDelegate?
    
    var selectionColor: UIColor = .red
    
    var toolbarItems = [MenuToolbarItem]() {
        didSet { updateItems() }
    }
    
    private(set) var selectedItem: MenuToolbarItem?
    
    private var slidingMenuDisplayed = false
    
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
    
    // MARK: - Methods
    
    private func setup() {
        // Add menu item view then toolbar
        addSubviews(slidingMenuView, toolbar)
        // Constrain menu item view
        NSLayoutConstraint.constraintsPinningView(slidingMenuView, axis: .horizontal).activate()
        menuPositionConstraint.activate()
        // Constrain toolbar
        NSLayoutConstraint.constraintsPinningView(toolbar, axis: .horizontal).activate()
        toolbar.bottomAnchor.constraint(equalTo: bottomAnchor).activate()
    }
    
    private func updateItems() {
        var newButtons = [UIBarButtonItem]()
        for item in toolbarItems {
            item.barButton.target = self
            item.barButton.action = #selector(didTapBarButton(_:))
            newButtons.append(item.barButton)
        }
        toolbar.setItems(newButtons, animated: true)
    }
    
    private func showOrUpdateSlidingMenu(with items: [MenuToolbarExpandedItem]) {
        // Assign new items
        setExpandedItems(items)
        // If already displayed then animate change of items
        guard !slidingMenuDisplayed else {
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
        }, completion: nil)
    }
    
    private func hideSlidingMenuIfDisplayed() {
        // Hide only if displayed
        guard slidingMenuDisplayed else { return }
        slidingMenuDisplayed = false
        // Animate out
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: animationDuration, delay: 0, options: .curveEaseOut, animations: {
            // Animate out
            self.menuPositionConstraint.deactivate()
            self.menuPositionConstraint = self.slidingMenuView.topAnchor.constraint(equalTo: self.toolbar.topAnchor).activate()
            self.layoutIfNeeded()
        }) { _ in
            // Remove current views when completed
            self.setExpandedItems([])
        }
    }
    
    private func setExpandedItems(_ items: [MenuToolbarExpandedItem]) {
        // Remove current items
        slidingMenuView.stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        // Add new ones
        for item in items { slidingMenuView.stackView.addArrangedSubview(item.view) }
    }
    
    // MARK: Actions
    
    @objc private func didTapBarButton(_ button: UIBarButtonItem) {
        // Check whether a current selection exists
        if let selection = selectedItem {
            // Change button color
            selection.barButton.tintColor = toolbar.tintColor
            // Remove selection
            selectedItem = nil
            // Inform delegate unselected
            delegate?.slidingMenuToolbarView(self, didUnselectItem: selection)
            // If this is tapped button then only thing left is to hide menu
            guard button != selection.barButton else {
                hideSlidingMenuIfDisplayed()
                return
            }
        }
        // Find new selected item (which should definitely exist)
        let newSelection = toolbarItems.first(where: { $0.barButton == button })!
        // Inform delegate
        delegate?.slidingMenuToolbarView(self, didSelectItem: newSelection)
        // If item doesn't stay selected there's nothing more to do
        guard newSelection.staysSelected else { return }
        // Color selected and assign
        newSelection.barButton.tintColor = selectionColor
        selectedItem = newSelection
        // Ask delegate for expanded items
        guard let expandedItems = delegate?.slidingMenuToolbarView(self, expandedItemsFor: newSelection) else { return }
        // Expand menu
        showOrUpdateSlidingMenu(with: expandedItems)
    }
}
