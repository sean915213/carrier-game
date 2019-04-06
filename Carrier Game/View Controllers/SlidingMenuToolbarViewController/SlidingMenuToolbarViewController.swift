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
    
    func slidingMenuViewController(_: SlidingMenuToolbarViewController, shouldSelectTappedItem: SlidingMenuToolbarViewController.MenuItem) -> Bool
    
    func slidingMenuViewController(_: SlidingMenuToolbarViewController, itemsForSelectedItem: SlidingMenuToolbarViewController.MenuItem?) -> [SlidingMenuToolbarViewController.MenuItem]?
    
    func slidingMenuViewController(_: SlidingMenuToolbarViewController, deselectedItem: SlidingMenuToolbarViewController.MenuItem)
    
}

class SlidingMenuToolbarViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    class ItemCollection {
        
        init(items: [MenuItem], collectionView: UICollectionView, heightConstraint: NSLayoutConstraint) {
            self.items = items
            self.collectionView = collectionView
            self.heightConstraint = heightConstraint
        }
        
        var items: [MenuItem]
        var collectionView: UICollectionView
        var heightConstraint: NSLayoutConstraint
        
        var expandedIndex: Int?
//        var selectedIndices = Set<Int>()
    }
    
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
            displayNewItems(rootItems, from: nil)
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
    
    func deselectItem(withIdentifier identifier: String, animated: Bool = true) {
        let itemCollectionIndex = menuHierarchy.firstIndex(where: { $0.items.contains(where: { $0.identifier == identifier }) })!
        let itemCollection = menuHierarchy[itemCollectionIndex]
        let itemRowIndex = itemCollection.items.firstIndex(where: { $0.identifier == identifier })!
        // Deselect in item collection
        itemCollection.collectionView.deselectItem(at: IndexPath(row: itemRowIndex, section: 0), animated: animated)
        
        // Check whether this is the expanded item. If so, collapse to this index
        if itemCollection.expandedIndex != nil, identifier == itemCollection.items[itemRowIndex].identifier {
            collapseMenu(toIndex: itemCollectionIndex)
        }
    }
    
    private func displayNewItems(_ items: [MenuItem], from leadingMenuItemIndex: Int?) {
        // Make a new collection view and insert into stack as first item
        let collectionView = makeCollectionView()
        // TODO: Change based on orientation
        stackView.insertArrangedSubview(collectionView, at: 0)
        // Make height constraint
        let heightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 1).withPriority(.defaultHigh).activate()
        // Make item collection
        let newCollection = ItemCollection(items: items, collectionView: collectionView, heightConstraint: heightConstraint)
        // Modify current leading collection entry (if it exists) before adding new collection
        if let leadingMenuItemIndex = leadingMenuItemIndex {
            // Get leading collection (expect this must exists if leading item index passed)
            let leadingCollection = menuHierarchy.last!
            leadingCollection.expandedIndex = leadingMenuItemIndex
        }
        // Add to menu hierarchy
        menuHierarchy.append(newCollection)
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
            let itemCollection = menuHierarchy.remove(at: i)
            // Remove collection view
            itemCollection.collectionView.removeFromSuperview()
        }
        // Need a layout to update preferredContentSize
        defer { view.setNeedsLayout() }
        // Check whether a menu item remains
        guard let leadingCollection = menuHierarchy.last else { return }
        // Nil expanded index
        leadingCollection.expandedIndex = nil
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
    
    private func menuItemFor(collectionView: UICollectionView, at index: Int) -> SlidingMenuToolbarViewController.MenuItem? {
        let selectedMenuIndex = indexOfItemCollection(with: collectionView)
        let itemCollection = menuHierarchy[selectedMenuIndex]
        return itemCollection.items[index]
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
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let menuItem = menuItemFor(collectionView: collectionView, at: indexPath.row)!
        return delegate?.slidingMenuViewController(self, shouldSelectTappedItem: menuItem) != false
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Get index & collection from hierarchy
        let selectedMenuIndex = indexOfItemCollection(with: collectionView)
        let itemCollection = menuHierarchy[selectedMenuIndex]
        let selectedItem = menuItemFor(collectionView: collectionView, at: indexPath.row)!
        // If delegate provides new menu items then expand further (and deselect other expanded items)
        guard let expandedItems = delegate?.slidingMenuViewController(self, itemsForSelectedItem: selectedItem), !expandedItems.isEmpty else {
            return
        }
        // If item collection has a currently expanded item then deselect it
        if let expandedIndex = itemCollection.expandedIndex {
            collectionView.deselectItem(at: IndexPath(row: expandedIndex, section: 0), animated: true)
        }
        // Expanded items replace any expansion up until now so collapse to this menu
        collapseMenu(toIndex: selectedMenuIndex)
        // Display new items
        displayNewItems(expandedItems, from: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let deselectedItem = menuItemFor(collectionView: collectionView, at: indexPath.row)!
        deselectItem(withIdentifier: deselectedItem.identifier, animated: true)
        // Notify delegate
        delegate?.slidingMenuViewController(self, deselectedItem: deselectedItem)
    }
}
