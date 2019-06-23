//
//  MapViewPresenter.swift
//  MiAguilaDemo
//
//  Created by Rafael Andres Amezquita Mejia on 6/22/19.
//  Copyright © 2019 Rafael Andres Amezquita Mejia. All rights reserved.
//

import Foundation
import Mapbox

class MapViewPresenter {
  
  private let locationManager: CLLocationManager
  private let mapView: MGLMapView
  
  init(withDelegate controllerDelegate: CLLocationManagerDelegate, mapView: MGLMapView) {
    locationManager = CLLocationManager()
    locationManager.delegate = controllerDelegate
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    self.mapView = mapView
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
  
  func moveTo(location: CLLocationCoordinate2D) {
    centerViewTo(location: location)
  }
  
  func setUserpin() {
    guard let initialLocation = locationManager.location?.coordinate else {
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
      if let initialLocation = locationManager.location?.coordinate {
        centerViewTo(location: initialLocation)
        locationManager.startUpdatingLocation()
      }
    case .denied:
      // explanatory alert
      break
    case .notDetermined:
      locationManager.requestWhenInUseAuthorization()
    case .restricted:
      // explanatory alert
      break
    @unknown default:
      fatalError()
    }
  }
  
  private func centerViewTo(location: CLLocationCoordinate2D) {
    mapView.setCenter(location, zoomLevel: 13, animated: true)
  }
  

}
