//
//  AboutVC.swift
//  ChessGame
//
//  Created by Erdem on 28.11.2023.
//

import UIKit

class AboutVC: UIViewController {

    
    @IBOutlet weak var AboutBackGround: UIImageView!
    
    @IBOutlet weak var title1: UILabel!
    @IBOutlet weak var title2: UILabel!
    @IBOutlet weak var title3: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func BackButton(_ sender: Any) {
        
        performSegue(withIdentifier: "AboutToVC", sender: self)
        
    }
    
    


}
