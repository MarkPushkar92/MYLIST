//
//  ViewController.swift
//  MYLIST
//
//  Created by Марк Пушкарь on 12.09.2022.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    
    //MARK: PROPERTIES
    
    var places: Results<Place>!
    
    private let segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Date","Name"])
        segmentedControl.toAutoLayout()
        return segmentedControl
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .white
        tableView.toAutoLayout()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TableViewCell.self, forCellReuseIdentifier: cellID)
        return tableView
    }()
    
    private let cellID = "cellID"
    
    private var ascendindSorting = true

    //MARK: FUNCS
    
    @objc private func addButtonPressed() {
        navigationController?.pushViewController(NewPlaceViewController(), animated: true)
    }
    
    @objc private func reversedSorting() {
        print("reversed sorting button pressed")
        ascendindSorting.toggle()
        if ascendindSorting {
            navigationItem.leftBarButtonItem?.image = UIImage(named: "ZA")
        } else {
            navigationItem.leftBarButtonItem?.image = UIImage(named: "AZ")
        }
        sorting()
    }
    
    @objc private func sortSelection(_ sender: UISegmentedControl) {
        sorting()
    }
    
    private func sorting() {
        if segmentedControl.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "date", ascending: ascendindSorting)
        } else {
            places = places.sorted(byKeyPath: "name", ascending: ascendindSorting)
        }
        tableView.reloadData()
    }
    //MARK: LIFECYCLE
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        places = realm.objects(Place.self)
    }
}

//MARK: EXTENSIONS

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.isEmpty ? 0 :  places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! TableViewCell
        let place = places[indexPath.row]
        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.image.image = UIImage(data: place.imageData!)
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let place = places[indexPath.row]
            StorageManager.deleteObj(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = NewPlaceViewController()
        let place = places[indexPath.row]
        vc.currentPlace = place
        navigationController?.pushViewController(vc, animated: true)
    }
}

private extension ViewController {
    func setupViews() {
        view.addSubview(segmentedControl)
        navigationController?.navigationBar.topItem?.title = "My List"
        view.addSubview(tableView)
        view.backgroundColor = .systemBackground
        let constraints = [
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        let addPlaceButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
        navigationItem.rightBarButtonItem = addPlaceButton
        let sortButton = UIBarButtonItem(image: UIImage(named: "AZ"), style: .plain, target: self, action: #selector(reversedSorting))
        navigationItem.leftBarButtonItem = sortButton
        segmentedControl.addTarget(self, action: #selector(sortSelection), for: .valueChanged)
    }
}
