//
//  MapManager.swift
//  MYLIST
//
//  Created by Марк Пушкарь on 15.01.2023.
//

import UIKit
import MapKit

class MapManager {
    
    let locationManager = CLLocationManager()
    
    private var directionsArray: [MKDirections] = []
    private var placeCoordinate: CLLocationCoordinate2D?
    
    // Маркер заведения
    func setupPlacemark(place: Place, map: MKMapView) {
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
            annotation.title = place.name
            annotation.subtitle = place.type
            guard let placemarkLocation = placemark?.location else { return }
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate
            map.showAnnotations([annotation], animated: true)
            map.selectAnnotation(annotation, animated: true)
        }
    }
    
    // Проверка доступности сервисов геолокации
    func checkLOcationServises(map: MKMapView, closure: () -> ()) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAutherization(map: map)
            closure()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Location is not available", message: "Give permission is Settings -> My List -> Location")
            }
        }
    }
    
    // Проверка авторизации приложения для исопользования сервисов геолокации
    func checkLocationAutherization(map: MKMapView) {
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
    
    // Фокус карты на местоположении пользователя
    func showUserLocation(map: MKMapView) {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: 1000, longitudinalMeters: 1000)
            map.setRegion(region, animated: true)
        }
    }
    
    // Строим маршрут от местоположения пользователя до заведения
    func getDirections(for map: MKMapView, previousLocation: (CLLocation) -> ()) {
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location's not found")
            return
        }
        
        locationManager.startUpdatingLocation()
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        guard let request = createDirectionsRequest(from: location) else {
            showAlert(title: "Error", message: "Destination's not found")
            return
        }
        let directions = MKDirections(request: request)
        resetMap(withNew: directions, map: map)
        
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
                map.addOverlay(route.polyline)
                map.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = route.expectedTravelTime
                print("Расстояние до места \(distance) км")
                print("Время в пути \(timeInterval) сек.")
            }
        }
    }
    
    // Настройка запроса для расчета маршрута
    private func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        guard let destinationCoordinate = placeCoordinate else { return nil }
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        return request
    }
    
    // Меняем отображаемую зону области карты в соответствии с перемещением пользователя
    func startTrackingUserLocation(for map: MKMapView, and location: CLLocation?, closure: (_ currentLocation: CLLocation) -> ()) {
      
        guard let location = location else { return }
        let center = getCenterLocation(for: map)
        guard center.distance(from: location) > 50 else { return }
        
        closure(center)
    }
    
    // Сброс всех ранее построенных маршрутов перед построением нового
    private func resetMap(withNew directions: MKDirections, map: MKMapView) {
        map.removeOverlays(map.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
        directionsArray.removeAll()
    }
    
    // Определение центра отображаемой области карты
    func getCenterLocation(for map: MKMapView) -> CLLocation {
        
        let latitude = map.centerCoordinate.latitude
        let longitude = map.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        let alertwindow = UIWindow(frame: UIScreen.main.bounds)
        alertwindow.rootViewController = UIViewController()
        alertwindow.windowLevel = UIWindow.Level.alert + 1
        alertwindow.makeKeyAndVisible()
        alertwindow.rootViewController?.present(alert, animated: true, completion: nil)
    }
}


