//
//  SlidingMenuView.swift
//  Carrier Game
//
//  Created by Sean G Young on 3/3/19.
//  Copyright © 2019 Sean G Young. All rights reserved.
//

import UIKit

class SlidingMenuView: UIView {
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    private(set) lazy var stackView: UIStackView = {
        let view = UIStackView(translatesAutoresizingMask: false)
        view.distribution = .fillEqually
        return view
    }()
    
    // MARK: - Methods

    private func setup() {
        addSubview(stackView)
        NSLayoutConstraint.constraintsPinningView(stackView).activate()
    }
}
