//
//  TripsAPIServicesManager.swift
//  MiAguilaDemo
//
//  Created by Rafael Andres Amezquita Mejia on 6/20/19.
//  Copyright © 2019 Rafael Andres Amezquita Mejia. All rights reserved.
//

import Foundation

class TripsAPIServicesManager {
  
  static func getTrips(completion:@escaping (_ result: Data?)->Void)  {
    guard let path = Bundle.main.path(forResource: "trips", ofType: "json") else {
      completion(nil)
      return
    }
    
    do {
      let jsonResponse = try String(contentsOfFile: path)
      let data = jsonResponse.data(using: .utf8)
      completion(data)
    } catch {
      print("SERVICES ERROR: \(error)")
      completion(nil)
    }
  }
  
}
