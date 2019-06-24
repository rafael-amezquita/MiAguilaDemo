//
//  MapViewModel.swift
//  MiAguilaDemo
//
//  Created by Rafael Andres Amezquita Mejia on 6/23/19.
//  Copyright © 2019 Rafael Andres Amezquita Mejia. All rights reserved.
//

import Foundation
import Mapbox
import MapboxDirections

struct PrintablePath {
  var start: MGLPointAnnotation
  var end: MGLPointAnnotation
  var startTime: String = ""
  
  init(with trip: Trip) {
    start = MGLPointAnnotation()
    end = MGLPointAnnotation()
    
    start.coordinate = coordinates(from: trip.start)
    start.title = trip.start.pickupAddress
    startTime = formatStartTime(from: trip.start.date?.date)
    end.coordinate = coordinates(from: trip.end)
    end.title = trip.end.pickupAddress
  }
  
  func formatStartTime(from currentDate: Date?) -> String {
    guard let date = currentDate else { return "" }
    let formatter = DateFormatter()
    formatter.dateFormat = "MM-dd-yyyy HH:mm"
    return formatter.string(from: date)
  }
  
  func coordinates(from point: LocationPoint) -> CLLocationCoordinate2D {
    let latitude = point.pickupLocation.coordinates.latitude
    let longitude = point.pickupLocation.coordinates.longitude
    return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }
}

struct GPSDistance {
  var userLocation: CLLocation
  var comparedLocation: CLLocation
  var distance: Double
}
