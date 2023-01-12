//
//  NewPlaceTableViewCell.swift
//  MYLIST
//
//  Created by Марк Пушкарь on 17.09.2022.
//

import UIKit


class NewPlaceTableViewCell: UITableViewCell {
    
    var selectLocationbutton: UIButton = {
        let button = UIButton()
        button.toAutoLayout()
        button.setImage(UIImage(named: "GetDirection"), for: .normal)
        button.isHidden = true
        return button
    }()
    
    var textField: UITextField?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
     }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        
        guard let textField = textField else { return }
        textField.toAutoLayout()
        contentView.addSubview(textField)
        textField.addSubview(selectLocationbutton)
        let constraints = [
            selectLocationbutton.trailingAnchor.constraint(equalTo: textField.trailingAnchor, constant: -10),
            selectLocationbutton.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            selectLocationbutton.heightAnchor.constraint(equalToConstant: 30),
            selectLocationbutton.widthAnchor.constraint(equalToConstant: 30),
            
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            textField.topAnchor.constraint(equalTo: contentView.topAnchor),
            textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }

}

