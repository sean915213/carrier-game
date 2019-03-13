//
//  SlidingMenuToolbarViewController.swift
//  Carrier Game
//
//  Created by Sean G Young on 3/4/19.
//  Copyright © 2019 Sean G Young. All rights reserved.
//

import UIKit
import SGYSwiftUtility

// TODO NEXT: Confused why collection view flow scroll direction must be set to vertical to layout how I expect?
// TODO REALLY: Standardize after answering above question. Changes to layout done via preferredContentSize changes.

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
        print("== TOOLBAR VIEW DID LAYOUT")
        // Calculate preferred size based on all collection views
        var height = CGFloat.zero
        for collection in menuHierarchy {
//            let collectionHeight = collection.collectionView.contentSize.height
            let collectionHeight = collection.collectionView.collectionViewLayout.collectionViewContentSize.height
            height += collectionHeight
            
            print("@@ COLLECTION VIEW FRAME HEIGHT: \(collection.collectionView.frame.size.height). CONTENT HEIGHT: \(collection.collectionView.collectionViewLayout.collectionViewContentSize.height)")
            print("?? COLLECTION VIEW FRAME ORIGIN: \(collection.collectionView.frame.origin)")
            
//            collection.heightConstraint.constant = collection.collectionView.collectionViewLayout.collectionViewContentSize.height
        }
        
        print("&& TOTAL HEIGHT: \(height). FOR COUNT: \(menuHierarchy.count)")
        preferredContentSize = CGSize(width: -1, height: height)
        
        // Modify preferred content size
//        preferredContentSize = CGSize(width: -1, height: menuHierarchy.first!.collectionView.collectionViewLayout.collectionViewContentSize.height)
    }
    
    override func updateViewConstraints() {
        // Modify menu constraints
        for collection in menuHierarchy {
            //            let collectionHeight = collection.collectionView.contentSize.height
//            let collectionHeight = collection.collectionView.collectionViewLayout.collectionViewContentSize.height
//            height += collectionHeight
//
//            print("@@ COLLECTION VIEW FRAME HEIGHT: \(collection.collectionView.frame.size.height). CONTENT HEIGHT: \(collection.collectionView.collectionViewLayout.collectionViewContentSize.height)")
//            print("?? COLLECTION VIEW FRAME ORIGIN: \(collection.collectionView.frame.origin)")
//
            collection.heightConstraint.constant = collection.collectionView.collectionViewLayout.collectionViewContentSize.height
        }
        
        
        
        
        super.updateViewConstraints()
    }
    
    private func displayNewItems(_ items: [MenuItem], for expandedItem: MenuItem?) {
        // Make a new collection view and add
        let collectionView = makeCollectionView()
        
        if menuHierarchy.count == 1 {
            print("!! CHANGIG BG COLOR")
            collectionView.backgroundColor = .red
        }
        
        
        stackView.insertArrangedSubview(collectionView, at: 0)
        
        print("## INSERTED NEW ITEM. STACK COUNT: \(stackView.arrangedSubviews.count)")
        
//        // Constrain
//        // - VERTICAL
//        // Top
//        let topAnchorConstraint = collectionView.topAnchor.constraint(equalTo: view.topAnchor)
//        topAnchorConstraint.identifier = "top.anchor"
//        topAnchorConstraint.activate()
//        // Bottom
//        let bottomAnchor = menuHierarchy.first?.collectionView.topAnchor ?? view.bottomAnchor
//        let bottomAnchorConstraint = collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).activate()
//        bottomAnchorConstraint.identifier = "bottom.anchor"
//        // - HORIZONTAL
//        NSLayoutConstraint.constraintsPinningView(collectionView, axis: .horizontal).activate()
        
        // Modify current leading menu (if it exists)
        if let item = expandedItem {
            var leadingCollection = menuHierarchy.removeLast()
            leadingCollection.expanded = item
            menuHierarchy.append(leadingCollection)
//            // Modify bottom constrain
//            let bottomAnchorConstraint =
        }
        
        
        // Add to menu hierarchy
        
        let heightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 1).activate()
//        view.setNeedsUpdateConstraints()
        menuHierarchy.append((items: items, collectionView: collectionView, heightConstraint: heightConstraint, expanded: nil))
        
        // Need to perform a reload to get contentSize set properly and therefore update preferredContentSize
        collectionView.performBatchUpdates({
            collectionView.reloadSections(IndexSet(integer: 0))
        }, completion: { _ in
            print("&& BATCH COMPLETION")
            self.view.setNeedsUpdateConstraints()
            self.view.setNeedsLayout()
        })
        
        
        
