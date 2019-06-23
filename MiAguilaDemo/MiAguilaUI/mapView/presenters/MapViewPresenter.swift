//
//  MapViewPresenter.swift
//  MiAguilaDemo
//
//  Created by Rafael Andres Amezquita Mejia on 6/22/19.
//  Copyright © 2019 Rafael Andres Amezquita Mejia. All rights reserved.
//

import Foundation
import Mapbox

struct Constants {
  static let defaultZoomLevel: Double = 11.5
}

class MapViewPresenter {
  
  private var locationManager: CLLocationManager?
  private let mapView: MGLMapView
  
  init(with locationManager: CLLocationManager?, mapView: MGLMapView) {
    self.mapView = mapView
    self.locationManager = locationManager
  }
  
  func checkLocationServicesAvailability() {
    if CLLocationManager.locationServicesEnabled() {
      checkLocationServicesAuthorization()
    } else {
      // alert view
    }
  }
  
  func updateLocationAuthorization() {
    checkLocationServicesAuthorization()
  }
  
  func moveTo(location: CLLocationCoordinate2D, zoomLevel: Double = Constants.defaultZoomLevel) {
    centerViewTo(location: location, zoomLevel: zoomLevel)
  }
  
  func setUserpin() {
    guard let manager = locationManager,
      let initialLocation = manager.location?.coordinate else {
      return
    }
    
    let user = MGLPointAnnotation()
    user.coordinate = CLLocationCoordinate2D(latitude: initialLocation.latitude,
                                              longitude: initialLocation.longitude)
    user.title = "Me"
    mapView.addAnnotation(user)
    //    calculatePath(from: testStartPin.coordinate, to: testEndPin.coordinate)
  }
  
  private func checkLocationServicesAuthorization() {
    switch CLLocationManager.authorizationStatus() {
    case .authorizedAlways:
      break
    case .authorizedWhenInUse:
      if let manager = locationManager,
        let initialLocation = manager.location?.coordinate {
        centerViewTo(location: initialLocation, zoomLevel: Constants.defaultZoomLevel)
        manager.startUpdatingLocation()
      }
    case .denied:
      // explanatory alert
      break
    case .notDetermined:
      locationManager?.requestWhenInUseAuthorization()
    case .restricted:
      // explanatory alert
      break
    @unknown default:
      fatalError()
    }
  }
  
  private func centerViewTo(location: CLLocationCoordinate2D, zoomLevel: Double) {
    mapView.setCenter(location, zoomLevel: zoomLevel, animated: true)
  }
  

}
