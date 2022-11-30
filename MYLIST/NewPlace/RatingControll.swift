//
//  RatingControll.swift
//  MYLIST
//
//  Created by Марк Пушкарь on 30.11.2022.
//

import UIKit

class RatingControll: UIStackView {
    
    // MARK: Propreties
    
    private var ratingButtons = [UIButton]()
    
    var rating = 0

    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .blue
        setupButtons()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Private methods
    
    private func setupButtons() {
        for _ in 1 ... 5 {
            let button = UIButton()
            button.addTarget(self, action: #selector(ratingButtonTapped), for: .touchUpInside)
            button.toAutoLayout()
            button.backgroundColor = .red
            addArrangedSubview(button)
//            let constraints = [
//                button.heightAnchor.constraint(equalToConstant: 44),
//                button.widthAnchor.constraint(equalToConstant: 44),
//            ]
//            NSLayoutConstraint.activate(constraints)
            ratingButtons.append(button)
        }
    }
    
    @objc func ratingButtonTapped() {
        print("butttonnn presssed")
    }
    
    
    
}
