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
    
    private var placeCoordinate: CLLocationCoordinate2D?
    
    var mapViewControllerDelegate: MapViewControllerDelegate?
    
    var place = Place()
    
    private let annotationID = "annotationID"

    private let map = MKMapView()
    
    private let locationManager = CLLocationManager()
    
    //MARK: lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlacemark()
        setupViews()
        map.delegate = self
        checkLOcationServises()
    }
    
    //MARK: Location and Map Methods
    
    @objc private func getDirections() {
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location's not found")
            return
        }
        guard let request = createDirectionsRequest(from: location) else {
            showAlert(title: "Error", message: "Destination's not found")
            return
        }
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if let error = error {
                print(error)
                return
            }
            guard let response = response else {
                self.showAlert(title: "Error", message: "Direction's not available")
                return
            }
            for route in response.routes {
                self.map.addOverlay(route.polyline)
                self.map.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = route.expectedTravelTime
                print("Расстояние до места \(distance) км")
                print("Время в пути \(timeInterval) сек.")
            }
        }
    }
    
    private func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        guard let destinationCoordinate = placeCoordinate else { return nil }
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .walking
        request.requestsAlternateRoutes = true
        return request
    }
    
    
    private func checkLOcationServises() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAutherization()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.showAlert(title: "Location is not available", message: "Give permission is Settings -> My List -> Location")
            }
        }
    }
    
    private func checkLocationAutherization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            map.showsUserLocation = true
            break
        case .denied:
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.showAlert(title: "Location is not available", message: "Give permission is Settings -> My List -> Location")
            }
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.showAlert(title: "Location is not available", message: "Give permission is Settings -> My List -> Location")
            }
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("New case is available")
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func setupPlacemark() {
        guard let location = place.location else { return }
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { placemarks, error in
            if let error = error {
                print(error)
                return
            }
            guard let placemarks = placemarks else { return}
            let placemark = placemarks.first
            let annotation = MKPointAnnotation()
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            guard let placemarkLocation = placemark?.location else { return }
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate
            self.map.showAnnotations([annotation], animated: true)
            self.map.selectAnnotation(annotation, animated: true)
        }
    }
    
    private func showUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: 10000, longitudinalMeters: 10000)
            map.setRegion(region, animated: true)
        }
    }
    
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = map.centerCoordinate.latitude
        let longitude = map.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
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

    //MARK: UI Methods
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    @objc private func centerViewInUserLocation() {
        showUserLocation()
    }
    
    @objc private func doneButtonPressed() {
        mapViewControllerDelegate?.getAddress(address: addressLabel.text)
        dismiss(animated: true)
    }
    
    private func setupViews() {
        map.addSubviews(userLocationbutton, marker, addressLabel, doneButton, getDirectionsbutton)
        view.addSubview(map)
        map.toAutoLayout()
        getDirectionsbutton.addTarget(self, action: #selector(getDirections), for: .touchUpInside)
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
        checkLocationAutherization()
    }
}
