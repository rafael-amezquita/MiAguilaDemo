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
  
  private var locationManager: CLLocationManager?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setUpManager()
    setUpPresenters()
    presentOnGoingTrips()
  }
  
  private func setUpManager() {
    locationManager = CLLocationManager()
    locationManager?.delegate = self
    locationManager?.desiredAccuracy = kCLLocationAccuracyBest
  }
  
  private func setUpPresenters() {
    mapPresenter = MapViewPresenter(with: locationManager, mapView: mapView)
    tripsPresenter = TripsPresenter(with: locationManager)
    mapPresenter?.checkLocationServicesAvailability()
    mapPresenter?.setUserpin()
  }
  
  private func presentOnGoingTrips() {
    guard let presenter = tripsPresenter else {
      return
    }
    
    for point in presenter.closestsPoints() {
      let options = MatchOptions(coordinates: [point.start.coordinate, point.end.coordinate])
      preparePath(with: options, point: point)
    }
  }
  
  private func preparePath(with options: MatchOptions, point: PrintablePath) {
    Directions.shared.calculate(options) { (matches, error) in
      guard error == nil, let match = matches?.first else {
        // TODO: Error banner / alert
        print("Error matching coordinates: \(error.debugDescription)")
        return
      }
      
      let formatedDistanceString = self.formatPathDistances(from: match)
      if let coordinates = match.coordinates, coordinates.count > 0 {
        self.showLocationMarkers(from: point)
        self.showPath(from: coordinates, title: formatedDistanceString)
      }
    }
  }
  
  // TODO: use for the popup controller
  private func formatPathDistances(from match: Match) -> String {
    guard let presenter = tripsPresenter else {
      return ""
    }
    
    let formattedDistance = presenter.formatedDistance(from: match.distance)
    let formattedTravelTime = presenter.formatedEstimatedTimeOfArrival(from: match.expectedTravelTime)
    return "Distance: \(formattedDistance); ETA: \(formattedTravelTime)"
  }
  
  private func showLocationMarkers(from point: PrintablePath) {
    mapView.addAnnotation(point.start)
    mapView.addAnnotation(point.end)
  }
  
  private func showPath(from coordinates: [CLLocationCoordinate2D], title: String) {
    // Convert the route’s coordinates into a polyline.
    var routeCoordinates = coordinates
    let routeLine = MGLPolyline(coordinates: &routeCoordinates,
                                count: UInt(coordinates.count))
    routeLine.title = title
    
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
  
  func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
    if annotation .isKind(of: MGLPolyline.self) {
      mapPresenter?.moveTo(location: annotation.coordinate,
                           zoomLevel: 14)
    }
    
  }
}
