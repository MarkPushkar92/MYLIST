//
//  Header.swift
//  MYLIST
//
//  Created by Марк Пушкарь on 23.09.2022.
//

import Foundation
import UIKit

class NewPlaceHeaderView: UITableViewHeaderFooterView {
    
    var image: UIImageView = {
        let imageView = UIImageView()
        imageView.toAutoLayout()
        imageView.contentMode = .center
        imageView.backgroundColor = .lightGray
        imageView.image = UIImage(named: "Photo")
        return imageView
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupImageView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupImageView() {
        contentView.addSubview(image)
        let constraints = [
            image.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            image.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            image.topAnchor.constraint(equalTo: contentView.topAnchor),
            image.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

 
