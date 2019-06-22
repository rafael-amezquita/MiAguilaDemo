//
//  TripDataModel.swift
//  MiAguilaDemo
//
//  Created by Rafael Andres Amezquita Mejia on 6/19/19.
//  Copyright © 2019 Rafael Andres Amezquita Mejia. All rights reserved.
//

import Foundation

/*
 "pickup_location" : {
  "type" : "Point",
  "coordinates" : [ -74.0565192, 4.6761959 ]
 }
 */
enum LocationDataType: String, Codable {
  case point = "Point"
}

struct LocationData: Codable {
  var type: LocationDataType
  var coordinates: (latitude: Float, longitude: Float) {
    return (latitude: coordinatesArray.first ?? 0,
            longitude: coordinatesArray.last ?? 0)
  }
  
  private var coordinatesArray: [Float]
  
  enum LocationDataKeys: String, CodingKey {
    case type = "type"
    case coordinates = "coordinates"
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: LocationDataKeys.self)
    type = try values.decode(LocationDataType.self, forKey: .type)
    coordinatesArray = try values.decode([Float].self, forKey: .coordinates)
  }
  
  func encode(to encoder: Encoder) throws {
    var values = encoder.container(keyedBy: LocationDataKeys.self)
    try values.encode(type, forKey: .type)
    try values.encode(coordinatesArray, forKey: .coordinates)
  }
}


/*
 "date" : {
    "$date" : "2019-01-25T19:06:27.936+0000"
 },
 */
struct LocationDate: Codable {
  
  var date: Date? {
    let formatter = DateFormatter()
    return formatter.date(from: dateFormat)
  }
  
  private var dateFormat: String
  
  enum LocationDateKeys: String, CodingKey {
    case dateFormat = "$date"
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: LocationDateKeys.self)
    dateFormat = try values.decode(String.self, forKey: .dateFormat)
  }
  
  func encode(to encoder: Encoder) throws {
    var values = encoder.container(keyedBy: LocationDateKeys.self)
    try values.encode(dateFormat, forKey: .dateFormat)
  }
}

/*
 {
   "date" : {
     "$date" : "2019-01-25T19:06:27.936+0000"
   },
   "pickup_address" : "Cl. 90 #19-41, Bogotá, Colombia",
   "pickup_location" : {
     "type" : "Point",
     "coordinates" : [ -74.0565192, 4.6761959 ]
   }
 }
 */
struct LocationPoint: Codable {
  var date: LocationDate?
  var pickupAddress: String
  var pickupLocation: LocationData
  
  enum LocationPointKeys: String, CodingKey {
    case date
    case pickupAddress = "pickup_address"
    case pickupLocation = "pickup_location"
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: LocationPointKeys.self)
    if let unwrappedDate = try? values.decode(LocationDate.self, forKey: .date) {
      date = unwrappedDate
    }
    pickupAddress = try values.decode(String.self, forKey: .pickupAddress)
    pickupLocation = try values.decode(LocationData.self, forKey: .pickupLocation)
  }
  
  func encode(to encoder: Encoder) throws {
    var values = encoder.container(keyedBy: LocationPointKeys.self)
    try? values.encode(date, forKey: .date)
    try values.encode(pickupAddress, forKey: .pickupAddress)
    try values.encode(pickupLocation, forKey: .pickupLocation)
  }
}

/*
 {
   "name" : "Colombia" / "Bogota"
 }
 */
struct Region: Codable {
  var name: String
}

/*
 {
   "first_name" : "Ricardo",
   "last_name" : "Sarmiento"
 }
 */
struct User: Codable {
  var firstName: String?
  var lastName: String?
  
  enum UserKeys: String, CodingKey {
    case firstName = "first_name"
    case lastName = "last_name"
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: UserKeys.self)
    if let name = try? values.decode(String.self, forKey: .firstName) {
      firstName = name
    }
    if let unwrappedLastName = try? values.decode(String.self, forKey: .lastName) {
      lastName = unwrappedLastName
    }
  }
  
  func encode(to encoder: Encoder) throws {
    var values = encoder.container(keyedBy: UserKeys.self)
    try? values.encode(firstName, forKey: .firstName)
    try? values.encode(lastName, forKey: .lastName)
  }
}

/*
 {
   "plate" : "ESM308"
 }
 */
struct Vehicle: Codable {
  var plate: String?
}

enum TripStatus: String, Codable {
  case started = "started"
  case near = "near"
  case onWay = "onWay"
}

/*
{
"start" : {},
"end" : {},
"country" : {},
"city" : {},
"passenger" : {},
"driver" : {},
"car" : {},
"status" : "started",
"check_code" : "66",
"createdAt" : {},
"updatedAt" : {},
"price" : 13800.0,
"driver_location" : {}
}
 */
struct Trip: Codable {
  var start: LocationPoint
  var end: LocationPoint
  var country: Region
  var passenger: User
  var driver: User
  var car: Vehicle
  var status: TripStatus
  var checkCode: String
  var createdAt: LocationDate
  var updatedAt: LocationDate
  var price: Float
  var driverLocation: LocationData?
  
  enum TripKeys: String, CodingKey {
    case start
    case end
    case country
    case passenger
    case driver
    case car
    case status
    case checkCode = "check_code"
    case createdAt
    case updatedAt
    case price
    case driverLocation = "driver_location"
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: TripKeys.self)
    start = try values.decode(LocationPoint.self, forKey: .start)
    end = try values.decode(LocationPoint.self, forKey: .end)
    country = try values.decode(Region.self, forKey: .country)
    passenger = try values.decode(User.self, forKey: .passenger)
    driver = try values.decode(User.self, forKey: .driver)
    car = try values.decode(Vehicle.self, forKey: .car)
    status = try values.decode(TripStatus.self, forKey: .status)
    checkCode = try values.decode(String.self, forKey: .checkCode)
    createdAt = try values.decode(LocationDate.self, forKey: .createdAt)
    updatedAt = try values.decode(LocationDate.self, forKey: .updatedAt)
    price = try values.decode(Float.self, forKey: .price)
    if let location = try? values.decode(LocationData.self, forKey: .driverLocation) {
      driverLocation = location
    }
  }
  
  func encode(to encoder: Encoder) throws {
    var values = encoder.container(keyedBy: TripKeys.self)
    try values.encode(start, forKey: .start)
    try values.encode(end, forKey: .end)
    try values.encode(country, forKey: .country)
    try values.encode(passenger, forKey: .passenger)
    try values.encode(driver, forKey: .driver)
    try values.encode(car, forKey: .car)
    try values.encode(status, forKey: .status)
    try values.encode(checkCode, forKey: .checkCode)
    try values.encode(createdAt, forKey: .createdAt)
    try values.encode(updatedAt, forKey: .updatedAt)
    try values.encode(price, forKey: .price)
    try? values.encode(driverLocation, forKey: .driverLocation)
  }
}

struct TripResponse: Codable {
  var trips: [Trip]
}


