//
//  SlidingMenuToolbarCell.swift
//  Carrier Game
//
//  Created by Sean G Young on 3/4/19.
//  Copyright © 2019 Sean G Young. All rights reserved.
//

import UIKit

class SlidingMenuToolbarCell: UICollectionViewCell {
    
    static let reuseID = "com.sdot.slidingMenuToolbarCell"
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    let label: UILabel = {
        let label = UILabel(translatesAutoresizingMask: false)
        return label
    }()
    
    override var isSelected: Bool {
        didSet {
            label.textColor = isSelected ? .red: .black
        }
    }
    
    // MARK: - Methods
    
    private func setup() {
        print("&& CELL SETUP")
        contentView.addSubview(label)
        NSLayoutConstraint.constraintsPinningView(label).activate()
    }
}
