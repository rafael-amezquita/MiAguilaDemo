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

//  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var mapView: MGLMapView!
  
  private var mapPresenter: MapViewPresenter?
  private var tripsPresenter: TripsPresenter?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    mapPresenter = MapViewPresenter(withDelegate: self, mapView: mapView)
    tripsPresenter = TripsPresenter()
    mapPresenter?.checkLocationServicesAvailability()
    mapPresenter?.setUserpin()
    
    testPath()
  }
  
  func testPath() {
    let start = MGLPointAnnotation()
    start.coordinate = CLLocationCoordinate2D(latitude: 4.6761959,
                                              longitude: -74.0565192)
    start.title = "start"
    
    let end = MGLPointAnnotation()
    end.coordinate = CLLocationCoordinate2D(latitude: 4.6830892 ,
                                              longitude: -74.0465655)
    end.title = "end"
    
    mapView.addAnnotation(start)
    mapView.addAnnotation(end)
    
    let coordinates = [
      start.coordinate,
      end.coordinate
    ]
    
    let options = MatchOptions(coordinates: coordinates)
    options.includesSteps = true
    
    Directions.shared.calculate(options) { (matches, error) in
      guard error == nil else {
        print("Error matching coordinates: \(error!)")
        return
      }
      
      if let match = matches?.first, let leg = match.legs.first {
        print("Match via \(leg):")
        
        let distanceFormatter = LengthFormatter()
        let formattedDistance = distanceFormatter.string(fromMeters: match.distance)
        
        let travelTimeFormatter = DateComponentsFormatter()
        travelTimeFormatter.unitsStyle = .short
        let formattedTravelTime = travelTimeFormatter.string(from: match.expectedTravelTime)
        
        print("Distance: \(formattedDistance); ETA: \(formattedTravelTime!)")
        
        for step in leg.steps {
          print("\(step.instructions)")
          let formattedDistance = distanceFormatter.string(fromMeters: step.distance)
          print("— \(formattedDistance) —")
        }
        
        if match.coordinates!.count > 0 {
          // Convert the route’s coordinates into a polyline.
          var routeCoordinates = match.coordinates!
          let routeLine = MGLPolyline(coordinates: &routeCoordinates, count: UInt(match.coordinates!.count))
          
          // Add the polyline to the map and fit the viewport to the polyline.
          self.mapView.addAnnotation(routeLine)
          self.mapView.setVisibleCoordinates(&routeCoordinates, count: UInt(match.coordinates!.count), edgePadding: .zero, animated: true)
        }
        
      }
      
      

    }
    
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
