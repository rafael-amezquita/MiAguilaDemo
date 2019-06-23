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
    start.title = trip.start.pickupAddress
    end.coordinate = coordinates(from: trip.end)
    end.title = trip.end.pickupAddress
  }
  
  func coordinates(from point: LocationPoint) -> CLLocationCoordinate2D {
    let latitude = point.pickupLocation.coordinates.latitude
    let longitude = point.pickupLocation.coordinates.longitude
    return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }
}

class TripsPresenter {
  
  private let adapter: TripsAdapterProtocol
  private var trips = [Trip]()
  
  private var currentCityTrips: [Trip] {
    // BR: Only 5
    var availableTrips = [Trip]()
    let bogotaTrips = trips.filter({$0.city.name == "Bogotá"})
    for index in 0...10 {
      availableTrips.append(bogotaTrips[index])
    }
    return availableTrips
  }
  
  var coordinates: [PrintablePath] {
    return currentCityTrips.map({PrintablePath(with: $0)})
  }
  
  init() {
    adapter = TripsAdapter()
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