//        // Make a new collection view and add
//        let collectionView = makeCollectionView()
//        view.addSubview(collectionView)
//        // Constrain
//        // - VERTICAL
//        // Top
//        let topAnchorConstraint = collectionView.topAnchor.constraint(equalTo: view.topAnchor)
//        topAnchorConstraint.identifier = "top.anchor"
//        topAnchorConstraint.activate()
//        // Bottom
//        let bottomAnchor = menuHierarchy.first?.collectionView.topAnchor ?? view.bottomAnchor
//        let bottomAnchorConstraint = collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).activate()
//        bottomAnchorConstraint.identifier = "bottom.anchor"
//        // - HORIZONTAL
//        NSLayoutConstraint.constraintsPinningView(collectionView, axis: .horizontal).activate()
//
//        // Modify current leading menu (if it exists)
//        if let item = expandedItem {
//            var leadingCollection = menuHierarchy.removeLast()
//            leadingCollection.expanded = item
//            menuHierarchy.append(leadingCollection)
//            // Modify bottom constrain
//            let bottomAnchorConstraint =
//        }
//        // Add to menu hierarchy
//        menuHierarchy.append((items: items, collectionView: collectionView, expanded: nil))
//
//        // Need to perform a reload to get contentSize set properly and therefore update preferredContentSize
//        collectionView.performBatchUpdates({
//            collectionView.reloadSections(IndexSet(integer: 0))
//        }, completion: nil)
    }
    
//    private func collapseMostRecentItems() {
//        let itemCollection = menuHierarchy.removeLast()
//        // Remove collection view
//        itemCollection.collectionView.removeFromSuperview()
//        // Add new constraint on previous collectionView
//        if let previousCollectionView = menuHierarchy.last?.collectionView {
//            previousCollectionView.topAnchor.constraint(equalTo: view.topAnchor).activate()
//        }
//    }
    
    private func collapseMenu(toIndex index: Int?) {
        
        print("&& COLLAPSING TO INDEX: \(index)")
        
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
        
//        var topAnchorConstraint = view.constraints.first(where: { $0.identifier == "top.anchor" })!
//        topAnchorConstraint.deactivate()
//        topAnchorConstraint = leadingMenu.collectionView.topAnchor.constraint(equalTo: view.topAnchor).activate()
//        topAnchorConstraint.identifier = "top.anchor"
        
        // Nil expanded item and re-assign menu
        leadingMenu.expanded = nil
        menuHierarchy.append(leadingMenu)
        
//        self.view.setNeedsUpdateConstraints()
        self.view.setNeedsLayout()
    }
    
    private func makeCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        
//        layout.scrollDirection = .horizontal
        layout.scrollDirection = .vertical
        // TODO: Better estimate?
        layout.estimatedItemSize = CGSize(width: 1, height: 1)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.dataSource = self
        view.delegate = self
        view.allowsMultipleSelection = true
        
//        view.heightAnchor.constraint(equalToConstant: 1).withPriority(.defaultLow).activate()
        
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
        print("&& SELECTED: \(indexPath)")
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
        
        
        
        
        
//        // Get index in hierarchy
//        let selectedMenuIndex = indexOfItemCollection(with: collectionView)
//        // Collapse menu to this location
//        collapseMenu(toIndex: selectedMenuIndex)
//
//        // Get selected item collection and item
//        let selectedCollection = menuHierarchy[selectedMenuIndex]
//        let selectedItem = selectedCollection.items[indexPath.row]
//        // Check whether a currently selected item exists
//        if let expandedItem = selectedCollection.expanded {
//            // Current selection will be deselected regardless
//            print("&& SELECTED AN EXPANDED ITEM.")
//            collectionView.deselectItem(at: indexPath, animated: true)
//            // If this was the expanded item then nothing left to do
//            guard expandedItem.identifier != selectedItem.identifier else { return }
//        }
//
//
//
//
//        // TODO: BE SAFER
//        let selectedItem = menuHierarchy.first(where: { $0.collectionView == collectionView })!.items[indexPath.row]
//        let nextItems = delegate?.slidingMenuViewController(self, itemsForSelectedItem: selectedItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("-- DE-SELECT: \(indexPath)")
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