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
  @IBOutlet weak var speedLabel: UILabel!
  
  private var mapPresenter: MapViewPresenter?
  private var tripsPresenter: TripsPresenter?
  private var locationManager: CLLocationManager?
  private var descriptionCardPresenter: DescriptionCardPresenter?
  
  private var presentedPathDictionary = [String: Any]()
  
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
    descriptionCardPresenter = DescriptionCardPresenter()
    
    mapPresenter?.checkLocationServicesAvailability()
    mapPresenter?.setUserpin(in: locationManager?.location)
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
      guard error == nil,
        let match = matches?.first,
        let presenter = self.tripsPresenter else {
        // TODO: Error banner / alert
        print("Error matching coordinates: \(error.debugDescription)")
        return
      }
      
      if let coordinates = match.coordinates, coordinates.count > 0 {
        // Convert the route’s coordinates into a polyline.
        var routeCoordinates = coordinates
        let routeLine = MGLPolyline(coordinates: &routeCoordinates,
                                    count: UInt(coordinates.count))
        
        let description = PathDescription(distance: presenter.formatedDistance(from: match.distance),
                                          formatedETA: presenter.formatedEstimatedTimeOfArrival(from: match.expectedTravelTime),
                                          startTime: point.startTime,
                                          endTime: "",
                                          originAddress: point.start.title ?? "",
                                          destinationAddress: point.end.title ?? "")
        self.presentedPathDictionary["\(routeLine.hashValue)"] = description
        
        self.showLocationMarkers(from: point)
        self.showPath(from: routeLine, coordinates: routeCoordinates)
      }
    }
  }
  
  private func showLocationMarkers(from point: PrintablePath) {
    mapView.addAnnotation(point.start)
    mapView.addAnnotation(point.end)
  }
  
  private func showPath(from poliline: MGLPolyline, coordinates: [CLLocationCoordinate2D]) {
    var polilineCoordinates = coordinates
    // Add the polyline to the map and fit the viewport to the polyline.
    self.mapView.addAnnotation(poliline)
    self.mapView.setVisibleCoordinates(&polilineCoordinates,
                                       count: UInt(polilineCoordinates.count),
                                       edgePadding: .zero,
                                       animated: true)
  }
  
}

// MARK: - Location Manager Delegate
extension MapViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager,
                       didUpdateLocations locations: [CLLocation]) {
    
    guard let location = locations.first else { return }
    
    mapPresenter?.setUserpin(in: location)
    speedLabel.text = "valocidad: \(location.speed)"
  }
  
  func locationManager(_ manager: CLLocationManager,
                       didChangeAuthorization status: CLAuthorizationStatus) {
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
    
    mapPresenter?.moveTo(location: annotation.coordinate, zoomLevel: 14)
    
    guard let poliline = annotation as? MGLPolyline else {
      return
    }
    
    if let objectDescription = self.presentedPathDictionary["\(poliline.hashValue)"] as? PathDescription {
      descriptionCardPresenter?.setup(description: objectDescription)
    }
    
    if let storyboard = self.storyboard,
      let popupController = storyboard.instantiateViewController(withIdentifier: "DescriptionCardViewController") as? DescriptionCardViewController {
      
      popupController.descriptionPresenter = descriptionCardPresenter
      present(popupController, animated: true, completion: nil)
    }

  }
}
