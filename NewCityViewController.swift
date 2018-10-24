//
//  NewCityViewController.swift
//  CityTourism-Backendless
//
//  Created by Michael Rogers on 9/15/18.
//  Copyright © 2018 Michael Rogers. All rights reserved.
//

import UIKit

class NewCityViewController: UIViewController {

    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var populationTF: UITextField!
    
    let touristBureau = TouristBureau.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    @IBAction func done(_ sender: Any) {
        touristBureau.saveCity(named:nameTF.text!, population:Int(populationTF.text!)!)
        self.dismiss(animated: true, completion: nil) // instead of using an unwind segue
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
