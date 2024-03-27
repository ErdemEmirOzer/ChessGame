//
//  SettingsVC.swift
//  ChessGame
//
//  Created by Erdem on 22.12.2023.
//

import UIKit

class SettingsVC: UIViewController {

   
   
    @IBOutlet weak var SettingsBackground: UIImageView!

    
    @IBOutlet weak var OpponentLabel: UILabel!
    @IBOutlet weak var moveTimeLabel: UILabel!
    @IBOutlet weak var pieceSoundLabel: UILabel!
    @IBOutlet weak var gameMusicLabel: UILabel!
    
    
    
    var opponentType = "Player"
    var gameMusicStatus = "Off"
    var pieceSoundStatus = "Off"
    var moveTimeOptions = [0, 15, 30, 60]
    var currentMoveTimeIndex = 0


    
    
    
    
    
    @IBAction func gameMusicChangeClicked(_ sender: Any) {
        
        gameMusicStatus = gameMusicStatus == "Off" ? "On" : "Off"
           gameMusicLabel.text = "\(gameMusicStatus)"
        
        saveSettings()
        printCurrentSettings()
    }
    
    
    @IBAction func pieceSoundChangeClicked(_ sender: Any) {
        
        pieceSoundStatus = pieceSoundStatus == "Off" ? "On" : "Off"
           pieceSoundLabel.text = "\(pieceSoundStatus)"
        
        saveSettings()
        printCurrentSettings()
    }
    
    
    @IBAction func opponentChangeClicked(_ sender: Any) {
        
        opponentType = opponentType == "Player" ? "AI" : "Player"
            OpponentLabel.text = "\(opponentType)"
        
        saveSettings()
        printCurrentSettings()
    }
    
    
    @IBAction func moveTimeChangeClicked(_ sender: Any) {
        
            currentMoveTimeIndex = (currentMoveTimeIndex + 1) % moveTimeOptions.count
            
            let newMoveTime = moveTimeOptions[currentMoveTimeIndex]
            moveTimeLabel.text = "\(newMoveTime == 0 ? "Off" : "\(newMoveTime) sec")"
            
        saveSettings()
        printCurrentSettings()
        
    }
    
    
    
    
    
   
   
   override func viewDidLoad() {
       
       super.viewDidLoad()
              
      loadSettings()
       
       OpponentLabel.text = "\(opponentType)"
       gameMusicLabel.text = "\(gameMusicStatus)"
       pieceSoundLabel.text = "\(pieceSoundStatus)"
       let moveTime = moveTimeOptions[currentMoveTimeIndex]
       moveTimeLabel.text = "\(moveTime == 0 ? "Off" : "\(moveTime) sec")"
       
       
   }
   
    

   
    
    func saveSettings() {
        UserDefaults.standard.set(opponentType, forKey: "OpponentType")
        UserDefaults.standard.set(gameMusicStatus, forKey: "GameMusicStatus")
        UserDefaults.standard.set(pieceSoundStatus, forKey: "PieceSoundStatus")
        // İndeksin geçerli olduğundan emin ol
            let moveTimeIndexToSave = currentMoveTimeIndex >= 0 && currentMoveTimeIndex < moveTimeOptions.count ? currentMoveTimeIndex : 0
            UserDefaults.standard.set(moveTimeOptions[moveTimeIndexToSave], forKey: "MoveTimeSetting")
    }

    
    
    
    func loadSettings (){
        
        opponentType = UserDefaults.standard.string(forKey: "OpponentType") ?? "Player"
                gameMusicStatus = UserDefaults.standard.string(forKey: "GameMusicStatus") ?? "Off"
                pieceSoundStatus = UserDefaults.standard.string(forKey: "PieceSoundStatus") ?? "Off"
        let savedMoveTime = UserDefaults.standard.integer(forKey: "MoveTimeSetting")
            if let savedIndex = moveTimeOptions.firstIndex(of: savedMoveTime) {
                currentMoveTimeIndex = savedIndex
            } else {
                // Eğer kaydedilen süre moveTimeOptions'da yoksa varsayılan bir indeks kullan
                currentMoveTimeIndex = 0
            }
    }
    
    
    
    func printCurrentSettings() {
        print("Current Opponent: \(opponentType)")
        print("Current Game Music Status: \(gameMusicStatus)")
        print("Current Piece Sound Status: \(pieceSoundStatus)")
        print("Current Move Time: \(moveTimeOptions[currentMoveTimeIndex]) seconds")
    }
    
    
   
   
   @IBAction func OKButton(_ sender: Any) {
       
       performSegue(withIdentifier: "SettingsToVC", sender: self)
       
   }
   
   
}
