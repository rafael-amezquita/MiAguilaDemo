//
//  TripsAdapter.swift
//  MiAguilaDemo
//
//  Created by Rafael Andres Amezquita Mejia on 6/20/19.
//  Copyright © 2019 Rafael Andres Amezquita Mejia. All rights reserved.
//

import Foundation

protocol TripsAdapterProtocol {
  func getTrips(completion:@escaping (_ result: [Trip]?)->Void)
}

class TripsAdapter: TripsAdapterProtocol {
  
  func getTrips(completion:@escaping (_ result: [Trip]?)->Void ) {
    TripsAPIServicesManager.getTrips { (dataResponse) in
      guard let data = dataResponse else {
        completion(nil)
        return
      }

      do {
        let decoder = JSONDecoder()
        let response = try decoder.decode(TripResponse.self, from: data)
        completion(response.trips)
      } catch {
        print("PARSING ERROR: \(error)")
        completion(nil)
      }
      
    }
  }
}
