//
//  TouristSite.swift
//  CityTourism-Backendless
//
//  Created by Michael Rogers on 9/10/18.
//  Copyright © 2018 Michael Rogers. All rights reserved.
//

import Foundation

import Foundation

@objcMembers

class TouristSite : NSObject {
    
    var name:String?
    var admissionFee:Double
    override var description: String { // NSObject adheres to the CustomStringConvertible protocol
        return "Name: \(name ?? ""), Admission Fee: \(admissionFee)"
    }
    var objectId:String?
    
    static let impossiblePopulation = -1
    static let impossibleAdmissionFee = -1.00
    
    init(name:String?, admissionFee:Double?){
        self.name = name
        self.admissionFee = admissionFee ?? TouristSite.impossibleAdmissionFee
    }
    
    convenience override init(){
        self.init(name:"", admissionFee:TouristSite.impossibleAdmissionFee)
    }
    
}
