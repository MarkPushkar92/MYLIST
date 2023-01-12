//
//  NewPlaceTableViewCell.swift
//  MYLIST
//
//  Created by Марк Пушкарь on 17.09.2022.
//

import UIKit


class NewPlaceTableViewCell: UITableViewCell {
    
    var button: UIButton = {
        let button = UIButton()
        button.toAutoLayout()
        button.setImage(UIImage(named: "GetDirection"), for: .normal)
        button.isHidden = true
        return button
    }()
    
    var textField: UITextField = {
        let textField = UITextField()
        textField.toAutoLayout()
        return textField
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
     }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        contentView.addSubview(textField)
        textField.addSubview(button)
        let constraints = [
            button.trailingAnchor.constraint(equalTo: textField.trailingAnchor, constant: -10),
            button.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            button.heightAnchor.constraint(equalToConstant: 30),
            button.widthAnchor.constraint(equalToConstant: 30),
            
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            textField.topAnchor.constraint(equalTo: contentView.topAnchor),
            textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }

}

