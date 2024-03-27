//
//  ScoreVC.swift
//  ChessGame
//
//  Created by Erdem on 23.12.2023.
//

import UIKit
import CoreData

class ScoreVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    

    @IBOutlet weak var scoreTableView: UITableView!
    
    var gameResults: [GameResult] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scoreTableView.dataSource = self
        scoreTableView.delegate = self
        
        fetchGameResults()
        
    }
    

    
    func fetchGameResults() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<GameResult> = GameResult.fetchRequest()

        do {
            // Fetch sonuçları ve en yeni sonuçları listenin başına yerleştir
            let results = try context.fetch(fetchRequest)
            gameResults = results.reversed()  // En yeni sonuçları en üstte göstermek için ters çevir
            scoreTableView.reloadData()
        } catch let error as NSError {
            print("Veri çekme hatası: \(error), \(error.userInfo)")
        }
    }


    
        
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return gameResults.count
            
        }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "scoreCell", for: indexPath)
            
            let gameResult = gameResults[indexPath.row]
            
           
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = """
            White: \(gameResult.finalWhitePlayerName ?? "N/A") vs Black: \(gameResult.finalBlackPlayerName ?? "N/A")
            Opponent: \(gameResult.finalOpponentType ?? "N/A")
            Duration: \(gameResult.finalGameDuration) sec, Moves: \(gameResult.finalMoveCount)
            Captured Pieces - White: \(gameResult.finalCapturedWhitePieces), Black: \(gameResult.finalCapturedBlackPieces)
            Captured Value - White Team: \(gameResult.finalWhitesCapturedValue), Black Team : \(gameResult.finalBlacksCapturedValue)
            Winner: \(gameResult.winner ?? "Draw")
            """
            
            
            return cell
        
        }
    
    
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
           return true
       }
    
    
    
    
    
    
    
    
    @IBAction func deleteClicked(_ sender: Any) {
        
        if let selectedRows = scoreTableView.indexPathsForSelectedRows {
                   let appDelegate = UIApplication.shared.delegate as! AppDelegate
                   let context = appDelegate.persistentContainer.viewContext

                   for indexPath in selectedRows {
                       context.delete(gameResults[indexPath.row])
                       gameResults.remove(at: indexPath.row)
                   }

                   do {
                       try context.save()
                       fetchGameResults()
                   } catch let error as NSError {
                       print("Silme hatası: \(error), \(error.userInfo)")
                   }
               }
        
    }
    
    
    
    
    
    @IBAction func deleteAllClicked(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
           let context = appDelegate.persistentContainer.viewContext

           for gameResult in gameResults {
               context.delete(gameResult)  // Her GameResult'u CoreData'dan sil
           }
           
           do {
               try context.save()          // Değişiklikleri kaydet
               gameResults.removeAll()     // Dizi'yi temizle
               scoreTableView.reloadData() // TableView'ı yenile
           } catch let error as NSError {
               print("Tümünü silme hatası: \(error), \(error.userInfo)")
           }
        
    }
    
    
    
    
    
    @IBAction func exitClicked(_ sender: Any) {
        
        performSegue(withIdentifier: "ScoreToVC", sender: self)
    }
    
    
    

}
