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
  
  func setUserpin(in location: CLLocation?) {
    guard let currentLocation = location?.coordinate else {
      return
    }
    
    let user = MGLPointAnnotation()
    user.coordinate = CLLocationCoordinate2D(latitude: currentLocation.latitude,
                                              longitude: currentLocation.longitude)
    user.title = "Me"
    if let currentAnnotations = mapView.annotations {
      let markers = currentAnnotations.filter({$0 is MGLPointAnnotation})
      
      if let userMarker = markers.first(where:{$0.title == "Me"}) {
        mapView.removeAnnotation(userMarker)
      }
      
    }
    
    mapView.addAnnotation(user)
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
