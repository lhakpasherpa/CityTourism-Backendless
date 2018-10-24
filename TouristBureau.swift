//
//  TouristBureau.swift
//  CityTourism-Backendless
//
//  Created by Michael Rogers on 9/15/18.
//  Copyright © 2018 Michael Rogers. All rights reserved.
//

import Foundation

// TouristBureau is our model class
// It stores all the cities
// It can also work with a selected city, to get tourist sites for it

extension Notification.Name {
    static let CitiesReloaded = Notification.Name("Cities Reloaded")
    static let TouristSitesForSelectedCityReloaded = Notification.Name("Tourist Sites for Selected City Reloaded")
}


class TouristBureau {
    
    let backendless = Backendless.sharedInstance()!
    var cityDataStore:IDataStore!
    var touristSitesDataStore:IDataStore!
    static var sharedInstance:TouristBureau = TouristBureau()
    
    var cities =  [
        City(name: "London", population: 12,
             touristSites:[TouristSite(name: "Big Ben", admissionFee: 15.00), TouristSite(name: "Big Eye", admissionFee: 25.00)]),
        City(name: "Paris", population: 15,
             touristSites: [TouristSite(name:"Notre Dame", admissionFee:25.00), TouristSite(name:"Loeuvre", admissionFee:18.00)]),
        City(name: "Maryville", population: 11872,
             touristSites: [TouristSite(name: "Northwest", admissionFee: 15000), TouristSite(name: "Title Town Fitness", admissionFee: 25.00)])
    ]
    
    subscript(index:Int) -> City {
        return cities[index]
    }
    
    var selectedCity:String? // the city that we have selected and are currently displaying tourist sites for
    var touristSites:[TouristSite] = [] // all tourist sites. This is currently unused (for Tourist Sites tab)
    var touristSitesForSelectedCity:[TouristSite] = [] // tourist sites for our selected city
    
    private init(){
        cityDataStore = backendless.data.of(City.self)
        touristSitesDataStore = backendless.data.of(TouristSite.self)
    }
    
    // returns: # of cities
    func numCities() -> Int {
        return cities.count     //return cityDataStore.getObjectCount().intValue would
    }
    
    // returns: # of tourist sites
    func numTouristSites() -> Int {
        return touristSites.count
    }
    
    // returns: # of tourist sites for selected city
    func numTouristSitesForSelectedCity(named:String) -> Int {
        return touristSitesForSelectedCity.count
    }
    
    // fetches all cities and their tourist sites, storing results in cities
    func reloadAllCities() {
        let queryBuilder = DataQueryBuilder()
        queryBuilder!.setRelated(["touristSites"])            // TouristSites referenced in City's touristSites                                                   // field will be retrieved for each City
        queryBuilder!.setPageSize(100)                      // up to 100 TouristSites can be retrieved for each City
        cities = cityDataStore.find(queryBuilder) as! [City]
        
    }
    
    
    // returns: City for the particular Tourist Site (currently just a stub)
    func fetchCityForTouristSite(named:String) -> City {
        return City()
    }
    
    // fetches TouristSites for selected city and reloads touristSitesForSelectedCity
    func reloadTouristSitesForSelectedCity() {
        let startDate = Date()
        
        Types.tryblock( {
            let queryBuilder:DataQueryBuilder = DataQueryBuilder()
            queryBuilder.setWhereClause("name = '\(self.selectedCity!)'" ) // fetch that one City
            queryBuilder.setPageSize(100)
            queryBuilder.setRelated( ["touristSites"] )
            let result = self.cityDataStore.find(queryBuilder) as! [City] // query returns an array, but we will only have 1 element
            self.touristSitesForSelectedCity = result[0].touristSites     // now we have all its touristSites
            
        },
                        catchblock: {(exception) -> Void in
                            print("Oopsie retrieving tourist sites for selected city -- \(exception.debugDescription)")
        })
        
        print("Done in \(Date().timeIntervalSince(startDate)) seconds ")
        
    }
    
    
    // fetch all cities and their tourist sites
    func reloadAllCitiesAsynchronously() {
        let queryBuilder = DataQueryBuilder()
        queryBuilder!.setRelated(["touristSites"]) // TouristSites referenced in City's touristSites                                             // field will be retrieved for each City
        queryBuilder!.setPageSize(100) // up to 100 TouristSites can be retrieved for each City
        cityDataStore.find(queryBuilder, response: {(results) -> Void in
            self.cities = results as! [City]
            NotificationCenter.default.post(name: .CitiesReloaded, object: nil) // broadcast the fact that Cities have been reloaded
        }, error: {(exception) -> Void in
            print(exception.debugDescription)
        })
        
    }
    
    // fetches TouristSites for selected city and reloads touristSitesForSelectedCity
    func reloadTouristSitesForSelectedCityAsynchronously() {
        let startDate = Date()
        
        let queryBuilder:DataQueryBuilder = DataQueryBuilder()
        queryBuilder.setWhereClause("name = '\(self.selectedCity!)'" ) // restrict ourselves to one city
        queryBuilder.setPageSize(100)
        queryBuilder.setRelated( ["touristSites"] )
        self.cityDataStore.find(queryBuilder,
                    response: {(results) -> Void in
                        let city = results![0] as! City
                        self.touristSitesForSelectedCity = city.touristSites
                        NotificationCenter.default.post(name: .TouristSitesForSelectedCityReloaded, object: nil) // broadcast the fact that Cities have been reloaded
        }, error: {(exception) -> Void in
            print(exception.debugDescription)
        })
        print("Done in \(Date().timeIntervalSince(startDate)) seconds ")
    }
    
    func removeCity(objectId:String){
        
    }
    
    // creates a City, saves it both locally and in the data store
    func saveCity(named name:String, population:Int) {
        var cityToSave = City(name: name, population: population, touristSites: [])
        cityToSave = cityDataStore.save(cityToSave) as! City // so our local version, in cities, has the objectId filled in
        cities.append(cityToSave)

    }
    
    // creates a City, saves it both locally and in the data store
    func saveCityAsynchronously(named name:String, population:Int) {
        var cityToSave = City(name: name, population: population, touristSites: [])
        cityDataStore.save(cityToSave, response: {(result) -> Void in
            cityToSave = result as! City
            self.cities.append(cityToSave)
            self.reloadAllCitiesAsynchronously()},
            error:{(exception) -> Void in
                print(exception.debugDescription)
                
            })
    }

    
    func saveTouristSite(touristSite:TouristSite) {
    }
    
}
