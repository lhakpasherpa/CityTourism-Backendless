//
//  ViewController.swift
//  CityTourism-Backendless
//
//  Created by Michael Rogers on 9/9/18.
//  Copyright © 2018 Michael Rogers. All rights reserved.
//

import UIKit

// This class is not currently in part of the app ... it is a playground to show how to save 
class SavingViewController: UIViewController {
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var populationTF: UITextField!
    
    let backendless:Backendless = Backendless.sharedInstance()! // our singleton
    var cityDataStore:IDataStore! // our connection to the City data table in the Be app
    var touristSiteDataStore:IDataStore!
    
    var cities = [
        City(name: "London", population: 12,
             touristSites:[TouristSite(name: "Big Ben", admissionFee: 15.00), TouristSite(name: "Big Eye", admissionFee: 25.00)]),
        City(name: "Paris", population: 15,
             touristSites: [TouristSite(name:"Notre Dame", admissionFee:25.00), TouristSite(name:"Loeuvre", admissionFee:18.00)]),
        City(name: "Maryville", population: 11872,
             touristSites: [TouristSite(name: "Northwest", admissionFee: 15000), TouristSite(name: "Title Town Fitness", admissionFee: 25.00)])
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cityDataStore = backendless.data.of(City.self)! // our connection to the City data table in the Be app
        touristSiteDataStore = backendless.data.of(TouristSite.self)!
     }
    
    
    //shows how to create objects and make relations synchronously
    @IBAction func saveAllCitiesSynchronously(_ sender:Any?){
        
        let startingDate = Date()
        Types.tryblock({
            
            for city in self.cities {
                let savedCity = self.cityDataStore.save(city) as! City // save the city
                city.objectId = savedCity.objectId // save its objectId (needed for relation)
                var touristSiteIds:[String] = []
                for touristSite in city.touristSites { // now save all the TouristSites
                    let savedTouristSite = self.touristSiteDataStore.save(touristSite) as! TouristSite // save one of its TouristSites
                    touristSiteIds.append(savedTouristSite.objectId!)
                }
                self.cityDataStore.addRelation("touristSites:TouristSite:n", parentObjectId: city.objectId, childObjects: touristSiteIds)
            }
        }, catchblock:{ (exception) -> Void in
            print(exception.debugDescription)
        })
        
        print("Done!! in \(Date().timeIntervalSince(startingDate)) seconds")
    }
    
    @IBAction func saveAllCitiesAsynchronously(_ sender:Any?){
        let startingDate = Date()
        
        let myQueue = DispatchQueue(label:"myQueue", qos:.utility)
        myQueue.async {
            Types.tryblock({
                for city in self.cities {
                    let savedCity = self.cityDataStore.save(city) as! City // save the city
                    city.objectId = savedCity.objectId // save its objectId (needed for relation)
                    var touristSiteIds:[String] = []
                    for touristSite in city.touristSites { // now save all the TouristSites
                        let savedTouristSite = self.touristSiteDataStore.save(touristSite) as! TouristSite // save one of its TouristSites
                        touristSiteIds.append(savedTouristSite.objectId!)
                    }
                    self.cityDataStore.addRelation("touristSites:TouristSite:n", parentObjectId: city.objectId, childObjects: touristSiteIds)
                }
                
            },
                           catchblock:{(exception) in
                            print(exception ?? "Eh, what's up, doc?")
            })
        }
        
        print("Done!! in \(Date().timeIntervalSince(startingDate)) seconds")
        
    }
    
    // rather than use Apple's DispatchQueue, let's use the Backendless approach
    @IBAction func saveACityAsynchronouslyTheBackEndlessWay(_ sender:Any?){
        let startingDate = Date()
        
        let city = cities[0]
        
        cityDataStore.save(city,
                           response: {(savedCity) -> Void in            // saved the city, so now save the tourist site
                            print(savedCity as! City)
        },
                           error: {(exception) -> Void in
                            print(exception ?? "Eh, what's up, doc?")
        })
        
        
        print("Done!! in \(Date().timeIntervalSince(startingDate)) seconds")
        
    }
    /*
     If the column does not exist in the parent table at the time when the API is called, the value of the "columnName" argument must include the name of the child table separated by colon and the cardinality notation. The cardinality is expressed as ":1" for one-to-one relations and ":n" for one-to-many relations. For example, the value of "myOrder:Order:1" will create a one-to-one relation column "myOrder" in the parent table. The column will point to the Order child table. Likewise, the value of "myOrder:Order:n" will create a one-to-many relation column "myOrder" pointing to the Order table.
     */
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

