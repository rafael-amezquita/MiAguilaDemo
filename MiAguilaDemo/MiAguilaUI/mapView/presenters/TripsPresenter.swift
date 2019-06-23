//
//  TripsPresenter.swift
//  MiAguilaDemo
//
//  Created by Rafael Andres Amezquita Mejia on 6/22/19.
//  Copyright © 2019 Rafael Andres Amezquita Mejia. All rights reserved.
//

import Foundation
import Mapbox
import MapboxDirections

struct PrintablePath {
  var start: MGLPointAnnotation
  var end: MGLPointAnnotation
  
  init(with trip: Trip) {
    start = MGLPointAnnotation()
    end = MGLPointAnnotation()

    start.coordinate = coordinates(from: trip.start)
    start.title = "Mi aguila"
    end.coordinate = coordinates(from: trip.end)
    end.title = trip.end.pickupAddress
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

class TripsPresenter {
  
  private let adapter: TripsAdapterProtocol
  private var locationManager: CLLocationManager?
  private var trips = [Trip]()
  private var distances = [GPSDistance]()
  
  private var currentCityTrips: [Trip] {
    // BR: Only 5, but not all are shown for engine issues
    var availableTrips = [Trip]()
    let bogotaTrips = trips.filter({$0.city.name == "Bogotá"})
    for index in 0...10 {
      availableTrips.append(bogotaTrips[index])
    }
    return availableTrips
  }
  
  init(with locationManager: CLLocationManager?) {
    adapter = TripsAdapter()
    self.locationManager = locationManager
    fetchTrips()
  }
  
  func formatedDistance(from locationDistance: CLLocationDistance) -> String {
    let distanceFormatter = LengthFormatter()
    return distanceFormatter.string(fromMeters: locationDistance)
  }
  
  func formatedEstimatedTimeOfArrival(from travelTime: TimeInterval) -> String {
    let travelTimeFormatter = DateComponentsFormatter()
    travelTimeFormatter.unitsStyle = .short
    return travelTimeFormatter.string(from: travelTime) ?? ""
  }
  
  func closestsPoints() -> [PrintablePath] {
    var points = [PrintablePath]()
    
    guard let manager = locationManager,
     let userLocation = manager.location else {
      return points
    }
    
    for trip in currentCityTrips {
      let latitude = CLLocationDegrees(floatLiteral: trip.start.pickupLocation.coordinates.latitude)
      let longitude = CLLocationDegrees(floatLiteral: trip.start.pickupLocation.coordinates.longitude)
      let tripStartLocation = CLLocation(latitude: latitude, longitude: longitude)
      
      let distance = userLocation.distance(from: tripStartLocation)
      distances.append(GPSDistance(userLocation: userLocation,
                                   comparedLocation: tripStartLocation,
                                   distance: distance))
    }
    
    let sortedDistances = distances.sorted(by: { $0.distance < $1.distance })
    
    //BR: Only 2
    for index in 0..<2 {
      let currentGPSDistance = sortedDistances[index]
      if let currentTrip = currentCityTrips.first(where: {$0.start.pickupLocation.coordinates.latitude == currentGPSDistance.comparedLocation.coordinate.latitude && $0.start.pickupLocation.coordinates.longitude == currentGPSDistance.comparedLocation.coordinate.longitude}) {
        points.append(PrintablePath(with: currentTrip))
      }

    }
    
    return points
  }
  
  private func fetchTrips() {
    adapter.getTrips(completion: { (trips) in
      guard let fetchedTrips = trips else {
        // TODO: handle error
        return
      }
      self.trips.append(contentsOf: fetchedTrips)
    })
  }
}
