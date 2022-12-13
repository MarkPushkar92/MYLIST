//
//  FooterView.swift
//  MYLIST
//
//  Created by Марк Пушкарь on 07.12.2022.
//

import Foundation
import UIKit

class FooterView: UITableViewHeaderFooterView {
    
    let button: UIButton = {
        let button = UIButton()
        button.toAutoLayout()
        button.setImage(UIImage(named: "map"), for: .normal)
        return button
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupImageView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupImageView() {
        contentView.addSubview(button)
        let constraints = [
            button.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            button.heightAnchor.constraint(equalToConstant: 100),
            button.widthAnchor.constraint(equalToConstant: 100)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

 
