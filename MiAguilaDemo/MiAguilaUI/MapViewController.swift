//
//  MapViewController.swift
//  MiAguilaDemo
//
//  Created by Rafael Andres Amezquita Mejia on 6/19/19.
//  Copyright © 2019 Rafael Andres Amezquita Mejia. All rights reserved.
//

import UIKit
//import MapKit
import Mapbox

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
    
    DispatchQueue.global().async {
      do {
        
        guard let data = geoJSON.data(using: .utf8),
          let shapeCollectionFeature = try MGLShape(data: data, encoding: String.Encoding.utf8.rawValue) as? MGLShapeCollectionFeature else {
            fatalError("Could not cast to specified MGLShapeCollectionFeature")
        }
        
        if let polyline = shapeCollectionFeature.shapes.first as? MGLPolylineFeature {
          // Optionally set the title of the polyline, which can be used for:
          //  - Callout view
          //  - Object identification
          polyline.title = polyline.attributes["name"] as? String
          
          DispatchQueue.main.async {
            self.mapView.addAnnotation(polyline)
          }
        }
        
      } catch {
        print(error)
      }
    }
    
    
  }
//
//  private func calculatePath(from a:CLLocationCoordinate2D, to b: CLLocationCoordinate2D) {
//    let pathRequest = MKDirections.Request()
//    let originPalcemark = MKPlacemark(coordinate: a)
//    let destinationPlacemark = MKPlacemark(coordinate: b)
//    pathRequest.source = MKMapItem(placemark: originPalcemark)
//    pathRequest.destination = MKMapItem(placemark: destinationPlacemark)
//    pathRequest.requestsAlternateRoutes = true
//    pathRequest.transportType = .automobile
//
//    let directions = MKDirections(request: pathRequest)
//    directions.calculate { [weak self] (directionResponse, error) in
//      guard let strongSelf = self,
//        let response = directionResponse else {
//          // error message
//          return
//      }
//
//      for route in response.routes {
//        strongSelf.mapView.addOverlay(route.polyline)
//        strongSelf.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
//      }
//    }
//  }

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


let geoJSON = """
{
"type": "FeatureCollection",
"features": [
{
"type": "Feature",
"properties": {
"name": "My Path"
},
"geometry": {
"type": "LineString",
"coordinates": [
[
-74.0565192,
4.6761959
],
[
-74.0465655,
4.6830892
]
]
}
}
]
}
"""
