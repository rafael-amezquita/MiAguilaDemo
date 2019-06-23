//
//  MapViewController.swift
//  MiAguilaDemo
//
//  Created by Rafael Andres Amezquita Mejia on 6/19/19.
//  Copyright © 2019 Rafael Andres Amezquita Mejia. All rights reserved.
//

import UIKit
import Mapbox
import MapboxDirections

class MapViewController: UIViewController {

  @IBOutlet weak var mapView: MGLMapView!
  
  private var mapPresenter: MapViewPresenter?
  private var tripsPresenter: TripsPresenter?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setUpPresenters()
    presentOnGoingTrips()
  }
  
  private func setUpPresenters() {
    mapPresenter = MapViewPresenter(withDelegate: self, mapView: mapView)
    tripsPresenter = TripsPresenter()
    mapPresenter?.checkLocationServicesAvailability()
    mapPresenter?.setUserpin()
  }
  
  private func presentOnGoingTrips() {
    guard let presenter = tripsPresenter else {
      return
    }
    
    for point in presenter.coordinates {
      let options = MatchOptions(coordinates: [point.start.coordinate, point.end.coordinate])
      preparePath(with: options, point: point)
    }
  }
  
  private func preparePath(with options: MatchOptions, point: PrintablePath) {
    guard let presenter = tripsPresenter else {
      return
    }
    
    Directions.shared.calculate(options) { (matches, error) in
      guard error == nil else {
        // TODO: Error banner / alert
        print("Error matching coordinates: \(error!)")
        return
      }
      
      guard let match = matches?.first else {
        // TODO: Error banner / alert
        print("Error matching path")
        return
      }
      // TODO: use for the popup controller
      //let formattedDistance = presenter.formatedDistance(from: match.distance)
      //let formattedTravelTime = presenter.formatedEstimatedTimeOfArrival(from: match.expectedTravelTime)
      //"Distance: \(formattedDistance); ETA: \(formattedTravelTime)"
      if let coordinates = match.coordinates, coordinates.count > 0 {
        self.showLocationMarkers(from: point)
        self.showPath(from: coordinates)
      }
    }
  }
  
  private func showLocationMarkers(from point: PrintablePath) {
    mapView.addAnnotation(point.start)
    mapView.addAnnotation(point.end)
  }
  
  private func showPath(from coordinates: [CLLocationCoordinate2D]) {
    // Convert the route’s coordinates into a polyline.
    var routeCoordinates = coordinates
    let routeLine = MGLPolyline(coordinates: &routeCoordinates,
                                count: UInt(coordinates.count))
    
    // Add the polyline to the map and fit the viewport to the polyline.
    self.mapView.addAnnotation(routeLine)
    self.mapView.setVisibleCoordinates(&routeCoordinates,
                                       count: UInt(coordinates.count),
                                       edgePadding: .zero,
                                       animated: true)
  }
}

// MARK: - Location Manager Delegate
extension MapViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let currentLocation = locations.last else {
        return
    }
//    let center = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude,
//                                        longitude: currentLocation.coordinate.longitude)
    //mapPresenter?.moveTo(location: center)
  }
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    mapPresenter?.updateLocationAuthorization()
  }
}

extension MapViewController: MGLMapViewDelegate {
  func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
    return nil // use default
  }
  
  func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
    return true // Allow callout view to appear when an annotation is tapped.
  }
}
