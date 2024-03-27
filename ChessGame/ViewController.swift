//
//  ViewController.swift
//  ChessGame
//
//  Created by Erdem on 22.11.2023.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var Background: UIImageView!
    
    
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }

    
    
    @IBAction func PlayButton(_ sender: Any) {
        
        
        performSegue(withIdentifier: "toGameVC", sender: self)
        
         
    }
    
    
    @IBAction func SettingsButton(_ sender: Any) {
        
        performSegue(withIdentifier: "toSettingsVC", sender: self)
    }
    
    
    @IBAction func ScoreButton(_ sender: Any) {
        
        performSegue(withIdentifier: "toScoreVC", sender: self)
        
    }
    
    
    @IBAction func AboutButton(_ sender: Any) {
        
        performSegue(withIdentifier: "toAboutVC", sender: self)
    }
    
    
    
}

