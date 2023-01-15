//
//  MapViewController.swift
//  MYLIST
//
//  Created by Марк Пушкарь on 07.12.2022.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegate {
    func getAddress(address: String?)
}

class MapViewController: UIViewController {
    
    //MARK: UI properties
    
    var addressLabel: UILabel = {
        let view = UILabel()
        view.toAutoLayout()
        view.sizeToFit()
        view.text = ""
        view.textAlignment = .center
        view.isHidden = true
        return view
    }()
    
    var doneButton: UIButton = {
        let view = UIButton()
        view.toAutoLayout()
        view.backgroundColor = .black
        view.setTitle("Done", for: .normal)
        view.layer.cornerRadius = 10
        view.isHidden = true
        return view
    }()
    
    var marker: UIImageView = {
        let view = UIImageView()
        view.toAutoLayout()
        view.image = UIImage(named: "Pin")
        view.isHidden = true
        return view
    }()
    
    private let userLocationbutton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "Location"), for: .normal)
        button.toAutoLayout()
        return button
    }()
    
     let getDirectionsbutton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "GetDirection"), for: .normal)
        button.isHidden = true
        button.toAutoLayout()
        return button
    }()
    
    //MARK: properties
    
    let mapManager = MapManager()
    
    private var previousLocation: CLLocation? {
        didSet {
            mapManager.startTrackingUserLocation(
                for: map,
                and: previousLocation) { (currentLocation) in
                    self.previousLocation = currentLocation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.mapManager.showUserLocation(map: self.map)
                    }
                }
        }
    }
    
    var mapViewControllerDelegate: MapViewControllerDelegate?
    
    var place = Place()
    
    private let annotationID = "annotationID"

    private let map = MKMapView()
    
    private let locationManager = CLLocationManager()
    
    //MARK: lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        map.delegate = self
        mapManager.checkLOcationServises(map: map) {
            mapManager.locationManager.delegate = self
        }
        mapManager.setupPlacemark(place: place, map: map)
    }
    
    //MARK: Private methods
    
    @objc private func centerViewInUserLocation() {
        mapManager.showUserLocation(map: map)
    }
    
    @objc private func doneButtonPressed() {
        mapViewControllerDelegate?.getAddress(address: addressLabel.text)
        dismiss(animated: true)
    }
    
    @objc private func goButtonPressed() {
        print("hello")
        mapManager.getDirections(for: map) { (location) in
            self.previousLocation = location
        }
    }
    
    private func setupViews() {
        map.addSubviews(userLocationbutton, marker, addressLabel, doneButton, getDirectionsbutton)
        view.addSubview(map)
        map.toAutoLayout()
        getDirectionsbutton.addTarget(self, action: #selector(goButtonPressed), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
        userLocationbutton.addTarget(self, action: #selector(centerViewInUserLocation), for: .touchUpInside)
        let constraints = [
            marker.widthAnchor.constraint(equalToConstant: 50),
            marker.heightAnchor.constraint(equalToConstant: 50),
            marker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            marker.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -25),
            
            doneButton.widthAnchor.constraint(equalToConstant: 70),
            doneButton.heightAnchor.constraint(equalToConstant: 25),
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            
            getDirectionsbutton.widthAnchor.constraint(equalToConstant: 50),
            getDirectionsbutton.heightAnchor.constraint(equalToConstant: 50),
            getDirectionsbutton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            getDirectionsbutton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            
            addressLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            addressLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            addressLabel.widthAnchor.constraint(equalTo: view.widthAnchor),
                        
            userLocationbutton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            userLocationbutton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            userLocationbutton.widthAnchor.constraint(equalToConstant: 50),
            userLocationbutton.heightAnchor.constraint(equalToConstant: 50),

            map.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            map.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            map.topAnchor.constraint(equalTo: view.topAnchor),
            map.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

//MARK: extensions

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = mapManager.getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(center) { placemarks, error in
            if let error = error {
                print(error)
                return
            }
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            let streetName = placemark?.thoroughfare
            let buildNumber = placemark?.subThoroughfare
            DispatchQueue.main.async {
                if streetName != nil && buildNumber != nil {
                    self.addressLabel.text = "\(streetName!), \(buildNumber!)"
                } else if streetName != nil {
                    self.addressLabel.text = "\(streetName!)"
                } else {
                    self.addressLabel.text = ""
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        var annotationView = map.dequeueReusableAnnotationView(withIdentifier: annotationID) as? MKPinAnnotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationID)
            annotationView?.canShowCallout = true
        }
        if let imageData = place.imageData {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            annotationView?.rightCalloutAccessoryView = imageView
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        return renderer
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        mapManager.checkLocationAutherization(map: map)
    }
}
