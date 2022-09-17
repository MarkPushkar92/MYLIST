//
//  TableViewCell.swift
//  MYLIST
//
//  Created by Марк Пушкарь on 12.09.2022.
//

import UIKit

class TableViewCell: UITableViewCell {

    var image: UIImageView = {
        let imageView = UIImageView()
        imageView.toAutoLayout()
        imageView.layer.cornerRadius = 65/2
        imageView.clipsToBounds = true
        return imageView
    }()
    
    var nameLabel: UILabel = {
        let label = UILabel()
        label.toAutoLayout()
        return label
    }()
    
    var locationLabel: UILabel = {
        let label = UILabel()
        label.toAutoLayout()
        return label
    }()
    
    var typeLabel: UILabel = {
        let label = UILabel()
        label.toAutoLayout()
        return label
    }()
    
    private let labelsStackView: UIStackView = {
        let stack = UIStackView()
        stack.toAutoLayout()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        labelsStackView.addArrangedSubview(nameLabel)
        labelsStackView.addArrangedSubview(locationLabel)
        labelsStackView.addArrangedSubview(typeLabel)

        contentView.addSubviews(image, labelsStackView)
        let constraints = [
            image.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            image.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            image.heightAnchor.constraint(equalToConstant: 65),
            image.widthAnchor.constraint(equalToConstant: 65),
            
            labelsStackView.leadingAnchor.constraint(equalTo: image.trailingAnchor, constant: 20),
            labelsStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            labelsStackView.heightAnchor.constraint(equalTo: image.heightAnchor)
            
        ]
        
        NSLayoutConstraint.activate(constraints)
    }

}
