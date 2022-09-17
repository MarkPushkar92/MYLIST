//
//  NewPlaceViewController.swift
//  MYLIST
//
//  Created by Марк Пушкарь on 16.09.2022.
//

import Foundation
import UIKit

class NewPlaceViewController: UIViewController {
    
    //MARK: PROPERTIES
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .white
        tableView.toAutoLayout()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(NewPlaceTableViewCell.self, forCellReuseIdentifier: cellID)
        return tableView
    }()
    
    private let cellID = "cellID"
   
    
    //MARK: FUNCS
    
    @objc func saveButtonPressed() {
        print("save button pressed")
    }
    
    //MARK: LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
    }
}

//MARK: EXTENSIONS

extension NewPlaceViewController: UITableViewDataSource {
         
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! NewPlaceTableViewCell
        switch indexPath.row {
            case 0:
            cell.setupImageView()
            case 1:
            cell.setupViews()
            cell.textField.placeholder = "Enter location name"
            case 2:
            cell.setupViews()
            cell.textField.placeholder = "Enter location"
            case 3:
            cell.setupViews()
            cell.textField.placeholder = "Enter location type"
            default:
            break
        }
        return cell
    }
}

extension NewPlaceViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
            case 0:
            return 180
            default:
            return 50
        }
    }
    
}

private extension NewPlaceViewController {
    func setupViews() {
        navigationController?.navigationBar.topItem?.title = "My List"
        view.addSubview(tableView)
        view.backgroundColor = .systemBackground
        let constraints = [
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveButtonPressed))
        navigationItem.rightBarButtonItem = saveButton
    }
    
    
}

