//
//  MapViewController.swift
//  MYLIST
//
//  Created by Марк Пушкарь on 07.12.2022.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    let map = MKMapView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        view.addSubview(map)
        map.toAutoLayout()
        let constraints = [
            map.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            map.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            map.topAnchor.constraint(equalTo: view.topAnchor),
            map.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }

}
