//
//  TripsPresenter.swift
//  MiAguilaDemo
//
//  Created by Rafael Andres Amezquita Mejia on 6/22/19.
//  Copyright © 2019 Rafael Andres Amezquita Mejia. All rights reserved.
//

import Foundation

class TripsPresenter {
  
  private let adapter: TripsAdapterProtocol
  private var trips = [Trip]()
  
  var currentCityTrips: [Trip] {
     return trips.filter({$0.city.name == "Bogota"})
  }
  
  init() {
    adapter = TripsAdapter()
    fetchTrips()
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
