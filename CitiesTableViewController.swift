//
//  CitiesTableViewController.swift
//  CityTourism-Backendless
//
//  Created by Michael Rogers on 9/15/18.
//  Copyright © 2018 Michael Rogers. All rights reserved.
//

// https://cocoacasts.com/what-is-notification-name-and-how-to-use-it

import UIKit

class CitiesTableViewController: UITableViewController {

    var touristBureau:TouristBureau!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        touristBureau = TouristBureau.sharedInstance // our model
        NotificationCenter.default.addObserver(self, selector: #selector(citiesReloaded), name: .CitiesReloaded, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        touristBureau.reloadAllCities()             //touristBureau.reloadAllCitiesAsynchronously()
        tableView.reloadData()
    }
    
    
    // when the model reports that our local version of cities has been reloaded, this will be called. This lets us work asynchronously
    @objc func citiesReloaded(){
        tableView.reloadData()
    }
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return touristBureau.numCities()
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath)

        let city = touristBureau[indexPath.row]
        cell.textLabel?.text = city.name
        cell.detailTextLabel?.text = "\(city.population)"

        return cell
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SelectedCity" {
            // Get the new view controller using segue.destinationViewController.
            let touristSitesForSelectedCityTVC = segue.destination as! TouristSitesForSelectedCityTableViewController
            if let cityName = touristBureau[tableView.indexPathForSelectedRow!.row].name {
                touristBureau.selectedCity = cityName
                touristSitesForSelectedCityTVC.selectedCityName = cityName
            }
        } else {
            // handle New City ... nothing really to do here
        }
    }
    


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
  
}
