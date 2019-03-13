//
//  SlidingMenuToolbarViewController.swift
//  Carrier Game
//
//  Created by Sean G Young on 3/4/19.
//  Copyright © 2019 Sean G Young. All rights reserved.
//

import UIKit
import SGYSwiftUtility

protocol SlidingMenuToolbarViewControllerDelegate: AnyObject {
    
    func slidingMenuViewController(_: SlidingMenuToolbarViewController, itemsForSelectedItem: SlidingMenuToolbarViewController.MenuItem?) -> [SlidingMenuToolbarViewController.MenuItem]?
    
    func slidingMenuViewController(_: SlidingMenuToolbarViewController, deselectedItem: SlidingMenuToolbarViewController.MenuItem)
    
}

class SlidingMenuToolbarViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    typealias ItemCollection = (items: [MenuItem], collectionView: UICollectionView, heightConstraint: NSLayoutConstraint, expanded: MenuItem?)
    
    class MenuItem {
        
        enum ItemType { case text(String) }
        
        init(type: ItemType, identifier: String) {
            self.type = type
            self.identifier = identifier
        }
        
        let type: ItemType
        let identifier: String
    }
    
    // MARK: - Initialization
    
    // MARK: - Properties
    
    weak var delegate: SlidingMenuToolbarViewControllerDelegate?
    
    private lazy var menuHierarchy = [ItemCollection]()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(translatesAutoresizingMask: false)
        stack.axis = .vertical
        stack.distribution = UIStackView.Distribution.fill
        stack.alignment = UIStackView.Alignment.fill
        return stack
    }()
    
    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(stackView)
        NSLayoutConstraint.constraintsPinningView(stackView).activate()
        // Ask delegate for initial items
        if let rootItems = delegate?.slidingMenuViewController(self, itemsForSelectedItem: nil) {
            displayNewItems(rootItems, for: nil)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Calculate preferred size based on all collection views
        var height = CGFloat.zero
        for collection in menuHierarchy {
            // Add the flow layout's calculate height since that's what the view uses
            height += collection.collectionView.collectionViewLayout.collectionViewContentSize.height
        }
        // Assign new size.
        // TODO: Change assigned size and calculation based on orientation
        preferredContentSize = CGSize(width: -1, height: height)
    }
    
    override func updateViewConstraints() {
        // Modify each collection view's constraints
        for collection in menuHierarchy {
            // TODO: Change based on orientation
            collection.heightConstraint.constant = collection.collectionView.collectionViewLayout.collectionViewContentSize.height
        }
        super.updateViewConstraints()
    }
    
    private func displayNewItems(_ items: [MenuItem], for expandedItem: MenuItem?) {
        // Make a new collection view and insert into stack as first item
        let collectionView = makeCollectionView()
        // TODO: Change based on orientation
        stackView.insertArrangedSubview(collectionView, at: 0)
        // Modify current leading collection entry (if it exists)
        if let item = expandedItem {
            var leadingCollection = menuHierarchy.removeLast()
            leadingCollection.expanded = item
            menuHierarchy.append(leadingCollection)
        }
        // Add expanded items to hierarchy
        let heightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 1).withPriority(.defaultHigh).activate()
        menuHierarchy.append((items: items, collectionView: collectionView, heightConstraint: heightConstraint, expanded: nil))
        // Need to perform a reload to get contentSize set properly and therefore update preferredContentSize
        collectionView.performBatchUpdates({
            collectionView.reloadSections(IndexSet(integer: 0))
        }, completion: { _ in
            // Must call both to perform proper update
            self.view.setNeedsUpdateConstraints()
            self.view.setNeedsLayout()
        })
    }
    
    private func collapseMenu(toIndex index: Int?) {
        // Iterate through hierarchy backwards
        for i in (0..<menuHierarchy.endIndex).reversed() {
            guard i != index else { break }
            let collectionView = menuHierarchy[i].collectionView
            collectionView.removeFromSuperview()
            menuHierarchy.remove(at: i)
        }
        // Check whether a menu item remains
        guard !menuHierarchy.isEmpty else { return }
        // Remove last to modify
        var leadingMenu = menuHierarchy.removeLast()
        // Nil expanded item and re-assign menu
        leadingMenu.expanded = nil
        menuHierarchy.append(leadingMenu)
        // Need a layout to update preferredContentSize
        view.setNeedsLayout()
    }
    
    private func makeCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        // TODO: MODIFY FOR ORIENTATION
        layout.scrollDirection = .vertical
        // TODO: Better estimate?
        layout.estimatedItemSize = CGSize(width: 1, height: 1)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.dataSource = self
        view.delegate = self
        view.allowsMultipleSelection = true
        // Register cells
        view.register(SlidingMenuToolbarCell.self, forCellWithReuseIdentifier: SlidingMenuToolbarCell.reuseID)
        return view
    }
    
    private func indexOfItemCollection(with collectionView: UICollectionView) -> Int {
        return menuHierarchy.firstIndex(where: { $0.collectionView == collectionView })!
    }
    
    // MARK: UICollectionView DataSource Implementation
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Return item count
        let items = menuHierarchy[indexOfItemCollection(with: collectionView)].items
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Determine cell to use
        let items = menuHierarchy[indexOfItemCollection(with: collectionView)].items
        switch items[indexPath.row].type {
        case .text(let text):
            let cell: SlidingMenuToolbarCell = collectionView.dequeueReusableCell(withReuseIdentifier: SlidingMenuToolbarCell.reuseID, for: indexPath)
            cell.label.text = text
            return cell
        }
    }
    
    // MARK: UICollectionView Delegate Implementation
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Get index & collection from hierarchy
        let selectedMenuIndex = indexOfItemCollection(with: collectionView)
        let itemCollection = menuHierarchy[selectedMenuIndex]
        let selectedItem = itemCollection.items[indexPath.row]
        // If delegate provides new menu items then expand further
        guard let expandedItems = delegate?.slidingMenuViewController(self, itemsForSelectedItem: selectedItem) else {
            return
        }
        // Expanded items replace any expansion up until now so collapse to this menu
        collapseMenu(toIndex: selectedMenuIndex)
        // Display new items
        displayNewItems(expandedItems, for: selectedItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        // Get index & collection from hierarchy
        let selectedMenuIndex = indexOfItemCollection(with: collectionView)
        let itemCollection = menuHierarchy[selectedMenuIndex]
        let item = itemCollection.items[indexPath.row]
        // Check whether this is the expanded item. If so, collapse to this index
        if let expandedItem = itemCollection.expanded, expandedItem.identifier == item.identifier {
            collapseMenu(toIndex: selectedMenuIndex)
        }
        // Notify delegate
        delegate?.slidingMenuViewController(self, deselectedItem: item)
    }
}
