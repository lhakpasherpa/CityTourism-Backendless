//
//  City.swift
//  CityTourism-Backendless
//
//  Created by Michael Rogers on 9/9/18.
//  Copyright © 2018 Michael Rogers. All rights reserved.
//

import Foundation

@objcMembers
class City : NSObject {
    
    var name:String?
    var population:Int
    var touristSites:[TouristSite] = []
    override var description: String { // NSObject adheres to the CustomStringConvertible protocol
        return "Name: \(name ?? ""), Population: \(population), ObjectId: \(objectId ?? "N/A")"
    }
    var objectId:String?
    
    static let impossiblePopulation = -1
    
    init(name:String?, population:Int?, touristSites:[TouristSite]){
        self.name = name
        self.population = population ?? City.impossiblePopulation
        self.touristSites = touristSites
        //self.objectId = ""
    }
    
    convenience override init(){
        self.init(name:"", population:City.impossiblePopulation, touristSites:[])
    }
    
}
