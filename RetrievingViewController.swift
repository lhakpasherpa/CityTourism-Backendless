//
//  RetrievingViewController.swift
//  CityTourism-Backendless
//
//  Created by Michael Rogers on 9/11/18.
//  Copyright © 2018 Michael Rogers. All rights reserved.
//

import UIKit

enum TableRows:Int {case City = 0, TouristSite = 1 }
class RetrievingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let backendless = Backendless.sharedInstance()!
    var cityDataStore:IDataStore!
    var touristSitesDataStore:IDataStore!
    
    var cities:[City] = []                          // in section 0 of citiesTableView
    var touristSitesForChosenCity:[TouristSite] = [] // in section 1 of citiesTableView  - tourist sites for the chosen city
    
    @IBOutlet weak var citiesTableView: UITableView!
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [cities.count, touristSitesForChosenCity.count][section]
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ["Cities", "Tourist Sites"][section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var tableViewCell:UITableViewCell!
        switch indexPath.section {
        case TableRows.City.rawValue:
            tableViewCell = citiesTableView.dequeueReusableCell(withIdentifier: "cityCell")!
            let city = cities[indexPath.row]
            tableViewCell.textLabel?.text = city.name ?? "N/A"
            tableViewCell.detailTextLabel?.text = "\(city.population)"
            
        case TableRows.TouristSite.rawValue:
            tableViewCell = citiesTableView.dequeueReusableCell(withIdentifier: "touristSiteCell")!
            let touristSite = touristSitesForChosenCity[indexPath.row]
            tableViewCell.textLabel?.text = touristSite.name ?? "N/A"
            tableViewCell.detailTextLabel?.text = "\(touristSite.admissionFee)"
        default:print("Can't happen")
        }
        return tableViewCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == TableRows.City.rawValue {       // if you tapped a city ...
            let cityName = cities[indexPath.row].name!          // get the city's name
            retrieveTouristSitesForCity(named:cityName)         // retrieve the associated Tourist Sites
            citiesTableView.reloadData()                        // display them in the TableRows.TouristSite.rawValue
            
        } else {                                                // You've tapped on a tourist site, find its city
            let touristSiteName = touristSitesForChosenCity[indexPath.row].name!
            retrieveCityForTouristSite(named:touristSiteName)
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cityDataStore = backendless.data.of(City.self)
        touristSitesDataStore = backendless.data.of(TouristSite.self)
        
        finderDemo()
        
    }
    
    @IBAction func retrieveAllCitiesSynchronously(_ sender: Any) {
        let startDate = Date()
        //let queryBuilder:DataQueryBuilder = DataQueryBuilder()
        //queryBuilder.setPageSize(100)
        
        cities = cityDataStore.find(/*queryBuilder*/) as! [City]
        citiesTableView.reloadData()
        print("Done in \(Date().timeIntervalSince(startDate)) seconds ")
    }
    
    @IBAction func retrieveAllCitiesAsynchronously(_ sender: Any) {
        let startDate = Date()
        
        // let queryBuilder:DataQueryBuilder = DataQueryBuilder()
        // queryBuilder.setPageSize(100)
        
        cityDataStore.find({
            (retrievedCities) -> Void in
            self.cities = retrievedCities as! [City]
            self.citiesTableView.reloadData()
        },
                           error: {(exception) -> Void in
                            print(exception.debugDescription)
        })
        print("Done in \(Date().timeIntervalSince(startDate)) seconds ")
        
    }
    
    func finderDemo(){
        
        // first, find a TouristSite (e.g., Royal Ontario Museum)
        var royalOntarioMuseum:TouristSite!
        let queryBuilder = DataQueryBuilder()
        queryBuilder?.setWhereClause("name = 'Royal Ontario Museum'")
        royalOntarioMuseum = touristSitesDataStore.find(queryBuilder)[0] as? TouristSite
        
        // Now, find the City associated with it, i.e., the one who's touristSites.objectId matches the Royal Ontari Museum
        // This iterates through all the touristSites of all the retrieved Cities (in this case all of them) until it's
        // found the right City -- Toronto
        queryBuilder!.setPageSize(100) // up to 100 TouristSites can be retrieved for each City
        queryBuilder!.setWhereClause("touristSites.objectId = '\(royalOntarioMuseum.objectId!)'")
        cityDataStore.find(queryBuilder, response: {(cities) -> Void in    //
            let city = cities![0] as! City
            print("The city corresponding to this tourist site, the Royal Ontario Museum, is \(city.name!)")
        }, error: {(exception) -> Void in
            print(exception.debugDescription)
        })
        
        
        
    }
    func retrieveTouristSitesForCity(named cityName:String){
        let startDate = Date()
        
        Types.tryblock( {
            let queryBuilder:DataQueryBuilder = DataQueryBuilder()
            queryBuilder.setWhereClause("name = '\(cityName)'" )
            queryBuilder.setPageSize(100)
            queryBuilder.setRelated( ["touristSites"] )
            let result = self.cityDataStore.find(queryBuilder) as! [City]
            self.touristSitesForChosenCity = result[0].touristSites
            self.citiesTableView.reloadData()
        },
                        catchblock: {(exception) -> Void in
                            print("Oopsie retrieving tourist sites for selected city -- \(exception.debugDescription)")
        })
        
        print("Done in \(Date().timeIntervalSince(startDate)) seconds ")
        
    }
    
    func retrieveCityForTouristSite(named touristSiteName:String){
        
        let startDate = Date()
        
        Types.tryblock( {
            let queryBuilder:DataQueryBuilder = DataQueryBuilder()
            queryBuilder.setWhereClause("name = '\(touristSiteName)'" )
            queryBuilder.setPageSize(100)
            queryBuilder.setRelated( ["touristSites"] )
            let result = self.touristSitesDataStore.find(queryBuilder) as! [City]
            self.touristSitesForChosenCity = result[0].touristSites
            self.citiesTableView.reloadData()
        },
                        catchblock: {(exception) -> Void in
                            print("Oopsie retrieving tourist sites for selected city -- \(exception.debugDescription)")
        })
        
        print("Done in \(Date().timeIntervalSince(startDate)) seconds ")
        
        
    }
    @IBAction func retrieveAllTouristSites(_ sender: Any) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
