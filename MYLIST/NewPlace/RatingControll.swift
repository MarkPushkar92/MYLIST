//
//  RatingControll.swift
//  MYLIST
//
//  Created by Марк Пушкарь on 30.11.2022.
//

import UIKit

class RatingControll: UIStackView {
    
    // MARK: Propreties
    
   // private var starSize: CGSize = CGSize(width: 44, height: 44)
    
    private var starCount: Int = 5
    
    private var ratingButtons = [UIButton]()
    
    var rating = 0 {
        didSet {
            updateButtonSelectionStates()
        }
    }

    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Private methods
    
    private func setupButtons() {
        
        let filledStar = UIImage(named: "filledStar")
        let emptyStar = UIImage(named: "emptyStar")
        let highlightedStar = UIImage(named: "highlightedStar")
        
        for _ in 1 ... starCount {
            let button = UIButton()
            button.addTarget(self, action: #selector(ratingButtonTapped), for: .touchUpInside)
            button.toAutoLayout()
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(highlightedStar, for: .highlighted)
            button.setImage(highlightedStar, for: [.highlighted, .selected])
            addArrangedSubview(button)
            ratingButtons.append(button)
        }
        updateButtonSelectionStates()
        print(ratingButtons.count)
    }
    
    @objc func ratingButtonTapped(button: UIButton) {
        print("butttonnn presssed")
        
        guard let index = ratingButtons.firstIndex(of: button) else  { return }
        let selectedRating = index + 1
        if selectedRating == rating {
            rating = 0
        } else {
            rating = selectedRating
        }
    }
    
    private func updateButtonSelectionStates() {
        for (index, button) in ratingButtons.enumerated() {
            button.isSelected = index < rating
        }
    }
}
