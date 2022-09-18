//
//  NewPlaceTableViewCell.swift
//  MYLIST
//
//  Created by Марк Пушкарь on 17.09.2022.
//

import UIKit

class NewPlaceTableViewCell: UITableViewCell {
    
    var image: UIImageView = {
        let imageView = UIImageView()
        imageView.toAutoLayout()
        imageView.contentMode = .center
        imageView.backgroundColor = .lightGray
        imageView.image = UIImage(named: "Photo")
        return imageView
    }()
    
    var textField: UITextField = {
        let textField = UITextField()
        textField.toAutoLayout()
        return textField
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
     }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        contentView.addSubview(textField)
        let constraints = [
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            textField.heightAnchor.constraint(equalTo: contentView.heightAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    func setupImageView() {
        contentView.addSubview(image)
        let constraints = [
            image.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            image.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            image.heightAnchor.constraint(equalTo: contentView.heightAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}


