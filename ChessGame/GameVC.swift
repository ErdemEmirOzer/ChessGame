//
//  GameVC.swift
//  ChessGame
//
//  Created by Erdem on 28.10.2023.
//

import UIKit
import AVFoundation
import CoreData



// PIECE ATTRIBUTES


/*
struct ChessPiece {
    var name: String
    var imageView: UIImageView
    var x: CGFloat
    var y: CGFloat
    
}
*/


struct ChessPiece: Equatable {
    var name: String
    var imageView: UIImageView
    var x: CGFloat
    var y: CGFloat
    
    static func ==(lhs: ChessPiece, rhs: ChessPiece) -> Bool {
        return lhs.name == rhs.name && lhs.x == rhs.x && lhs.y == rhs.y
    }
}


// MOVE RECORD

struct MoveRecord {
    var movedPiece: ChessPiece
    var capturedPiece: ChessPiece?
    var fromPosition: CGPoint
    var toPosition: CGPoint
    
}


struct Move {
    var piece: ChessPiece
    var to: (x: CGFloat, y: CGFloat)
}




// GAME CLASS. ALL FUNCTIONALITIES ARE HERE

class GameVC: UIViewController, UITextFieldDelegate {
    
    // REGISTER GRAPHICS
    
    @IBOutlet weak var whitePawn1: UIImageView!
    @IBOutlet weak var whitePawn2: UIImageView!
    @IBOutlet weak var whitePawn3: UIImageView!
    @IBOutlet weak var whitePawn4: UIImageView!
    @IBOutlet weak var whitePawn5: UIImageView!
    @IBOutlet weak var whitePawn6: UIImageView!
    @IBOutlet weak var whitePawn7: UIImageView!
    @IBOutlet weak var whitePawn8: UIImageView!
    @IBOutlet weak var whiteRook1: UIImageView!
    @IBOutlet weak var whiteKnight1: UIImageView!
    @IBOutlet weak var whiteBishop1: UIImageView!
    @IBOutlet weak var whiteQueen: UIImageView!
    @IBOutlet weak var whiteKing: UIImageView!
    @IBOutlet weak var whiteBishop2: UIImageView!
    @IBOutlet weak var whiteKnight2: UIImageView!
    @IBOutlet weak var whiteRook2: UIImageView!
    
    
    
    @IBOutlet weak var blackPawn1: UIImageView!
    @IBOutlet weak var blackPawn2: UIImageView!
    @IBOutlet weak var blackPawn3: UIImageView!
    @IBOutlet weak var blackPawn4: UIImageView!
    @IBOutlet weak var blackPawn5: UIImageView!
    @IBOutlet weak var blackPawn6: UIImageView!
    @IBOutlet weak var blackPawn7: UIImageView!
    @IBOutlet weak var blackPawn8: UIImageView!
    @IBOutlet weak var blackRook1: UIImageView!
    @IBOutlet weak var blackKnight1: UIImageView!
    @IBOutlet weak var blackBishop1: UIImageView!
    @IBOutlet weak var blackQueen: UIImageView!
    @IBOutlet weak var blackKing: UIImageView!
    @IBOutlet weak var blackBishop2: UIImageView!
    @IBOutlet weak var blackKnight2: UIImageView!
    @IBOutlet weak var blackRook2: UIImageView!
    
    
    @IBOutlet weak var ChessBoardImageView: UIImageView!
    
    @IBOutlet weak var moveInput: UITextField!
    
    @IBOutlet weak var turnIndicatorView: UIView!
    
    

    
    // ATTRIBUTES
    
    var selectedPiece: UIImageView?
    
    var chessPieces: [ChessPiece] = []
    
    var moveHistory: [MoveRecord] = []
    
    var capturedBlackPieces: [UIImageView] = []
    var capturedWhitePieces: [UIImageView] = []
    
    var promotedWhiteQueenCounter = 0
    var promotedBlackQueenCounter = 0

    var moveSoundPlayer: AVAudioPlayer?
    var captureSoundPlayer: AVAudioPlayer?
    var illegalSoundPlayer: AVAudioPlayer?
    var backgroundMusicPlayer: AVAudioPlayer?
    var tenSecondsSoundPlayer: AVAudioPlayer?

    var opponentType = "Player"
    var gameMusicStatus = "Off"
    var pieceSoundStatus = "Off"
    var moveTimeOptions = [0, 15, 30, 60]
    var currentMoveTimeIndex = 0
    
    var whitePlayerName: String?
    var blackPlayerName: String?
    
    var isGameActive = true
    
    var isWhiteTurn = true

    var moveTimer: Timer?
    var moveTimeRemaining: Int = 0
    var totalTimeElapsed: Int = 0
    var totalTimeTimer: Timer?
    
    var moveCounter = 0
    var finalMoveCount = 0
    
    var finalGameDuration = 0
    
    var finalWhitePlayerName :String?
    var finalBlackPlayerName :String?
    
    var finalOpponentType :String?
    
    var finalCapturedBlackPieces = 0
    var finalCapturedWhitePieces = 0
    
    var whiteCapturedValue = 0
    var blackCapturedValue = 0
    
    var finalWhitesCapturedValue = 0
    var finalBlacksCapturedValue = 0
    
    var winner :String?
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // VIEWDIDLOAD
        
        moveInput.delegate = self
        addWhiteGestureRecognizers()
        initializeChessPieces()
        loadSoundFiles()
        loadSettings()
        
        
        turnIndicatorView.frame = CGRect(x: 207, y: 90, width: 40, height: 40)
            turnIndicatorView.backgroundColor = isWhiteTurn ? .systemBrown : .black
            view.addSubview(turnIndicatorView)

           
        
        
        if opponentType == "Player" {
            
            addBlackGestureRecognizers()
            
        }
        
        
        
        
        if gameMusicStatus == "On" {
            backgroundMusicPlayer?.numberOfLoops = -1 // Sürekli çalması için
            backgroundMusicPlayer?.play() // Arka plan müziğini başlat
            
        }
    
    
    }
    
   
    
    // VIEWDIDAPPEAR
    
    override func viewDidAppear(_ animated: Bool) {
        
        promptForPlayerNames()
        
    }
    
   
    
    
    // UNDO FUNCTION
    
    @IBAction func undoClicked(_ sender: Any) {
        
        guard let lastMove = moveHistory.popLast() else { return }

           // Taşı eski pozisyonuna geri koy
           UIView.animate(withDuration: 0.5) {
               lastMove.movedPiece.imageView.frame.origin = lastMove.fromPosition
           }
           updateChessPieceCoordinates(lastMove.movedPiece.imageView, newX: lastMove.fromPosition.x, newY: lastMove.fromPosition.y)
           
           // Eğer bir taş yenilmişse, onu geri getir
           if let captured = lastMove.capturedPiece {
               captured.imageView.isHidden = false
               captured.imageView.frame.origin = lastMove.toPosition
               chessPieces.append(captured)
           }
           
           print("Son hamle geri alındı.")
        
    }
    
    
    
    @IBAction func exitClicked(_ sender: Any) {
        
        endGame()
        
        performSegue(withIdentifier: "GameToVC", sender: self)
        
        
    }
    
    
    @IBAction func startClicked(_ sender: Any) {
        
        startGame()
        
    }
    
    
    
    
    
    
    
    @IBOutlet weak var remainingTimeLabel: UILabel!
    
    
    
    
    // INITIALIZE PIECE LOCATIONS
    
    func initializeChessPieces() {
        chessPieces.append(ChessPiece(name: "whitePawn1", imageView: whitePawn1, x: 7, y: 460))
        chessPieces.append(ChessPiece(name: "whitePawn2", imageView: whitePawn2, x: 57, y: 460))
        chessPieces.append(ChessPiece(name: "whitePawn3", imageView: whitePawn3, x: 107, y: 460))
        chessPieces.append(ChessPiece(name: "whitePawn4", imageView: whitePawn4, x: 157, y: 460))
        chessPieces.append(ChessPiece(name: "whitePawn5", imageView: whitePawn5, x: 207, y: 460))
        chessPieces.append(ChessPiece(name: "whitePawn6", imageView: whitePawn6, x: 257, y: 460))
        chessPieces.append(ChessPiece(name: "whitePawn7", imageView: whitePawn7, x: 307, y: 460))
        chessPieces.append(ChessPiece(name: "whitePawn8", imageView: whitePawn8, x: 357, y: 460))
        chessPieces.append(ChessPiece(name: "whiteRook1", imageView: whiteRook1, x: 7, y: 510))
        chessPieces.append(ChessPiece(name: "whiteKnight1", imageView: whiteKnight1, x: 57, y: 510))
        chessPieces.append(ChessPiece(name: "whiteBishop1", imageView: whiteBishop1, x: 107, y: 510))
        chessPieces.append(ChessPiece(name: "whiteQueen", imageView: whiteQueen, x: 157, y: 510))
        chessPieces.append(ChessPiece(name: "whiteKing", imageView: whiteKing, x: 207, y: 510))
        chessPieces.append(ChessPiece(name: "whiteBishop2", imageView: whiteBishop2, x: 257, y: 510))
        chessPieces.append(ChessPiece(name: "whiteKnight2", imageView: whiteKnight2, x: 307, y: 510))
        chessPieces.append(ChessPiece(name: "whiteRook2", imageView: whiteRook2, x: 357, y: 510))
        
        chessPieces.append(ChessPiece(name: "blackPawn1", imageView: blackPawn1, x: 7, y: 210))
        chessPieces.append(ChessPiece(name: "blackPawn2", imageView: blackPawn2, x: 57, y: 210))
        chessPieces.append(ChessPiece(name: "blackPawn3", imageView: blackPawn3, x: 107, y: 210))
        chessPieces.append(ChessPiece(name: "blackPawn4", imageView: blackPawn4, x: 157, y: 210))
        chessPieces.append(ChessPiece(name: "blackPawn5", imageView: blackPawn5, x: 207, y: 210))
        chessPieces.append(ChessPiece(name: "blackPawn6", imageView: blackPawn6, x: 257, y: 210))
        chessPieces.append(ChessPiece(name: "blackPawn7", imageView: blackPawn7, x: 307, y: 210))
        chessPieces.append(ChessPiece(name: "blackPawn8", imageView: blackPawn8, x: 357, y: 210))
        chessPieces.append(ChessPiece(name: "blackRook1", imageView: blackRook1, x: 7, y: 160))
        chessPieces.append(ChessPiece(name: "blackKnight1", imageView: blackKnight1, x: 57, y: 160))
        chessPieces.append(ChessPiece(name: "blackBishop1", imageView: blackBishop1, x: 107, y: 160))
        chessPieces.append(ChessPiece(name: "blackQueen", imageView: blackQueen, x: 157, y: 160))
        chessPieces.append(ChessPiece(name: "blackKing", imageView: blackKing, x: 207, y: 160))
        chessPieces.append(ChessPiece(name: "blackBishop2", imageView: blackBishop2, x: 257, y: 160))
        chessPieces.append(ChessPiece(name: "blackKnight2", imageView: blackKnight2, x: 307, y: 160))
        chessPieces.append(ChessPiece(name: "blackRook2", imageView: blackRook2, x: 357, y: 160))
        
    }
    
    
    
    
    
    
    // LOAD SETTINGS
    
    func loadSettings() {
        // Mevcut ayarları UserDefaults'tan yükleyin
        opponentType = UserDefaults.standard.string(forKey: "OpponentType") ?? "Player"
        gameMusicStatus = UserDefaults.standard.string(forKey: "GameMusicStatus") ?? "Off"
        pieceSoundStatus = UserDefaults.standard.string(forKey: "PieceSoundStatus") ?? "Off"

        let savedMoveTime = UserDefaults.standard.integer(forKey: "MoveTimeSetting")

            // Eğer kaydedilen süre 0 ise, süre sınırlaması olmayacak
            moveTimeRemaining = savedMoveTime

            // Ayarlanan hamle süresini etikete yansıt veya süre sınırlaması yoksa bunu belirt
            remainingTimeLabel.text = moveTimeRemaining > 0 ? "\(moveTimeRemaining) seconds" : "No time limit"

            // Oyun süresini sıfırlayın
            totalTimeElapsed = 0
    }

    
    
    
    
    
    
    // SOUND FUNCTIONS
    
    func loadSoundFiles() {
        
        moveSoundPlayer = preparePlayer(with: "move.mp3")
        captureSoundPlayer = preparePlayer(with: "capture.mp3")
        illegalSoundPlayer = preparePlayer(with: "illegal.mp3")
        backgroundMusicPlayer = preparePlayer(with: "backgroundmusic.mp3")
        tenSecondsSoundPlayer = preparePlayer(with: "tenseconds.mp3")

        
    }

    
    
    
    func preparePlayer(with resource: String) -> AVAudioPlayer? {
        
        if let path = Bundle.main.path(forResource: resource, ofType: nil) {
            let url = URL(fileURLWithPath: path)
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()
                return player
            } catch {
                print("Dosya yüklenemedi: \(resource)")
            }
        }
        return nil
        
    }
    
    
    
    

    

    // CHANGE TURN
    
    func changeTurn() {
        isWhiteTurn = !isWhiteTurn
        moveTimeRemaining = UserDefaults.standard.integer(forKey: "MoveTimeSetting")
        remainingTimeLabel.text = "\(moveTimeRemaining) seconds"
        updateTurnIndicator()
    }
    
    
    
    // CHANGE TURN VIEW
    
    func updateTurnIndicator() {
        turnIndicatorView.backgroundColor = isWhiteTurn ? UIColor.systemBrown : UIColor.black
    }

    
    
    // TIME WARNING
    
    func checkForTimeWarning(timeRemaining: Int) {
       
        let moveTimeSetting = UserDefaults.standard.integer(forKey: "MoveTimeSetting")

        switch moveTimeSetting {
        case 15 where timeRemaining == 5,
             30 where timeRemaining == 10,
             60 where timeRemaining == 15:
            playTenSecondsSound()
        default:
            break
        }
    }


    // TIME WARNING SOUND
    
    func playTenSecondsSound() {
        
        tenSecondsSoundPlayer?.play()
    }
    
    
    
    
    // TAKE THE NAMES
    
    func promptForPlayerNames() {
        
        if opponentType == "Player"{
            
            let alertController = UIAlertController(title: "Enter Player Names", message: nil, preferredStyle: .alert)
            
            
            alertController.addTextField { textField in
                textField.placeholder = "White Player Name"
            }
            alertController.addTextField { textField in
                textField.placeholder = "Black Player Name"
            }
            
            let startAction = UIAlertAction(title: "Start Game", style: .default) { [unowned self] _ in
                let whiteName = alertController.textFields?[0].text
                let blackName = alertController.textFields?[1].text
                
                self.whitePlayerName = whiteName
                self.blackPlayerName = blackName
                
                
                
            }
            
            alertController.addAction(startAction)
            present(alertController, animated: true, completion: nil)
        }
        
        else {
            
            let alertController = UIAlertController(title: "Enter Player Name", message: nil, preferredStyle: .alert)
            
            alertController.addTextField { textField in
                textField.placeholder = "Player Name"
            }
            
            let startAction = UIAlertAction(title: "Start Game", style: .default) { [unowned self] _ in
                
                let whiteName = alertController.textFields?[0].text
            
                self.whitePlayerName = whiteName
                self.blackPlayerName = "AI"
                
                
                
            }
            
            alertController.addAction(startAction)
            present(alertController, animated: true, completion: nil)
            
        }
        
    }

    
    
    // START GAME
    
    func startGame() {
        
        isGameActive = true
        moveTimeRemaining = UserDefaults.standard.integer(forKey: "MoveTimeSetting")
        if moveTimeRemaining == 0 {
            remainingTimeLabel.isHidden = true
        }
        else {
            remainingTimeLabel.text = "\(moveTimeRemaining) seconds"
            
            moveTimer?.invalidate()
            moveTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateMoveTimer), userInfo: nil, repeats: true)
            
            totalTimeTimer?.invalidate()
            totalTimeElapsed = 0
            totalTimeTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTotalTime), userInfo: nil, repeats: true)
        }
    }
    
    
    
    // TIMER FUNCTIONS
    
    @objc func updateTotalTime() {
        if isGameActive {
            totalTimeElapsed += 1
            print("Total Time Elapsed: \(totalTimeElapsed) seconds")
        } else {
            totalTimeTimer?.invalidate()
            print("Game ended. Final Total Time Elapsed: \(totalTimeElapsed) seconds")
        }
    }

    
    
    @objc func updateMoveTimer() {
        if moveTimeRemaining > 0 {
            moveTimeRemaining -= 1
            remainingTimeLabel.text = "\(moveTimeRemaining) seconds"
            
            checkForTimeWarning(timeRemaining: moveTimeRemaining)
        }
        else {
            changeTurn()
        }
    }
   
    
    
    
    // END THE GAME
    
    func endGame() {
        isGameActive = false
        moveTimer?.invalidate()
        totalTimeTimer?.invalidate()

        finalMoveCount = moveCounter
        finalGameDuration = totalTimeElapsed
        finalOpponentType = opponentType
        finalBlackPlayerName = blackPlayerName
        finalWhitePlayerName = whitePlayerName
        finalCapturedBlackPieces = capturedBlackPieces.count
        finalCapturedWhitePieces = capturedWhitePieces.count
        finalBlacksCapturedValue = whiteCapturedValue
        finalWhitesCapturedValue = blackCapturedValue
        winner = determineWinner()
        
        saveGameResult()
        
        /*
        print("Final Move Count: \(finalMoveCount)")
        print("Final Game Duration: \(finalGameDuration) seconds")
        print("Final Opponent Type: \(finalOpponentType ?? "Unknown")")
        print("Final Black Player Name: \(finalBlackPlayerName ?? "Unknown")")
        print("Final White Player Name: \(finalWhitePlayerName ?? "Unknown")")
        print("Final Captured Black Pieces: \(finalCapturedBlackPieces)")
        print("Final Captured White Pieces: \(finalCapturedWhitePieces)")
        print("Final Blacks Captured Value: \(finalBlacksCapturedValue)")
        print("Final Whites Captured Value: \(finalWhitesCapturedValue)")
        print("Winner: \(winner ?? "No Winner")")
        */
         
        
    }
    
    
    
    
    
    // SAVE SCORES TO COREDATA DATABASE
    
    func saveGameResult() {
       
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let gameResult = GameResult(context: context)

    
        gameResult.finalMoveCount = Int16(finalMoveCount)
        gameResult.finalGameDuration = Int16(finalGameDuration)
        gameResult.finalOpponentType = finalOpponentType
        gameResult.finalBlackPlayerName = finalBlackPlayerName
        gameResult.finalWhitePlayerName = finalWhitePlayerName
        gameResult.finalCapturedBlackPieces = Int16(finalCapturedBlackPieces)
        gameResult.finalCapturedWhitePieces = Int16(finalCapturedWhitePieces)
        gameResult.finalBlacksCapturedValue = Int16(finalBlacksCapturedValue)
        gameResult.finalWhitesCapturedValue = Int16(finalWhitesCapturedValue)
        gameResult.winner = winner

        
        do {
            try context.save()
            print("Game result saved successfully!")
        }
        catch {
            print("Failed to save game result: \(error)")
        }
    }
    
    
    


    // DETERMINE WINNER NAME
    
    func determineWinner() -> String {
        
        if isCheckmate(kingPiece: chessPieces.first { $0.name == "whiteKing" }!) {
            return blackPlayerName ?? "Black"
        }
        
        else if isCheckmate(kingPiece: chessPieces.first { $0.name == "blackKing" }!) {
            
            return whitePlayerName ?? "White"
        }
    
        else {
            return "Draw"
        }

}
    
    
    
    // UPDATE NEW LOCATIONS OF PIECES
    
    func updateChessPieceCoordinates(_ piece: UIImageView, newX: CGFloat, newY: CGFloat) {
        if let index = chessPieces.firstIndex(where: { $0.imageView == piece }) {
            chessPieces[index].x = newX
            chessPieces[index].y = newY
            let name = chessPieces[index].name
            print("\(name) - X: \(newX), Y: \(newY)")
        }
    }
    
    
    
    // GIVE GEST.RECOG TO WHITE PIECES
    
    func addWhiteGestureRecognizers(){
        
            let tapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(pieceTapped))
            whitePawn1.addGestureRecognizer(tapGestureRecognizer1)
            whitePawn1.isUserInteractionEnabled = true
            
            
            let tapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(pieceTapped))
            whitePawn2.addGestureRecognizer(tapGestureRecognizer2)
            whitePawn2.isUserInteractionEnabled = true
            
            
            let tapGestureRecognizer3 = UITapGestureRecognizer(target: self, action: #selector(pieceTapped))
            whitePawn3.addGestureRecognizer(tapGestureRecognizer3)
            whitePawn3.isUserInteractionEnabled = true
            
            
            let tapGestureRecognizer4 = UITapGestureRecognizer(target: self, action: #selector(pieceTapped))
            whitePawn4.addGestureRecognizer(tapGestureRecognizer4)
            whitePawn4.isUserInteractionEnabled = true
            
            
            let tapGestureRecognizer5 = UITapGestureRecognizer(target: self, action: #selector(pieceTapped))
            whitePawn5.addGestureRecognizer(tapGestureRecognizer5)
            whitePawn5.isUserInteractionEnabled = true
            
            
            let tapGestureRecognizer6 = UITapGestureRecognizer(target: self, action: #selector(pieceTapped))
            whitePawn6.addGestureRecognizer(tapGestureRecognizer6)
            whitePawn6.isUserInteractionEnabled = true
            
            
            let tapGestureRecognizer7 = UITapGestureRecognizer(target: self, action: #selector(pieceTapped))
            whitePawn7.addGestureRecognizer(tapGestureRecognizer7)
            whitePawn7.isUserInteractionEnabled = true
            
            
            let tapGestureRecognizer8 = UITapGestureRecognizer(target: self, action: #selector(pieceTapped))
            whitePawn8.addGestureRecognizer(tapGestureRecognizer8)
            whitePawn8.isUserInteractionEnabled = true
            
            
            let tapGestureRecognizer9 = UITapGestureRecognizer(target: self, action: #selector(pieceTapped))
            whiteRook1.addGestureRecognizer(tapGestureRecognizer9)
            whiteRook1.isUserInteractionEnabled = true
            
            
            let tapGestureRecognizer10 = UITapGestureRecognizer(target: self, action: #selector(pieceTapped))
            whiteRook2.addGestureRecognizer(tapGestureRecognizer10)
            whiteRook2.isUserInteractionEnabled = true
            
            
            let tapGestureRecognizer11 = UITapGestureRecognizer(target: self, action: #selector(pieceTapped))
            whiteKnight1.addGestureRecognizer(tapGestureRecognizer11)
            whiteKnight1.isUserInteractionEnabled = true
            
            
            let tapGestureRecognizer12 = UITapGestureRecognizer(target: self, action: #selector(pieceTapped))
            whiteKnight2.addGestureRecognizer(tapGestureRecognizer12)
            whiteKnight2.isUserInteractionEnabled = true
            
            
            let tapGestureRecognizer13 = UITapGestureRecognizer(target: self, action: #selector(pieceTapped))
            whiteBishop1.addGestureRecognizer(tapGestureRecognizer13)
            whiteBishop1.isUserInteractionEnabled = true
            
            
            let tapGestureRecognizer14 = UITapGestureRecognizer(target: self, action: #selector(pieceTapped))
            whiteBishop2.addGestureRecognizer(tapGestureRecognizer14)
            whiteBishop2.isUserInteractionEnabled = true
            
            
            let tapGestureRecognizer15 = UITapGestureRecognizer(target: self, action: #selector(pieceTapped))
            whiteQueen.addGestureRecognizer(tapGestureRecognizer15)
            whiteQueen.isUserInteractionEnabled = true
            
            
            let tapGestureRecognizer16 = UITapGestureRecognizer(target: self, action: #selector(pieceTapped))
            whiteKing.addGestureRecognizer(tapGestureRecognizer16)
            whiteKing.isUserInteractionEnabled = true
            
        
    }
    
    
    
    
    // GIVE GEST.RECOG TO BLACK PIECES
    
    func addBlackGestureRecognizers() {
        
        let tapGestureRecognizer17 = UITapGestureRecognizer(target: self, action: #selector(pieceTapped))
        blackPawn1.addGestureRecognizer(tapGestureRecognizer17)
        blackPawn1.isUserInteractionEnabled = true
        
        
        let tapGestureRecognizer18 = UITapGestureRecognizer(target: self, action: #selector(pieceTapped))
        blackPawn2.addGestureRecognizer(tapGestureRecognizer18)
        blackPawn2.isUserInteractionEnabled = true
        
        
        let tapGestureRecognizer19 = UITapGestureRecognizer(target: self, action: #selector(pieceTapped))
        blackPawn3.addGestureRecognizer(tapGestureRecognizer19)
        blackPawn3.isUserInteractionEnabled = true
        
        
        let tapGestureRecognizer20 = UITapGestureRecognizer(target: self, action: #selector(pieceTapped))
        blackPawn4.addGestureRecognizer(tapGestureRecognizer20)
        blackPawn4.isUserInteractionEnabled = true
        
        
        let tapGestureRecognizer21 = UITapGestureRecognizer(target: self, action: #selector(pieceTapped))
        blackPawn5.addGestureRecognizer(tapGestureRecognizer21)
        blackPawn5.isUserInteractionEnabled = true
        
        
        let tapGestureRecognizer22 = UITapGestureRecognizer(target: self, action: #selector(pieceTapped))
        blackPawn6.addGestureRecognizer(tapGestureRecognizer22)
        blackPawn6.isUserInteractionEnabled = true
        
        
        let tapGestureRecognizer23 = UITapGestureRecognizer(target: self, action: #selector(pieceTapped))
        blackPawn7.addGestureRecognizer(tapGestureRecognizer23)
        blackPawn7.isUserInteractionEnabled = true
        
        
        let tapGestureRecognizer24 = UITapGestureRecognizer(target: self, action: #selector(pieceTapped))
        blackPawn8.addGestureRecognizer(tapGestureRecognizer24)
        blackPawn8.isUserInteractionEnabled = true
        
        
        let tapGestureRecognizer25 = UITapGestureRecognizer(target: self, action: #selector(pieceTapped))
        blackRook1.addGestureRecognizer(tapGestureRecognizer25)
        blackRook1.isUserInteractionEnabled = true
        
        
        let tapGestureRecognizer26 = UITapGestureRecognizer(target: self, action: #selector(pieceTapped))
        blackRook2.addGestureRecognizer(tapGestureRecognizer26)
        blackRook2.isUserInteractionEnabled = true
        
        
        let tapGestureRecognizer27 = UITapGestureRecognizer(target: self, action: #selector(pieceTapped))
        blackKnight1.addGestureRecognizer(tapGestureRecognizer27)
        blackKnight1.isUserInteractionEnabled = true
        
        
        let tapGestureRecognizer28 = UITapGestureRecognizer(target: self, action: #selector(pieceTapped))
        blackKnight2.addGestureRecognizer(tapGestureRecognizer28)
        blackKnight2.isUserInteractionEnabled = true
        
        
        let tapGestureRecognizer29 = UITapGestureRecognizer(target: self, action: #selector(pieceTapped))
        blackBishop1.addGestureRecognizer(tapGestureRecognizer29)
        blackBishop1.isUserInteractionEnabled = true
        
        
        let tapGestureRecognizer30 = UITapGestureRecognizer(target: self, action: #selector(pieceTapped))
        blackBishop2.addGestureRecognizer(tapGestureRecognizer30)
        blackBishop2.isUserInteractionEnabled = true
        
        
        let tapGestureRecognizer31 = UITapGestureRecognizer(target: self, action: #selector(pieceTapped))
        blackQueen.addGestureRecognizer(tapGestureRecognizer31)
        blackQueen.isUserInteractionEnabled = true
        
        
        let tapGestureRecognizer32 = UITapGestureRecognizer(target: self, action: #selector(pieceTapped))
        blackKing.addGestureRecognizer(tapGestureRecognizer32)
        blackKing.isUserInteractionEnabled = true
        
        
        
    }
    
    
    
    
    //  GIVE PROMOTED QUEENS GEST.RECOG
    
    func addPromotedGestureRecognizers(to piece: UIImageView, withTag tag: Int) {
        piece.tag = tag
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pieceTapped))
        piece.addGestureRecognizer(tapGestureRecognizer)
        piece.isUserInteractionEnabled = true
    }


    
    
    
    //  MAKE PIECES TAPPED
    
    @objc func pieceTapped(_ sender: UITapGestureRecognizer) {
        // Eğer daha önce seçilmiş bir taş varsa rengini eski haline getir
        selectedPiece?.layer.borderWidth = 0
        
        // Seçili taşı güncelle
        selectedPiece = sender.view as? UIImageView
        
        // Seçilen taşın rengini değiştir
        selectedPiece?.layer.borderColor = UIColor.blue.cgColor
        selectedPiece?.layer.borderWidth = 2
    }
    
    
    
    
    
    // TAKING INPUT AND PROCESS IT FUNCTION
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        guard let selectedPiece = selectedPiece,
              let moveInputText = moveInput.text else {
            return true
        }
        
        
        
        if selectedPiece == whiteRook1 || selectedPiece == whiteRook2 {
            
            let direction = moveInputText.prefix(1)
            let steps = Int(moveInputText.dropFirst()) ?? 1
            
            moveWhiteRook(selectedPiece, direction: direction, steps: steps)
            checkGameStatus()
        }
        
        
        else if  selectedPiece == whitePawn1 || selectedPiece == whitePawn2 || selectedPiece == whitePawn3 || selectedPiece == whitePawn4 || selectedPiece == whitePawn5 || selectedPiece == whitePawn6 || selectedPiece == whitePawn7 || selectedPiece == whitePawn8 {
            
            let direction: Substring
            let steps: Int
            
            if moveInputText.count > 2 {
                let index = moveInputText.index(moveInputText.startIndex, offsetBy: 2)
                direction = moveInputText.prefix(upTo: index)
                steps = Int(moveInputText[index...]) ?? 1
            } else {
                direction = moveInputText.prefix(1)
                steps = Int(moveInputText.dropFirst()) ?? 1
            }
            
            moveWhitePawn(selectedPiece, direction: direction, steps: steps)
            checkGameStatus()
            
            if opponentType == "AI" {
                checkAndApplyAIMove()
                checkGameStatus()
            }
        }
        
        
        else if selectedPiece == whiteKnight1 || selectedPiece == whiteKnight2 {
            
            let direction = moveInputText.prefix(2)
            
            moveWhiteKnight(selectedPiece, direction: direction)
            checkGameStatus()
        }
        
        
        else if selectedPiece == whiteBishop1 || selectedPiece == whiteBishop2 {
            
            let direction = moveInputText.prefix(2)
            let stepsString = moveInputText.dropFirst(2)
            let steps = Int(stepsString) ?? 1
            
            moveWhiteBishop(selectedPiece, direction: direction, steps: steps)
            checkGameStatus()
        }
        
        
        else if selectedPiece == whiteQueen {
            
            let direction: Substring
            let steps: Int
            
            if moveInputText.count > 2 {
                let index = moveInputText.index(moveInputText.startIndex, offsetBy: 2)
                direction = moveInputText.prefix(upTo: index)
                steps = Int(moveInputText[index...]) ?? 1
            } else {
                direction = moveInputText.prefix(1)
                steps = Int(moveInputText.dropFirst()) ?? 1
            }
            moveWhiteQueen(selectedPiece, direction: direction, steps: steps)
            checkGameStatus()
        }
        
        
        if selectedPiece.tag >= 1000 && selectedPiece.tag < 2000 {
                  
            let direction: Substring
            let steps: Int
            
            if moveInputText.count > 2 {
                let index = moveInputText.index(moveInputText.startIndex, offsetBy: 2)
                direction = moveInputText.prefix(upTo: index)
                steps = Int(moveInputText[index...]) ?? 1
            } else {
                direction = moveInputText.prefix(1)
                steps = Int(moveInputText.dropFirst()) ?? 1
            }
           movePromotedWhiteQueen(selectedPiece, direction: direction, steps: steps)
            checkGameStatus()
        }
        
        
        else if selectedPiece == whiteKing {
            
            let direction: Substring
            
            if moveInputText.count == 1 {
                direction = moveInputText.prefix(1)
            }
            else {
                direction = moveInputText.prefix(2)
            }
            moveWhiteKing(selectedPiece, direction: direction)
            checkGameStatus()
        }
        
        
        if (selectedPiece == whiteKing || selectedPiece == blackKing) && (moveInputText == "scastle" || moveInputText == "lcastle") {
                performCastle(with: selectedPiece, moveInputText: moveInputText)
            }
        
        
        
        
        
        
        
        if selectedPiece  == blackPawn1 || selectedPiece == blackPawn2 || selectedPiece == blackPawn3 || selectedPiece == blackPawn4 || selectedPiece == blackPawn5 || selectedPiece == blackPawn6 || selectedPiece == blackPawn7 || selectedPiece == blackPawn8 {
            
             let direction: Substring
             let steps: Int
             
             if moveInputText.count > 2 {
                 let index = moveInputText.index(moveInputText.startIndex, offsetBy: 2)
                 direction = moveInputText.prefix(upTo: index)
                 steps = Int(moveInputText[index...]) ?? 1
             } else {
                 direction = moveInputText.prefix(1)
                 steps = Int(moveInputText.dropFirst()) ?? 1
             }
             
             moveBlackPawn(selectedPiece, direction: direction, steps: steps)
             checkGameStatus()
             
        }
        
        
        else if  selectedPiece == blackRook1 || selectedPiece == blackRook2 {
            
            let direction = moveInputText.prefix(1)
            let steps = Int(moveInputText.dropFirst()) ?? 1
            
            moveBlackRook(selectedPiece, direction: direction, steps: steps)
            checkGameStatus()
        }
        
        
        else if selectedPiece == blackKnight1 || selectedPiece == blackKnight2 {
            
            let direction = moveInputText.prefix(2)
            
            moveBlackKnight(selectedPiece, direction: direction)
            checkGameStatus()
        }
        
        
        else if selectedPiece == blackBishop1 || selectedPiece == blackBishop2 {
            
            let direction = moveInputText.prefix(2)
            let stepsString = moveInputText.dropFirst(2)
            let steps = Int(stepsString) ?? 1
            
            moveBlackBishop(selectedPiece, direction: direction, steps: steps)
            checkGameStatus()
        }
        
        
        else if selectedPiece == blackQueen {
            
            let direction: Substring
            let steps: Int
            
            if moveInputText.count > 2 {
                let index = moveInputText.index(moveInputText.startIndex, offsetBy: 2)
                direction = moveInputText.prefix(upTo: index)
                steps = Int(moveInputText[index...]) ?? 1
            } else {
                direction = moveInputText.prefix(1)
                steps = Int(moveInputText.dropFirst()) ?? 1
            }
            moveBlackQueen(selectedPiece, direction: direction, steps: steps)
            checkGameStatus()
        }
        
        
        if selectedPiece.tag >= 2000 {
            
            let direction: Substring
            let steps: Int

            if moveInputText.count > 2 {
                let index = moveInputText.index(moveInputText.startIndex, offsetBy: 2)
                direction = moveInputText.prefix(upTo: index)
                steps = Int(moveInputText[index...]) ?? 1
            } else {
                direction = moveInputText.prefix(1)
                steps = Int(moveInputText.dropFirst()) ?? 1
            }
            movePromotedBlackQueen(selectedPiece, direction: direction, steps: steps)
            checkGameStatus()
        }

        
        else if selectedPiece == blackKing {
            
            let direction: Substring
            
            if moveInputText.count == 1 {
                direction = moveInputText.prefix(1)
            }
            else {
                direction = moveInputText.prefix(2)
            }
            moveBlackKing(selectedPiece, direction: direction)
            checkGameStatus()
        }
        
        
        
        
        
        
        
        
        selectedPiece.layer.borderWidth = 0
        
        
        
        
        textField.resignFirstResponder()
        
        
        
        return true
    }
    
    
    
    
    
    // LOOKING IS TARGET SQUARE EMPTY
    
    func isSquareEmpty(atX x: CGFloat, atY y: CGFloat) -> Bool {
        return !chessPieces.contains(where: { $0.x == x && $0.y == y })
    }
    
    
    
    // BOARD BOUNDS
    
    func isWithinBounds(x: CGFloat, y: CGFloat) -> Bool {
        return x >= 7 && x <= 357 && y >= 160 && y <= 510
    }

    
    
    // IS TARGET PIECE OPPONENT
    
    func isOppositeColor(_ piece1: ChessPiece, _ piece2: ChessPiece) -> Bool {
        return (piece1.name.contains("white") && piece2.name.contains("black")) ||
               (piece1.name.contains("black") && piece2.name.contains("white"))
    }
    
    
    
    
    // CAPTURED PIECE DISPLAY FUNCTION
    
    func capturePiece(_ piece: UIImageView) {
        piece.frame.size = CGSize(width: 30, height: 30)

        let pieceName = chessPieces.first { $0.imageView == piece }?.name ?? ""
        let pieceValue = calculatePieceValue(pieceName)
        
        let isPieceBlack = pieceName.contains("black")

        if isPieceBlack {
            
            let xPosition = 7 + (capturedBlackPieces.count % 3) * 33
            let yPosition = 560 + (capturedBlackPieces.count / 3) * 30
            piece.frame.origin = CGPoint(x: xPosition, y: yPosition)
            capturedBlackPieces.append(piece)
            blackCapturedValue += pieceValue
            
        }
        
        else {
            
            let xPosition = 357 - (capturedWhitePieces.count % 3) * 33
            let yPosition = 560 + (capturedWhitePieces.count / 3) * 30
            piece.frame.origin = CGPoint(x: xPosition, y: yPosition)
            capturedWhitePieces.append(piece)
            whiteCapturedValue += pieceValue
            
        }

        if pieceSoundStatus == "On" {
            captureSoundPlayer?.play()
        }
        
        self.view.addSubview(piece)
    }


    
    
    
    
    // DETERMINE VALUE OF PIECES
    
    func calculatePieceValue(_ pieceName: String) -> Int {
        if pieceName.contains("Pawn") {
            return 1
        } else if pieceName.contains("Knight") || pieceName.contains("Bishop") {
            return 3
        } else if pieceName.contains("Rook") {
            return 5
        } else if pieceName.contains("Queen") {
            return 9
        }
        else {
            return 0
        }
    }

    
    
    
    
    
    //PAWN PROMOTING FUNCTIONS
    
    func promoteWhitePawnToQueenClone(pawn: ChessPiece, atLocation location: CGPoint) {
        guard let pawnIndex = chessPieces.firstIndex(where: { $0.imageView == pawn.imageView }) else {
            print("Pawn not found in the chessPieces array.")
            return
        }

        let removedPawn = chessPieces.remove(at: pawnIndex)
        removedPawn.imageView.removeFromSuperview()

        let queenCloneName = "whiteQueenClone\(promotedWhiteQueenCounter)"
        promotedWhiteQueenCounter += 1
        
        print("New promoted white queen created: \(queenCloneName)")

        let newQueenImageView = UIImageView(image: UIImage(named: "queen1"))
        newQueenImageView.frame = CGRect(origin: location, size: CGSize(width: 50, height: 50))
        newQueenImageView.contentMode = .scaleAspectFit
        view.addSubview(newQueenImageView)

        let queenClone = ChessPiece(name: queenCloneName, imageView: newQueenImageView, x: location.x, y: location.y)
        chessPieces.append(queenClone)
        
        let newQueenTag = 1000 + promotedWhiteQueenCounter  // Benzersiz bir tag beyaz için
        addPromotedGestureRecognizers(to: newQueenImageView, withTag: newQueenTag)

        print("New white queen clone added: \(queenCloneName) at x: \(location.x), y: \(location.y)")
        
    }
    
    
    
    func promoteBlackPawnToQueenClone(pawn: ChessPiece, atLocation location: CGPoint) {
        guard let pawnIndex = chessPieces.firstIndex(where: { $0.imageView == pawn.imageView }) else {
            print("Pawn not found in the chessPieces array.")
            return
        }

        let removedPawn = chessPieces.remove(at: pawnIndex)
        removedPawn.imageView.removeFromSuperview()

        let queenCloneName = "blackQueenClone\(promotedBlackQueenCounter)"
        promotedBlackQueenCounter += 1
        
        print("New promoted black queen created: \(queenCloneName)")

        let newQueenImageView = UIImageView(image: UIImage(named: "queen2"))
        newQueenImageView.frame = CGRect(origin: location, size: CGSize(width: 50, height: 50))
        newQueenImageView.contentMode = .scaleAspectFit
        view.addSubview(newQueenImageView)

        let queenClone = ChessPiece(name: queenCloneName, imageView: newQueenImageView, x: location.x, y: location.y)
        chessPieces.append(queenClone)
        
        let newQueenTag = 2000 + promotedBlackQueenCounter  // Benzersiz bir tag siyah için
        addPromotedGestureRecognizers(to: newQueenImageView, withTag: newQueenTag)

        print("New black queen clone added: \(queenCloneName) at x: \(location.x), y: \(location.y)")
        
    }



    
    
    
    
        // ALERTS
    
    func presentWrongTurnAlert() {
        let alertController = UIAlertController(title: "Its Not Your Turn ", message: "Please Wait Your Turn", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(okAction)
        
        if pieceSoundStatus == "On" {
            illegalSoundPlayer?.play()
        }
        present(alertController, animated: true, completion: nil)
    }
    
    
    func presentMoveBlockedAlert() {
        let alertController = UIAlertController(title: "Wrong Move", message: "Please Enter a valid move", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(okAction)
        
        if pieceSoundStatus == "On" {
            illegalSoundPlayer?.play()
        }
        present(alertController, animated: true, completion: nil)
    }
    
    
    func presentInvalidDirectionAlert() {
        let alertController = UIAlertController(title: "Wrong Direction", message: "Please Enter a valid move", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(okAction)
        
        if pieceSoundStatus == "On" {
            illegalSoundPlayer?.play()
        }
        present(alertController, animated: true, completion: nil)
    }
    
    
    func presentOutOfBoardAlert() {
        let alertController = UIAlertController(title: "Out of Board", message: "Please Enter a valid move", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(okAction)
        
        if pieceSoundStatus == "On" {
            illegalSoundPlayer?.play()
        }
        present(alertController, animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    
    // CASTLE FUNCTIONS
    // BUG IN HERE
    
    func performCastle(with king: UIImageView, moveInputText: String) {
        guard let kingIndex = chessPieces.firstIndex(where: { $0.imageView == king }) else { return }
        let kingPiece = chessPieces[kingIndex]

        if moveInputText == "scastle" {
            
            if canPerformCastle(kingPiece: kingPiece, isKingSide: true, isQueenSide: false) {
                moveKingAndRookForCastle(kingPiece: kingPiece, isKingSideCastle: true)
            } else {
                presentInvalidDirectionAlert()
            }
        } else if moveInputText == "lcastle" {
            
            if canPerformCastle(kingPiece: kingPiece, isKingSide: false, isQueenSide: true) {
                moveKingAndRookForCastle(kingPiece: kingPiece, isKingSideCastle: false)
            } else {
                presentInvalidDirectionAlert()
            }
        } else {
            presentInvalidDirectionAlert()
        }
    }



    
    
    func moveKingAndRookForCastle(kingPiece: ChessPiece, isKingSideCastle: Bool) {
        let kingNewX: CGFloat = isKingSideCastle ? 307 : 107 // Kısa rok için 307, uzun rok için 107
        let rookNewX: CGFloat = isKingSideCastle ? 257 : 157 // Kısa rok için 257, uzun rok için 157

        guard let rookIndex = chessPieces.firstIndex(where: { $0.name == (kingPiece.name.contains("white") ? "whiteRook" : "blackRook") + (isKingSideCastle ? "2" : "1") }) else { return }
        let rookPiece = chessPieces[rookIndex]

        UIView.animate(withDuration: 0.5, animations: {
            kingPiece.imageView.frame.origin = CGPoint(x: kingNewX, y: kingPiece.y)
            rookPiece.imageView.frame.origin = CGPoint(x: rookNewX, y: rookPiece.y)
        })
        updateChessPieceCoordinates(kingPiece.imageView, newX: kingNewX, newY: kingPiece.y)
        updateChessPieceCoordinates(rookPiece.imageView, newX: rookNewX, newY: rookPiece.y)
    }



    
    
    
    func canPerformCastle(kingPiece: ChessPiece, isKingSide: Bool, isQueenSide: Bool) -> Bool {
        // Şahın başlangıç pozisyonunda olup olmadığını ve tehdit altında olmadığını kontrol et
        let isKingInInitialPosition = (kingPiece.name == "whiteKing" && kingPiece.y == 510) || (kingPiece.name == "blackKing" && kingPiece.y == 160)
        if !isKingInInitialPosition || isKingUnderThreat(kingPiece: kingPiece) {
            return false
        }

        // Rok yapılacak yoldaki tüm karelerin boş olup olmadığını kontrol et
        let direction = isKingSide ? "r" : (isQueenSide ? "l" : "")
        return isPathClearForCastle(kingPiece: kingPiece, direction: direction)
    }


    
    
    func isPathClearForCastle(kingPiece: ChessPiece, direction: String) -> Bool {
        let step = CGFloat(direction == "r" ? 50 : -50)
        var checkX = kingPiece.x + step

        while direction == "r" ? (checkX < kingPiece.x + CGFloat(200)) : (checkX > kingPiece.x - CGFloat(200)) {
            if !isSquareEmpty(atX: checkX, atY: kingPiece.y) {
                return false
            }
            checkX += step
        }

        return true
    }


    
    /*
    func isKingUnderThreat(kingPiece: ChessPiece) -> Bool {
        // Şahın mevcut pozisyonunu al
        let kingX = kingPiece.x
        let kingY = kingPiece.y

        // Tüm rakip taşları tarayarak şahın tehdit altında olup olmadığını kontrol et
        for piece in chessPieces where piece.name.contains(kingPiece.name.contains("white") ? "black" : "white") {
            // Her bir taşın hareket yeteneğine göre tehdit durumunu kontrol et
            switch piece.name {
            case let name where name.contains("Pawn"):
                // Piyonlar sadece çapraz hareketlerde şahı tehdit edebilir
                if abs(piece.x - kingX) == 50 && (kingPiece.name.contains("white") ? (piece.y - kingY == -50) : (piece.y - kingY == 50)) {
                    return true
                }
            case let name where name.contains("Rook"):
                // Kaleler düz hatlarda tehdit oluşturabilir
                if piece.x == kingX || piece.y == kingY {
                    if isPathClear(piece.x, piece.y, kingX, kingY) {
                        return true
                    }
                }
            case let name where name.contains("Knight"):
                // Atlar L şeklinde hareket eder
                if (abs(piece.x - kingX) == 100 && abs(piece.y - kingY) == 50) || (abs(piece.x - kingX) == 50 && abs(piece.y - kingY) == 100) {
                    return true
                }
            case let name where name.contains("Bishop"):
                // Filler çapraz hatlarda tehdit oluşturabilir
                if abs(piece.x - kingX) == abs(piece.y - kingY) {
                    if isPathClear(piece.x, piece.y, kingX, kingY) {
                        return true
                    }
                }
            case let name where name.contains("Queen"):
                // Vezir her iki yönde de tehdit oluşturabilir
                if piece.x == kingX || piece.y == kingY || abs(piece.x - kingX) == abs(piece.y - kingY) {
                    if isPathClear(piece.x, piece.y, kingX, kingY) {
                        return true
                    }
                }
            default:
                break
            }
        }

        
        return false
    }
    */
    
    
    
    
    func isKingUnderThreat(kingPiece: ChessPiece) -> Bool {
        let kingX = kingPiece.x
        let kingY = kingPiece.y
        for piece in chessPieces where piece.name.contains(kingPiece.name.contains("white") ? "black" : "white") {
            if canPieceMoveTo(piece: piece, x: kingX, y: kingY) && isPathClear(piece.x, piece.y, kingX, kingY) {
                
                return true
            }
        }
        return false
    }
    
    
    
    
    
    func isPathClear(_ startX: CGFloat, _ startY: CGFloat, _ endX: CGFloat, _ endY: CGFloat) -> Bool {
        let deltaX = CGFloat(endX > startX ? 50 : (endX < startX ? -50 : 0))
        let deltaY = CGFloat(endY > startY ? 50 : (endY < startY ? -50 : 0))

        var currentX = startX + deltaX
        var currentY = startY + deltaY

        while currentX != endX || currentY != endY {
            if !isSquareEmpty(atX: currentX, atY: currentY) {
                return false
            }

            currentX += deltaX
            currentY += deltaY
        }

        return true
    }

    
    
    
    
    
    
    
    // CHECK AND CHECKMATE STATES
    
    func isCheckmate(kingPiece: ChessPiece) -> Bool {
        if isKingUnderThreat(kingPiece: kingPiece) {
            if !canKingEscape(kingPiece: kingPiece) && !canOthersSaveKing(kingPiece: kingPiece) {
                return true
            }
        }
        return false
    }

    
    
    
    
    
    func canKingEscape(kingPiece: ChessPiece) -> Bool {
        let escapeOffsets = [(-50, 0), (50, 0), (0, -50), (0, 50), (-50, -50), (50, 50), (50, -50), (-50, 50)]
        var safeSquares: [(CGFloat, CGFloat)] = []

        for offset in escapeOffsets {
            let newX = kingPiece.x + CGFloat(offset.0)
            let newY = kingPiece.y + CGFloat(offset.1)

            if isWithinBounds(x: newX, y: newY) && isSquareSafeForKing(x: newX, y: newY, kingColor: kingPiece.name.contains("white") ? "white" : "black") {
                safeSquares.append((newX, newY))
            }
        }
        if safeSquares.isEmpty {
            print("King cannot escape.")
            return false
        } else {
            print("King can escape to \(safeSquares.count) squares: \(safeSquares)")
            return true
        }
    }

    
    
    
    
    
    
    func isSquareSafeForKing(x: CGFloat, y: CGFloat, kingColor: String) -> Bool {
        
        if !isWithinBounds(x: x, y: y) {
                return false
            }
        
        for piece in chessPieces where piece.name.contains(kingColor == "white" ? "black" : "white") {
            if canPieceMoveTo(piece: piece, x: x, y: y) && isPathClear(piece.x, piece.y, x, y) {
                
                return false
            }
        }
        print("Square safe: \(x), \(y)")
        return isSquareEmpty(atX: x, atY: y) || !isKingUnderThreat(kingPiece: ChessPiece(name: kingColor + "King", imageView: UIImageView(), x: x, y: y))
    }



    
    
    
    
    func canOthersSaveKing(kingPiece: ChessPiece) -> Bool {
        let threats = findThreateningPieces(kingPiece: kingPiece)

        if threats.isEmpty {
            
            return true
        }

        if threats.count > 1 {
            
            return false
        } else if let threat = threats.first {
            for piece in chessPieces where piece.name.contains(kingPiece.name.contains("white") ? "white" : "black") && piece.name != kingPiece.name {
                if canPieceMoveTo(piece: piece, x: threat.x, y: threat.y) && isPathClear(piece.x, piece.y, threat.x, threat.y) {
                    print("\(piece.name) tehdidi engelleyebilir: \(threat.name)")
                    return true
                }
            }
        }
    
        return false
    }



    
    
    
    
    func findThreateningPieces(kingPiece: ChessPiece) -> [ChessPiece] {
        var threats: [ChessPiece] = []
        for piece in chessPieces where piece.name.contains(kingPiece.name.contains("white") ? "black" : "white") {
            if canPieceMoveTo(piece: piece, x: kingPiece.x, y: kingPiece.y) && isPathClear(piece.x, piece.y, kingPiece.x, kingPiece.y) {
                print("\(piece.name) is threatening the King at \(kingPiece.x), \(kingPiece.y)")
                threats.append(piece)
            }
        }
        print("Total number of threats: \(threats.count)")
        return threats
    }

    
    
    
    
    
    
    
    func canPieceMoveTo(piece: ChessPiece, x: CGFloat, y: CGFloat) -> Bool {
        let currentX = piece.x
        let currentY = piece.y

        switch piece.name {
        case let name where name.contains("Pawn"):
            // Piyonlar için hareket kuralları
            if piece.name.contains("white") {
                // Beyaz piyonlar için hareket kuralları
                if (currentY - y == 50 && currentX == x && isSquareEmpty(atX: x, atY: y)) ||
                   (currentY == 460 && currentY - y == 100 && currentX == x && isPathClear(currentX, currentY, x, y)) {
                    // İleri hareket
                    return true
                } else if abs(currentX - x) == 50 && currentY - y == 50 && !isSquareEmpty(atX: x, atY: y) {
                    // Çapraz hareket
                    return true
                }
            } else {
                // Siyah piyonlar için hareket kuralları
                // ...
            }

        case let name where name.contains("Rook"):
            // Kaleler için hareket kuralları
            if (currentX == x || currentY == y) && isPathClear(currentX, currentY, x, y) {
                return true
            }

        case let name where name.contains("Knight"):
            // Atlar için hareket kuralları
            if (abs(currentX - x) == 100 && abs(currentY - y) == 50) || (abs(currentX - x) == 50 && abs(currentY - y) == 100) {
                return true
            }

        case let name where name.contains("Bishop"):
            // Filler için hareket kuralları
            if abs(currentX - x) == abs(currentY - y) && isPathClear(currentX, currentY, x, y) {
                return true
            }

        case let name where name.contains("Queen"):
            // Vezirler için hareket kuralları
            if (currentX == x || currentY == y || abs(currentX - x) == abs(currentY - y)) && isPathClear(currentX, currentY, x, y) {
                return true
            }

        case let name where name.contains("King"):
            // Şahlar için hareket kuralları
            if abs(currentX - x) <= 50 && abs(currentY - y) <= 50 {
                return true
            }

        default:
            return false
        }

        return false
    }
    
    
    
    
    
    
    
    func checkGameStatus() {
        let whiteKing = chessPieces.first(where: { $0.name == "whiteKing" })
        let blackKing = chessPieces.first(where: { $0.name == "blackKing" })

        if let whiteKing = whiteKing {
            
            if isCheckmate(kingPiece: whiteKing) {
                print("Checkmate! Black wins.")
                endGame()
            }
        }

        
        if let blackKing = blackKing {
            
            if isCheckmate(kingPiece: blackKing) {
                print("Checkmate! White wins.")
                endGame()
                
            }
        }
    }
    
    
    

    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
     
    
    
    
    
    // WHITE PAWN MOVING FUNCTION
   
    func moveWhitePawn(_ piece: UIImageView, direction: Substring, steps: Int) {
        guard let index = chessPieces.firstIndex(where: { $0.imageView == piece }) else {
            return
        }
        
        let originalPosition = CGPoint(x: chessPieces[index].x, y: chessPieces[index].y) // Taşın orijinal pozisyonunu kaydet
        var capturedPiece: ChessPiece?
        
        let isAtStartingPosition = chessPieces[index].name.contains("whitePawn") && chessPieces[index].y == 460
        
        var newX = chessPieces[index].x
        var newY = chessPieces[index].y
        
        let movingChessPiece = chessPieces[index]
        
        let stepSize = CGFloat(50)
        let allowedSteps = isAtStartingPosition ? 2 : 1
        
        if turnIndicatorView.backgroundColor == UIColor.systemBrown {
            
        if direction == "f" && steps <= allowedSteps {
            let potentialNewY = newY - CGFloat(steps) * stepSize
            
            for step in 1...steps {
                let checkingY = newY - CGFloat(step) * stepSize
                if !isSquareEmpty(atX: newX, atY: checkingY) {
                    presentMoveBlockedAlert()
                    return
                }
            }
            
            newY = potentialNewY
        }
        
        
        else if (direction == "fl" || direction == "fr") && steps == 1 {
            
            let targetX = (direction == "fl") ? newX - stepSize : newX + stepSize
            let targetY = newY - stepSize
            
            
            if let targetIndex = chessPieces.firstIndex(where: { $0.x == targetX && $0.y == targetY }) {
                if isOppositeColor(chessPieces[index], chessPieces[targetIndex]) {
                    
                    capturePiece(chessPieces[targetIndex].imageView)
                    chessPieces.remove(at: targetIndex)
                    newX = targetX
                    newY = targetY
                }
                else {
                    presentMoveBlockedAlert()
                    return
                }
            }
            else {
                presentMoveBlockedAlert()
                return
            }
        }
        else {
            presentInvalidDirectionAlert()
            return
        }
    }
    else {
        presentWrongTurnAlert()
        return
        
    }
        
            
            if newX >= 7 && newX <= 357 && newY >= 160 && newY <= 510 {
                UIView.animate(withDuration: 0.5, animations: {
                    piece.frame.origin = CGPoint(x: newX, y: newY)
                })
                updateChessPieceCoordinates(piece, newX: newX, newY: newY)
                
                if pieceSoundStatus == "On" {
                    moveSoundPlayer?.play()
                }
                
                moveCounter += 1
                self.changeTurn()
                
                if let targetIndex = chessPieces.firstIndex(where: { $0.x == newX && $0.y == newY && $0.imageView != piece }) {
                    capturedPiece = chessPieces[targetIndex]
                }
                
                // Hamle kaydını oluştur ve kaydet
                let moveRecord = MoveRecord(movedPiece: chessPieces[index],
                                            capturedPiece: capturedPiece,
                                            fromPosition: originalPosition,
                                            toPosition: CGPoint(x: newX, y: newY))
                moveHistory.append(moveRecord)
                
                
                
                // Piyonun terfi durumunu kontrol et
                if (movingChessPiece.name.contains("whitePawn") && newY == 160)  {
                    // Piyonu vezire terfi ettir
                    promoteWhitePawnToQueenClone(pawn: movingChessPiece, atLocation: CGPoint(x: newX, y: newY))
                }
                
            }
            
            else {
                presentOutOfBoardAlert()
            }
        
    }


    
    
    // BLACK PAWN MOVING FUNCTION
    
    func moveBlackPawn(_ piece: UIImageView, direction: Substring, steps: Int) {
        guard let index = chessPieces.firstIndex(where: { $0.imageView == piece }) else {
            return
        }
        
        let originalPosition = CGPoint(x: chessPieces[index].x, y: chessPieces[index].y) // Taşın orijinal pozisyonunu kaydet
            var capturedPiece: ChessPiece?
        

        let isAtStartingPosition = chessPieces[index].name.contains("blackPawn") && chessPieces[index].y == 210

        var newX = chessPieces[index].x
        var newY = chessPieces[index].y
        
        let movingChessPiece = chessPieces[index]

        let stepSize = CGFloat(50)
        let allowedSteps = isAtStartingPosition ? 2 : 1
        
        if turnIndicatorView.backgroundColor == UIColor.black {
            
            if direction == "f" && steps <= allowedSteps {
                let potentialNewY = newY + CGFloat(steps) * stepSize
                
                for step in 1...steps {
                    let checkingY = newY + CGFloat(step) * stepSize
                    if !isSquareEmpty(atX: newX, atY: checkingY) {
                        presentMoveBlockedAlert()
                        return
                    }
                }
                
                newY = potentialNewY
            }
            
            else if (direction == "fl" || direction == "fr") && steps == 1 {
                let targetX = (direction == "fr") ? newX + stepSize : newX - stepSize
                let targetY = newY + stepSize
                
                if let targetIndex = chessPieces.firstIndex(where: { $0.x == targetX && $0.y == targetY }) {
                    if isOppositeColor(chessPieces[index], chessPieces[targetIndex]) {
                        capturePiece(chessPieces[targetIndex].imageView)
                        chessPieces.remove(at: targetIndex)
                        newX = targetX
                        newY = targetY
                    } else {
                        presentMoveBlockedAlert()
                        return
                    }
                } else {
                    presentMoveBlockedAlert()
                    return
                }
            }
            else {
                presentInvalidDirectionAlert()
                return
            }
        }
        else {
            presentWrongTurnAlert()
            return
        }

        if newX >= 7 && newX <= 357 && newY >= 160 && newY <= 510 {
            UIView.animate(withDuration: 0.5, animations: {
                piece.frame.origin = CGPoint(x: newX, y: newY)
            })
            updateChessPieceCoordinates(piece, newX: newX, newY: newY)
            
            if pieceSoundStatus == "On" {
                moveSoundPlayer?.play()
            }
            
            moveCounter += 1
            self.changeTurn()
            
            if let targetIndex = chessPieces.firstIndex(where: { $0.x == newX && $0.y == newY && $0.imageView != piece }) {
                        capturedPiece = chessPieces[targetIndex]
                    }

                    // Hamle kaydını oluştur ve kaydet
                    let moveRecord = MoveRecord(movedPiece: chessPieces[index],
                                                capturedPiece: capturedPiece,
                                                fromPosition: originalPosition,
                                                toPosition: CGPoint(x: newX, y: newY))
                    moveHistory.append(moveRecord)
            
            
            // Piyonun terfi durumunu kontrol et
            if movingChessPiece.name.contains("blackPawn") && newY == 510 {
                // Piyonu vezire terfi ettir
                promoteBlackPawnToQueenClone(pawn: movingChessPiece, atLocation: CGPoint(x: newX, y: newY))
            }
        }
        
        else {
            presentOutOfBoardAlert()
        }
    }

    
    
    
    
    
    //  WHITE ROOK MOVING FUNCTION
    
    func moveWhiteRook(_ piece: UIImageView, direction: Substring, steps: Int) {
        guard let pieceIndex = chessPieces.firstIndex(where: { $0.imageView == piece }) else {
            return
        }

        let originalPosition = CGPoint(x: chessPieces[pieceIndex].x, y: chessPieces[pieceIndex].y)
            var capturedPiece: ChessPiece?
        
        var newX = chessPieces[pieceIndex].x
        var newY = chessPieces[pieceIndex].y
        let stepSize = CGFloat(50)

        var moveCompleted = false  // Taşın hareketinin tamamlanıp tamamlanmadığını izler

        if turnIndicatorView.backgroundColor == UIColor.systemBrown {
            
            switch direction {
            case "f", "b", "l", "r":
                for step in 1...steps {
                    let checkingX = direction == "l" ? newX - CGFloat(step) * stepSize :
                    direction == "r" ? newX + CGFloat(step) * stepSize : newX
                    let checkingY = direction == "f" ? newY - CGFloat(step) * stepSize :
                    direction == "b" ? newY + CGFloat(step) * stepSize : newY
                    
                    if let targetIndex = chessPieces.firstIndex(where: { $0.x == checkingX && $0.y == checkingY }) {
                        if isOppositeColor(chessPieces[pieceIndex], chessPieces[targetIndex]) {
                            // Rakip taş yenilir ve yeni pozisyona taşınır
                            capturePiece(chessPieces[targetIndex].imageView)
                            chessPieces.remove(at: targetIndex)
                            newX = checkingX
                            newY = checkingY
                            moveCompleted = true
                            break
                        } else {
                            presentMoveBlockedAlert()
                            return
                        }
                    }
                }
                
                if !moveCompleted {
                    // Eğer hiçbir taş yeme işlemi gerçekleşmediyse, kaleyi son hedefe taşı
                    newX = direction == "l" ? newX - CGFloat(steps) * stepSize :
                    direction == "r" ? newX + CGFloat(steps) * stepSize : newX
                    newY = direction == "f" ? newY - CGFloat(steps) * stepSize :
                    direction == "b" ? newY + CGFloat(steps) * stepSize : newY
                }
            default:
                presentInvalidDirectionAlert()
                return
            }
        }
        else {
            presentWrongTurnAlert()
            return
        }

        
        if newX >= 7 && newX <= 357 && newY >= 160 && newY <= 510  {
            UIView.animate(withDuration: 0.5, animations: {
                piece.frame.origin = CGPoint(x: newX, y: newY)
            })
            updateChessPieceCoordinates(piece, newX: newX, newY: newY)
            
            if pieceSoundStatus == "On" {
                moveSoundPlayer?.play()
            }
            
            moveCounter += 1
            self.changeTurn()
            
            if let targetIndex = chessPieces.firstIndex(where: { $0.x == newX && $0.y == newY && $0.imageView != piece }) {
                        capturedPiece = chessPieces[targetIndex]
                    }

                    let moveRecord = MoveRecord(movedPiece: chessPieces[pieceIndex],
                                                capturedPiece: capturedPiece,
                                                fromPosition: originalPosition,
                                                toPosition: CGPoint(x: newX, y: newY))
                    moveHistory.append(moveRecord)
            
        }
        
        else {
            presentOutOfBoardAlert()
        }
    }

    
    
    
    
    // BLACK ROOK MOVING FUNCTION
    
    func moveBlackRook(_ piece: UIImageView, direction: Substring, steps: Int) {
        guard let pieceIndex = chessPieces.firstIndex(where: { $0.imageView == piece }) else {
            return
        }

        let originalPosition = CGPoint(x: chessPieces[pieceIndex].x, y: chessPieces[pieceIndex].y)
            var capturedPiece: ChessPiece?
        
        var newX = chessPieces[pieceIndex].x
        var newY = chessPieces[pieceIndex].y
        let stepSize = CGFloat(50)

        var moveCompleted = false  // Taşın hareketinin tamamlanıp tamamlanmadığını izler

        if turnIndicatorView.backgroundColor == UIColor.black {
            
            switch direction {
            case "f", "b", "l", "r":
                for step in 1...steps {
                    let checkingX = direction == "l" ? newX - CGFloat(step) * stepSize :
                    direction == "r" ? newX + CGFloat(step) * stepSize : newX
                    let checkingY = direction == "f" ? newY + CGFloat(step) * stepSize :  // Yön değişikliği burada
                    direction == "b" ? newY - CGFloat(step) * stepSize : newY  // Yön değişikliği burada
                    
                    if let targetIndex = chessPieces.firstIndex(where: { $0.x == checkingX && $0.y == checkingY }) {
                        if isOppositeColor(chessPieces[pieceIndex], chessPieces[targetIndex]) {
                            // Rakip taş yenilir ve yeni pozisyona taşınır
                            capturePiece(chessPieces[targetIndex].imageView)
                            chessPieces.remove(at: targetIndex)
                            newX = checkingX
                            newY = checkingY
                            moveCompleted = true
                            break
                        } else {
                            presentMoveBlockedAlert()
                            return
                        }
                    }
                }
                
                if !moveCompleted {
                    // Eğer hiçbir taş yeme işlemi gerçekleşmediyse, kaleyi son hedefe taşı
                    newX = direction == "l" ? newX - CGFloat(steps) * stepSize :
                    direction == "r" ? newX + CGFloat(steps) * stepSize : newX
                    newY = direction == "f" ? newY + CGFloat(steps) * stepSize :  // Yön değişikliği burada
                    direction == "b" ? newY - CGFloat(steps) * stepSize : newY  // Yön değişikliği burada
                }
            default:
                presentInvalidDirectionAlert()
                return
            }
        }
        else {
            presentWrongTurnAlert()
            return
        }

        
        if newX >= 7 && newX <= 357 && newY >= 160 && newY <= 510  {
            UIView.animate(withDuration: 0.5, animations: {
                piece.frame.origin = CGPoint(x: newX, y: newY)
            })
            updateChessPieceCoordinates(piece, newX: newX, newY: newY)
            
            if pieceSoundStatus == "On" {
                moveSoundPlayer?.play()
            }
            
            moveCounter += 1
            self.changeTurn()
            
            if let targetIndex = chessPieces.firstIndex(where: { $0.x == newX && $0.y == newY && $0.imageView != piece }) {
                        capturedPiece = chessPieces[targetIndex]
                    }

                    let moveRecord = MoveRecord(movedPiece: chessPieces[pieceIndex],
                                                capturedPiece: capturedPiece,
                                                fromPosition: originalPosition,
                                                toPosition: CGPoint(x: newX, y: newY))
                    moveHistory.append(moveRecord)
            
        }
        
        else {
            presentOutOfBoardAlert()
        }
    }

    
    
    
    
    
    // WHITE KNIGHT MOVING FUNCTION
    
    func moveWhiteKnight(_ knight: UIImageView, direction: Substring) {
        guard let index = chessPieces.firstIndex(where: { $0.imageView == knight }) else {
            return
        }
        
        let originalPosition = CGPoint(x: chessPieces[index].x, y: chessPieces[index].y)
            var capturedPiece: ChessPiece?

        var newX = chessPieces[index].x
        var newY = chessPieces[index].y
        let stepSize = CGFloat(50)

        if turnIndicatorView.backgroundColor == UIColor.systemBrown {
            
            switch direction {
            case "fr":
                newX += stepSize
                newY -= 2 * stepSize
            case "fl":
                newX -= stepSize
                newY -= 2 * stepSize
            case "rf":
                newX += 2 * stepSize
                newY -= stepSize
            case "lf":
                newX -= 2 * stepSize
                newY -= stepSize
            case "br":
                newX += stepSize
                newY += 2 * stepSize
            case "bl":
                newX -= stepSize
                newY += 2 * stepSize
            case "rb":
                newX += 2 * stepSize
                newY += stepSize
            case "lb":
                newX -= 2 * stepSize
                newY += stepSize
            default:
                presentInvalidDirectionAlert()
                return
            }
            
            // Yol boyunca başka bir taş var mı kontrol et
            if let targetIndex = chessPieces.firstIndex(where: { $0.x == newX && $0.y == newY }) {
                if isOppositeColor(chessPieces[index], chessPieces[targetIndex]) {
                    // Rakip taş yenilir ve yeni pozisyona taşınır
                    capturePiece(chessPieces[targetIndex].imageView)
                    chessPieces.remove(at: targetIndex)
                } else {
                    presentMoveBlockedAlert()
                    return
                }
            }
        }
        else {
            presentWrongTurnAlert()
            return
        }

        // Hareketin son konumunu güncelle
        if newX >= 7 && newX <= 357 && newY >= 160 && newY <= 510 {
            UIView.animate(withDuration: 0.5, animations: {
                knight.frame.origin = CGPoint(x: newX, y: newY)
            })
            updateChessPieceCoordinates(knight, newX: newX, newY: newY)
            
            if pieceSoundStatus == "On" {
                moveSoundPlayer?.play()
            }
            
            moveCounter += 1
            self.changeTurn()
            
            if let targetIndex = chessPieces.firstIndex(where: { $0.x == newX && $0.y == newY && $0.imageView != knight }) {
                        capturedPiece = chessPieces[targetIndex]
                    }

                    let moveRecord = MoveRecord(movedPiece: chessPieces[index],
                                                capturedPiece: capturedPiece,
                                                fromPosition: originalPosition,
                                                toPosition: CGPoint(x: newX, y: newY))
                    moveHistory.append(moveRecord)
            
        }
        
        else {
            presentOutOfBoardAlert()
        }
    }

    
    
    
    // BLACK KNIGHT MOVING FUNCTION
    
    func moveBlackKnight(_ knight: UIImageView, direction: Substring) {
        guard let index = chessPieces.firstIndex(where: { $0.imageView == knight }) else {
            return
        }
        
        let originalPosition = CGPoint(x: chessPieces[index].x, y: chessPieces[index].y)
            var capturedPiece: ChessPiece?


        var newX = chessPieces[index].x
        var newY = chessPieces[index].y
        let stepSize = CGFloat(50)

        if turnIndicatorView.backgroundColor == UIColor.black {
            
            switch direction {
            case "fr":
                newX += stepSize
                newY += 2 * stepSize  // Yön değişikliği burada
            case "fl":
                newX -= stepSize
                newY += 2 * stepSize  // Yön değişikliği burada
            case "rf":
                newX += 2 * stepSize
                newY += stepSize  // Yön değişikliği burada
            case "lf":
                newX -= 2 * stepSize
                newY += stepSize  // Yön değişikliği burada
            case "br":
                newX += stepSize
                newY -= 2 * stepSize  // Yön değişikliği burada
            case "bl":
                newX -= stepSize
                newY -= 2 * stepSize  // Yön değişikliği burada
            case "rb":
                newX += 2 * stepSize
                newY -= stepSize  // Yön değişikliği burada
            case "lb":
                newX -= 2 * stepSize
                newY -= stepSize  // Yön değişikliği burada
            default:
                presentInvalidDirectionAlert()
                return
            }
            
            // Yol boyunca başka bir taş var mı kontrol et
            if let targetIndex = chessPieces.firstIndex(where: { $0.x == newX && $0.y == newY }) {
                if isOppositeColor(chessPieces[index], chessPieces[targetIndex]) {
                    // Rakip taş yenilir ve yeni pozisyona taşınır
                    capturePiece(chessPieces[targetIndex].imageView)
                    chessPieces.remove(at: targetIndex)
                } else {
                    presentMoveBlockedAlert()
                    return
                }
            }
        }
        else {
            presentWrongTurnAlert()
            return
        }

        // Hareketin son konumunu güncelle
        if newX >= 7 && newX <= 357 && newY >= 160 && newY <= 510 {
            UIView.animate(withDuration: 0.5, animations: {
                knight.frame.origin = CGPoint(x: newX, y: newY)
            })
            updateChessPieceCoordinates(knight, newX: newX, newY: newY)
            
            if pieceSoundStatus == "On" {
                moveSoundPlayer?.play()
            }
            
            moveCounter += 1
            self.changeTurn()
            
            if let targetIndex = chessPieces.firstIndex(where: { $0.x == newX && $0.y == newY && $0.imageView != knight }) {
                        capturedPiece = chessPieces[targetIndex]
                    }

                    let moveRecord = MoveRecord(movedPiece: chessPieces[index],
                                                capturedPiece: capturedPiece,
                                                fromPosition: originalPosition,
                                                toPosition: CGPoint(x: newX, y: newY))
                    moveHistory.append(moveRecord)
            
        }
        
        else {
            presentOutOfBoardAlert()
        }
    }

    
    
    
    
    
    // WHITE BISHOP MOVING FUNCTION
    
    func moveWhiteBishop(_ bishop: UIImageView, direction: Substring, steps: Int) {
        guard ["fr", "fl", "br", "bl"].contains(direction) else {
            presentInvalidDirectionAlert()
            return
        }

        guard let index = chessPieces.firstIndex(where: { $0.imageView == bishop }) else {
            return
        }
        
        let originalPosition = CGPoint(x: chessPieces[index].x, y: chessPieces[index].y)
            var capturedPiece: ChessPiece?

        var newX = chessPieces[index].x
        var newY = chessPieces[index].y
        let stepSize = CGFloat(50)
        
        if turnIndicatorView.backgroundColor == UIColor.systemBrown {
            
            for step in 1...steps {
                let checkingX = direction.contains("l") ? newX - CGFloat(step) * stepSize :
                direction.contains("r") ? newX + CGFloat(step) * stepSize : newX
                let checkingY = direction.contains("f") ? newY - CGFloat(step) * stepSize :
                direction.contains("b") ? newY + CGFloat(step) * stepSize : newY
                
                if let targetIndex = chessPieces.firstIndex(where: { $0.x == checkingX && $0.y == checkingY }) {
                    if isOppositeColor(chessPieces[index], chessPieces[targetIndex]) {
                        // Rakip taş yenilir ve yeni pozisyona taşınır
                        capturePiece(chessPieces[targetIndex].imageView)
                        chessPieces.remove(at: targetIndex)
                        newX = checkingX
                        newY = checkingY
                        break
                    } else {
                        presentMoveBlockedAlert()
                        return
                    }
                } else if step == steps {
                    newX = checkingX
                    newY = checkingY
                }
            }
        }
        else {
            presentWrongTurnAlert()
            return
        }

        // Hareketin son konumunu güncelle
        if newX >= 7 && newX <= 357 && newY >= 160 && newY <= 510 {
            UIView.animate(withDuration: 0.5, animations: {
                bishop.frame.origin = CGPoint(x: newX, y: newY)
            })
            updateChessPieceCoordinates(bishop, newX: newX, newY: newY)
            
            if pieceSoundStatus == "On" {
                moveSoundPlayer?.play()
            }
            
            moveCounter += 1
            self.changeTurn()
            
            if let targetIndex = chessPieces.firstIndex(where: { $0.x == newX && $0.y == newY && $0.imageView != bishop }) {
                        capturedPiece = chessPieces[targetIndex]
                    }

                    let moveRecord = MoveRecord(movedPiece: chessPieces[index],
                                                capturedPiece: capturedPiece,
                                                fromPosition: originalPosition,
                                                toPosition: CGPoint(x: newX, y: newY))
                    moveHistory.append(moveRecord)
            
        }
        else {
            presentOutOfBoardAlert()
        }
    }

    
    
    
    
    // BLACK BISHOP MOVING FUNCTION
    
    func moveBlackBishop(_ bishop: UIImageView, direction: Substring, steps: Int) {
        guard ["fr", "fl", "br", "bl"].contains(direction) else {
            presentInvalidDirectionAlert()
            return
        }

        guard let index = chessPieces.firstIndex(where: { $0.imageView == bishop }) else {
            return
        }
        
        let originalPosition = CGPoint(x: chessPieces[index].x, y: chessPieces[index].y)
            var capturedPiece: ChessPiece?

        var newX = chessPieces[index].x
        var newY = chessPieces[index].y
        let stepSize = CGFloat(50)

        if turnIndicatorView.backgroundColor == UIColor.black {
            
            for step in 1...steps {
                let checkingX = direction.contains("l") ? newX - CGFloat(step) * stepSize :
                direction.contains("r") ? newX + CGFloat(step) * stepSize : newX
                let checkingY = direction.contains("f") ? newY + CGFloat(step) * stepSize :  // Yön değişikliği burada
                direction.contains("b") ? newY - CGFloat(step) * stepSize : newY  // Yön değişikliği burada
                
                if let targetIndex = chessPieces.firstIndex(where: { $0.x == checkingX && $0.y == checkingY }) {
                    if isOppositeColor(chessPieces[index], chessPieces[targetIndex]) {
                        // Rakip taş yenilir ve yeni pozisyona taşınır
                        capturePiece(chessPieces[targetIndex].imageView)
                        chessPieces.remove(at: targetIndex)
                        newX = checkingX
                        newY = checkingY
                        break
                    } else {
                        presentMoveBlockedAlert()
                        return
                    }
                } else if step == steps {
                    newX = checkingX
                    newY = checkingY
                }
            }
        }
        else {
            presentWrongTurnAlert()
            return
        }

        // Hareketin son konumunu güncelle
        if newX >= 7 && newX <= 357 && newY >= 160 && newY <= 510 {
            UIView.animate(withDuration: 0.5, animations: {
                bishop.frame.origin = CGPoint(x: newX, y: newY)
            })
            updateChessPieceCoordinates(bishop, newX: newX, newY: newY)
            
            if pieceSoundStatus == "On" {
                moveSoundPlayer?.play()
            }
            
            moveCounter += 1
            self.changeTurn()
            
            if let targetIndex = chessPieces.firstIndex(where: { $0.x == newX && $0.y == newY && $0.imageView != bishop }) {
                        capturedPiece = chessPieces[targetIndex]
                    }

                    let moveRecord = MoveRecord(movedPiece: chessPieces[index],
                                                capturedPiece: capturedPiece,
                                                fromPosition: originalPosition,
                                                toPosition: CGPoint(x: newX, y: newY))
                    moveHistory.append(moveRecord)
            
        }
        
        else {
            presentOutOfBoardAlert()
        }
    }

    
    
    
    
    
    
    // WHITE QUEEN MOVING FUNCTION
   
    func moveWhiteQueen(_ queen: UIImageView, direction: Substring, steps: Int) {
        guard ["f", "b", "l", "r", "fr", "fl", "br", "bl"].contains(direction) else {
            presentInvalidDirectionAlert()
            return
        }

        guard let index = chessPieces.firstIndex(where: { $0.imageView == queen }) else {
            return
        }
        
        let originalPosition = CGPoint(x: chessPieces[index].x, y: chessPieces[index].y)
            var capturedPiece: ChessPiece?


        var newX = chessPieces[index].x
        var newY = chessPieces[index].y
        let stepSize = CGFloat(50)

        if turnIndicatorView.backgroundColor == UIColor.systemBrown {
            
            for step in 1...steps {
                let checkingX = (direction.contains("l") ? newX - CGFloat(step) * stepSize :
                                    direction.contains("r") ? newX + CGFloat(step) * stepSize : newX)
                let checkingY = (direction.contains("f") ? newY - CGFloat(step) * stepSize :
                                    direction.contains("b") ? newY + CGFloat(step) * stepSize : newY)
                
                if let targetIndex = chessPieces.firstIndex(where: { $0.x == checkingX && $0.y == checkingY }) {
                    if isOppositeColor(chessPieces[index], chessPieces[targetIndex]) {
                        // Rakip taş yenilir ve yeni pozisyona taşınır
                        capturePiece(chessPieces[targetIndex].imageView)
                        chessPieces.remove(at: targetIndex)
                        newX = checkingX
                        newY = checkingY
                        break
                    } else {
                        presentMoveBlockedAlert()
                        return
                    }
                } else if step == steps {
                    newX = checkingX
                    newY = checkingY
                }
            }
        }
        else {
            presentWrongTurnAlert()
            return
        }

        // Hareketin son konumunu güncelle
        if newX >= 7 && newX <= 357 && newY >= 160 && newY <= 510 {
            UIView.animate(withDuration: 0.5, animations: {
                queen.frame.origin = CGPoint(x: newX, y: newY)
            })
            updateChessPieceCoordinates(queen, newX: newX, newY: newY)
            
            if pieceSoundStatus == "On" {
                moveSoundPlayer?.play()
            }
            
            moveCounter += 1
            self.changeTurn()
            
            if let targetIndex = chessPieces.firstIndex(where: { $0.x == newX && $0.y == newY && $0.imageView != queen }) {
                        capturedPiece = chessPieces[targetIndex]
                    }

                    let moveRecord = MoveRecord(movedPiece: chessPieces[index],
                                                capturedPiece: capturedPiece,
                                                fromPosition: originalPosition,
                                                toPosition: CGPoint(x: newX, y: newY))
                    moveHistory.append(moveRecord)
            
        }
        
        else {
            presentOutOfBoardAlert()
        }
    }


    
    
    
    
    // BLACK QUEEN MOVING FUNCTION
    
    func moveBlackQueen(_ queen: UIImageView, direction: Substring, steps: Int) {
        guard ["f", "b", "l", "r", "fr", "fl", "br", "bl"].contains(direction) else {
            presentInvalidDirectionAlert()
            return
        }

        guard let index = chessPieces.firstIndex(where: { $0.imageView == queen }) else {
            return
        }
        
        let originalPosition = CGPoint(x: chessPieces[index].x, y: chessPieces[index].y)
            var capturedPiece: ChessPiece?

        var newX = chessPieces[index].x
        var newY = chessPieces[index].y
        let stepSize = CGFloat(50)

        if turnIndicatorView.backgroundColor == UIColor.black {
            
            for step in 1...steps {
                let checkingX = (direction.contains("l") ? newX - CGFloat(step) * stepSize :
                                    direction.contains("r") ? newX + CGFloat(step) * stepSize : newX)
                let checkingY = (direction.contains("f") ? newY + CGFloat(step) * stepSize :  // Yön değişikliği burada
                                 direction.contains("b") ? newY - CGFloat(step) * stepSize : newY)  // Yön değişikliği burada
                
                if let targetIndex = chessPieces.firstIndex(where: { $0.x == checkingX && $0.y == checkingY }) {
                    if isOppositeColor(chessPieces[index], chessPieces[targetIndex]) {
                        // Rakip taş yenilir ve yeni pozisyona taşınır
                        capturePiece(chessPieces[targetIndex].imageView)
                        chessPieces.remove(at: targetIndex)
                        newX = checkingX
                        newY = checkingY
                        break
                    } else {
                        presentMoveBlockedAlert()
                        return
                    }
                } else if step == steps {
                    newX = checkingX
                    newY = checkingY
                }
            }
        }
        else {
            presentWrongTurnAlert()
            return
        }

        // Hareketin son konumunu güncelle
        if newX >= 7 && newX <= 357 && newY >= 160 && newY <= 510 {
            UIView.animate(withDuration: 0.5, animations: {
                queen.frame.origin = CGPoint(x: newX, y: newY)
            })
            updateChessPieceCoordinates(queen, newX: newX, newY: newY)
            
            if pieceSoundStatus == "On" {
                moveSoundPlayer?.play()
            }
            
            moveCounter += 1
            self.changeTurn()
            
            if let targetIndex = chessPieces.firstIndex(where: { $0.x == newX && $0.y == newY && $0.imageView != queen }) {
                        capturedPiece = chessPieces[targetIndex]
                    }

                    let moveRecord = MoveRecord(movedPiece: chessPieces[index],
                                                capturedPiece: capturedPiece,
                                                fromPosition: originalPosition,
                                                toPosition: CGPoint(x: newX, y: newY))
                    moveHistory.append(moveRecord)
            
            
        }
        
        else {
            presentOutOfBoardAlert()
        }
    }

    
    
    
    
    
    
    

    
    // PROMOTED WHITE QUEEN MOVING FUNCTION
    
    func movePromotedWhiteQueen(_ queen: UIImageView, direction: Substring, steps: Int) {
        guard ["f", "b", "l", "r", "fr", "fl", "br", "bl"].contains(direction) else {
            presentInvalidDirectionAlert()
            return
        }

        guard let index = chessPieces.firstIndex(where: { $0.imageView == queen }) else {
            print("Promoted queen not found in chess pieces.")
            return
        }
        
        print("Moving promoted queen: \(chessPieces[index].name)")

        let originalPosition = CGPoint(x: chessPieces[index].x, y: chessPieces[index].y)
            var capturedPiece: ChessPiece?
        
        var newX = chessPieces[index].x
        var newY = chessPieces[index].y
        let stepSize = CGFloat(50)
        
        if turnIndicatorView.backgroundColor == UIColor.systemBrown {
            
            for step in 1...steps {
                let checkingX = (direction.contains("l") ? newX - CGFloat(step) * stepSize :
                                    direction.contains("r") ? newX + CGFloat(step) * stepSize : newX)
                let checkingY = (direction.contains("f") ? newY - CGFloat(step) * stepSize :
                                    direction.contains("b") ? newY + CGFloat(step) * stepSize : newY)
                
                // Taş yeme kontrolü
                if let targetIndex = chessPieces.firstIndex(where: { $0.x == checkingX && $0.y == checkingY }) {
                    if isOppositeColor(chessPieces[index], chessPieces[targetIndex]) {
                        // Rakip taş yenilir ve yeni pozisyona taşınır
                        capturePiece(chessPieces[targetIndex].imageView)
                        chessPieces.remove(at: targetIndex)
                        newX = checkingX
                        newY = checkingY
                        break
                    } else {
                        // Kendi taşı varsa hareketi engelle
                        presentMoveBlockedAlert()
                        return
                    }
                } else if step == steps {
                    newX = checkingX
                    newY = checkingY
                }
            }
        }
        else {
            presentWrongTurnAlert()
            return
        }

        
        if newX >= 7 && newX <= 357 && newY >= 160 && newY <= 510 {
                UIView.animate(withDuration: 0.5, animations: {
                    queen.frame.origin = CGPoint(x: newX, y: newY)
                })
                updateChessPieceCoordinates(queen, newX: newX, newY: newY)
            
            if pieceSoundStatus == "On" {
                moveSoundPlayer?.play()
            }
            
            moveCounter += 1
            self.changeTurn()
            
            if let targetIndex = chessPieces.firstIndex(where: { $0.x == newX && $0.y == newY && $0.imageView != queen }) {
                        capturedPiece = chessPieces[targetIndex]
                    }

                    let moveRecord = MoveRecord(movedPiece: chessPieces[index],
                                                capturedPiece: capturedPiece,
                                                fromPosition: originalPosition,
                                                toPosition: CGPoint(x: newX, y: newY))
                    moveHistory.append(moveRecord)
            
                print("Promoted Queen moved: \(queen.tag)")
            } 
            else {
                presentOutOfBoardAlert()
            }
    }

    
    
    
    
    // PROMOTED BLACK QUEEN MOVING FUNCTION
    
    func movePromotedBlackQueen(_ queen: UIImageView, direction: Substring, steps: Int) {
        guard ["f", "b", "l", "r", "fr", "fl", "br", "bl"].contains(direction) else {
            presentInvalidDirectionAlert()
            return
        }

        guard let index = chessPieces.firstIndex(where: { $0.imageView == queen }) else {
            print("Promoted black queen not found in chess pieces.")
            return
        }
        
        print("Moving promoted black queen: \(chessPieces[index].name)")

        let originalPosition = CGPoint(x: chessPieces[index].x, y: chessPieces[index].y)
            var capturedPiece: ChessPiece?

        
        var newX = chessPieces[index].x
        var newY = chessPieces[index].y
        let stepSize = CGFloat(50)
        
        if turnIndicatorView.backgroundColor == UIColor.black {
            
            for step in 1...steps {
                let checkingX = (direction.contains("l") ? newX - CGFloat(step) * stepSize :
                                    direction.contains("r") ? newX + CGFloat(step) * stepSize : newX)
                let checkingY = (direction.contains("f") ? newY + CGFloat(step) * stepSize : // Yön değişikliği burada
                                 direction.contains("b") ? newY - CGFloat(step) * stepSize : newY) // Yön değişikliği burada
                
                if let targetIndex = chessPieces.firstIndex(where: { $0.x == checkingX && $0.y == checkingY }) {
                    if isOppositeColor(chessPieces[index], chessPieces[targetIndex]) {
                        capturePiece(chessPieces[targetIndex].imageView)
                        chessPieces.remove(at: targetIndex)
                        newX = checkingX
                        newY = checkingY
                        break
                    } else {
                        presentMoveBlockedAlert()
                        return
                    }
                } else if step == steps {
                    newX = checkingX
                    newY = checkingY
                }
            }
        }
        else {
            presentWrongTurnAlert()
            return
        }
        

        if newX >= 7 && newX <= 357 && newY >= 160 && newY <= 510 {
            UIView.animate(withDuration: 0.5, animations: {
                queen.frame.origin = CGPoint(x: newX, y: newY)
            })
            updateChessPieceCoordinates(queen, newX: newX, newY: newY)
            
            if pieceSoundStatus == "On" {
                moveSoundPlayer?.play()
            }
            
            moveCounter += 1
            self.changeTurn()
            
            if let targetIndex = chessPieces.firstIndex(where: { $0.x == newX && $0.y == newY && $0.imageView != queen }) {
                        capturedPiece = chessPieces[targetIndex]
                    }

                    let moveRecord = MoveRecord(movedPiece: chessPieces[index],
                                                capturedPiece: capturedPiece,
                                                fromPosition: originalPosition,
                                                toPosition: CGPoint(x: newX, y: newY))
                    moveHistory.append(moveRecord)
            
            print("Promoted Black Queen moved: \(queen.tag)")
        } 
        else {
            presentOutOfBoardAlert()
        }
    }

    
    
    
    
    
    
    // WHITE KING MOVING FUNCTION
    
    func moveWhiteKing(_ king: UIImageView, direction: Substring) {
        guard ["f", "b", "l", "r", "fr", "fl", "br", "bl"].contains(direction) else {
            presentInvalidDirectionAlert()
            return
        }

        guard let index = chessPieces.firstIndex(where: { $0.imageView == king }) else {
            return
        }

        let originalPosition = CGPoint(x: chessPieces[index].x, y: chessPieces[index].y)
            var capturedPiece: ChessPiece?
        
        let stepSize = CGFloat(50)
        var potentialNewX = chessPieces[index].x
        var potentialNewY = chessPieces[index].y

        if turnIndicatorView.backgroundColor == UIColor.systemBrown {
            
            if direction.contains("f") { potentialNewY -= stepSize }
            if direction.contains("b") { potentialNewY += stepSize }
            if direction.contains("l") { potentialNewX -= stepSize }
            if direction.contains("r") { potentialNewX += stepSize }
            
            
            if let targetIndex = chessPieces.firstIndex(where: { $0.x == potentialNewX && $0.y == potentialNewY }) {
                if isOppositeColor(chessPieces[index], chessPieces[targetIndex]) {
                    // Rakip taş yenilir ve yeni pozisyona taşınır
                    capturePiece(chessPieces[targetIndex].imageView)
                    chessPieces.remove(at: targetIndex)
                }
                else {
                    presentMoveBlockedAlert()
                    return
                }
            }
        }
        else {
            presentWrongTurnAlert()
            return
        }
        

        if potentialNewX >= 7 && potentialNewX <= 357 && potentialNewY >= 160 && potentialNewY <= 510 {
            UIView.animate(withDuration: 0.5, animations: {
                king.frame.origin = CGPoint(x: potentialNewX, y: potentialNewY)
            })
            updateChessPieceCoordinates(king, newX: potentialNewX, newY: potentialNewY)
            
            if pieceSoundStatus == "On" {
                moveSoundPlayer?.play()
            }
            
            moveCounter += 1
            self.changeTurn()
            
            if let targetIndex = chessPieces.firstIndex(where: { $0.x == potentialNewX && $0.y == potentialNewY && $0.imageView != king }) {
                       capturedPiece = chessPieces[targetIndex]
                   }

                   let moveRecord = MoveRecord(movedPiece: chessPieces[index],
                                               capturedPiece: capturedPiece,
                                               fromPosition: originalPosition,
                                               toPosition: CGPoint(x: potentialNewX, y: potentialNewY))
                   moveHistory.append(moveRecord)
            
        }
        
        else {
            presentOutOfBoardAlert()
        }
    }
        
    
    
    
    
    // BLACK KING MOVING FUNCTION
    
    func moveBlackKing(_ king: UIImageView, direction: Substring) {
        guard ["f", "b", "l", "r", "fr", "fl", "br", "bl"].contains(direction) else {
            presentInvalidDirectionAlert()
            return
        }
        
        guard let index = chessPieces.firstIndex(where: { $0.imageView == king }) else {
            return
        }
        
        let originalPosition = CGPoint(x: chessPieces[index].x, y: chessPieces[index].y)
            var capturedPiece: ChessPiece?
        
        let stepSize = CGFloat(50)
        var potentialNewX = chessPieces[index].x
        var potentialNewY = chessPieces[index].y
        
  
        if turnIndicatorView.backgroundColor == UIColor.black {
            
            if direction.contains("f") { potentialNewY += stepSize }
            if direction.contains("b") { potentialNewY -= stepSize }
            if direction.contains("l") { potentialNewX -= stepSize }
            if direction.contains("r") { potentialNewX += stepSize }
            
            if let targetIndex = chessPieces.firstIndex(where: { $0.x == potentialNewX && $0.y == potentialNewY }) {
                if isOppositeColor(chessPieces[index], chessPieces[targetIndex]) {
                    // Rakip taş yenilir ve yeni pozisyona taşınır
                    capturePiece(chessPieces[targetIndex].imageView)
                    chessPieces.remove(at: targetIndex)
                } else {
                    presentMoveBlockedAlert()
                    return
                }
            }
         }
    
            else {
                presentWrongTurnAlert()
                return
                 }

        
        
        
        if potentialNewX >= 7 && potentialNewX <= 357 && potentialNewY >= 160 && potentialNewY <= 510 {
            UIView.animate(withDuration: 0.5, animations: {
                king.frame.origin = CGPoint(x: potentialNewX, y: potentialNewY)
            })
            updateChessPieceCoordinates(king, newX: potentialNewX, newY: potentialNewY)
            
            if pieceSoundStatus == "On" {
                moveSoundPlayer?.play()
            }
            
            moveCounter += 1
            self.changeTurn()
            
            if let targetIndex = chessPieces.firstIndex(where: { $0.x == potentialNewX && $0.y == potentialNewY && $0.imageView != king }) {
                       capturedPiece = chessPieces[targetIndex]
                   }

                   let moveRecord = MoveRecord(movedPiece: chessPieces[index],
                                               capturedPiece: capturedPiece,
                                               fromPosition: originalPosition,
                                               toPosition: CGPoint(x: potentialNewX, y: potentialNewY))
                   moveHistory.append(moveRecord)
            
        }
        
        else {
            presentOutOfBoardAlert()
            
        }
        
    }
       
    
    
    
    
    
    
    
    
    
    func evaluateBoard(chessPieces: [ChessPiece]) -> Int {
        var score = 0
        for piece in chessPieces {
            switch piece.name {
            case let name where name.contains("Pawn"):
                score += name.contains("white") ? 10 : -10
            case let name where name.contains("Knight"):
                score += name.contains("white") ? 30 : -30
            case let name where name.contains("Bishop"):
                score += name.contains("white") ? 30 : -30
            case let name where name.contains("Rook"):
                score += name.contains("white") ? 50 : -50
            case let name where name.contains("Queen"):
                score += name.contains("white") ? 90 : -90
            case let name where name.contains("King"):
                // Şah için daha sofistike bir puanlama yapılabilir.
                score += name.contains("white") ? 900 : -900
            default:
                break
            }
        }
        return score
    }

    
    
    
    func isOppositeColorOnSquare(piece: ChessPiece, x: CGFloat, y: CGFloat, chessPieces: [ChessPiece]) -> Bool {
        if let otherPiece = chessPieces.first(where: { $0.x == x && $0.y == y }) {
            return isOppositeColor(piece, otherPiece)
        }
        return false
    }
    
    
    
    func getAllPossibleMoves(chessPieces: [ChessPiece], isWhite: Bool) -> [Move] {
        var allMoves: [Move] = []

        for piece in chessPieces where piece.name.contains(isWhite ? "white" : "black") {
            let possibleMoves = getPossibleMovesForPiece(piece: piece, chessPieces: chessPieces)
            allMoves.append(contentsOf: possibleMoves.map { Move(piece: piece, to: $0) })
        }
        
        return allMoves
    }
    
    
    
    func getPossibleMovesForPiece(piece: ChessPiece, chessPieces: [ChessPiece]) -> [(x: CGFloat, y: CGFloat)] {
        switch piece.name {
        case let name where name.contains("Pawn"):
            return getPossibleMovesForPawn(piece: piece, chessPieces: chessPieces)
        case let name where name.contains("Knight"):
            return getPossibleMovesForKnight(piece: piece, chessPieces: chessPieces)
        case let name where name.contains("Bishop"):
            return getPossibleMovesForBishop(piece: piece, chessPieces: chessPieces)
        case let name where name.contains("Rook"):
            return getPossibleMovesForRook(piece: piece, chessPieces: chessPieces)
        case let name where name.contains("Queen"):
            return getPossibleMovesForQueen(piece: piece, chessPieces: chessPieces)
        case let name where name.contains("King"):
            return getPossibleMovesForKing(piece: piece, chessPieces: chessPieces)
        default:
            return []
        }
    }

    
    
    
    
    
    func getPossibleMovesForPawn(piece: ChessPiece, chessPieces: [ChessPiece]) -> [(x: CGFloat, y: CGFloat)] {
        var possibleMoves: [(x: CGFloat, y: CGFloat)] = []
        let x = piece.x
        let y = piece.y
        let stepSize: CGFloat = 50

        let isBlack = piece.name.contains("black")
        let moveForward = isBlack ? stepSize : -stepSize  // Siyahlar için aşağı, beyazlar için yukarı
        let startRow = isBlack ? 210 : 460  // Siyah ve beyaz piyonlar için başlangıç satırları

        // İleri hareket
        if isSquareEmpty(atX: x, atY: y + moveForward) && isWithinBounds(x: x, y: y + moveForward) {
            possibleMoves.append((x, y + moveForward))

            // İki adım ileri hareket (sadece başlangıç pozisyonunda)
            if Int(y) == startRow && isSquareEmpty(atX: x, atY: y + 2 * moveForward) {
                possibleMoves.append((x, y + 2 * moveForward))
            }
        }

        // Çapraz hareketler (rakip taş almak)
        let diagonalMoves = [(-stepSize, moveForward), (stepSize, moveForward)]
        for move in diagonalMoves {
            let diagonalX = x + move.0
            let diagonalY = y + move.1
            if isWithinBounds(x: diagonalX, y: diagonalY) && isOppositeColorOnSquare(piece: piece, x: diagonalX, y: diagonalY, chessPieces: chessPieces) {
                possibleMoves.append((diagonalX, diagonalY))
            }
        }

        return possibleMoves
    }




    
    
    
    func getPossibleMovesForKnight(piece: ChessPiece, chessPieces: [ChessPiece]) -> [(x: CGFloat, y: CGFloat)] {
        var possibleMoves: [(x: CGFloat, y: CGFloat)] = []
        let x = piece.x
        let y = piece.y

        let moves = [(-50, -100), (50, -100), (-50, 100), (50, 100), (-100, -50), (100, -50), (-100, 50), (100, 50)]

        for move in moves {
            let newX = x + CGFloat(move.0)
            let newY = y + CGFloat(move.1)
            if isWithinBounds(x: newX, y: newY) && (isSquareEmpty(atX: newX, atY: newY) || isOppositeColorOnSquare(piece: piece, x: newX, y: newY, chessPieces: chessPieces)) {
                possibleMoves.append((newX, newY))
            }
        }

        return possibleMoves
    }


    
    
    
    
    func getPossibleMovesForBishop(piece: ChessPiece, chessPieces: [ChessPiece]) -> [(x: CGFloat, y: CGFloat)] {
        var possibleMoves: [(x: CGFloat, y: CGFloat)] = []
        let x = piece.x
        let y = piece.y

        let directions = [(1, 1), (1, -1), (-1, -1), (-1, 1)]
        for direction in directions {
            for step in 1...7 {
                let newX = x + CGFloat(step * 50 * direction.0)
                let newY = y + CGFloat(step * 50 * direction.1)

                if isWithinBounds(x: newX, y: newY) {
                    if isSquareEmpty(atX: newX, atY: newY) {
                        possibleMoves.append((newX, newY))
                    } else if isOppositeColorOnSquare(piece: piece, x: newX, y: newY, chessPieces: chessPieces) {
                        possibleMoves.append((newX, newY))
                        break
                    } else {
                        break
                    }
                }
            }
        }

        return possibleMoves
    }



    
    func getPossibleMovesForRook(piece: ChessPiece, chessPieces: [ChessPiece]) -> [(x: CGFloat, y: CGFloat)] {
        var possibleMoves: [(x: CGFloat, y: CGFloat)] = []
        let x = piece.x
        let y = piece.y
        let directions = [(0, 1), (1, 0), (0, -1), (-1, 0)]  // yukarı, sağa, aşağı ve sola hareketleri

        for direction in directions {
            for step in 1...7 {
                let newX = x + CGFloat(step * 50 * direction.0)
                let newY = y + CGFloat(step * 50 * direction.1)

                if isWithinBounds(x: newX, y: newY) {
                    if isSquareEmpty(atX: newX, atY: newY) {
                        possibleMoves.append((newX, newY))
                    } else if isOppositeColorOnSquare(piece: piece, x: newX, y: newY, chessPieces: chessPieces) {
                        possibleMoves.append((newX, newY))
                        break
                    } else {
                        break
                    }
                }
            }
        }
        return possibleMoves
    }

    
    
    
    
    func getPossibleMovesForQueen(piece: ChessPiece, chessPieces: [ChessPiece]) -> [(x: CGFloat, y: CGFloat)] {
        // Vezirin hareketleri kale ve filin birleşimidir.
        let rookMoves = getPossibleMovesForRook(piece: piece, chessPieces: chessPieces)
        let bishopMoves = getPossibleMovesForBishop(piece: piece, chessPieces: chessPieces)
        return rookMoves + bishopMoves  // Kale ve fil hareketlerini birleştir
    }

    
    
    
    
    func getPossibleMovesForKing(piece: ChessPiece, chessPieces: [ChessPiece]) -> [(x: CGFloat, y: CGFloat)] {
        var possibleMoves: [(x: CGFloat, y: CGFloat)] = []
        let x = piece.x
        let y = piece.y
        let directions = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)]  // Çevresindeki 8 kare

        for direction in directions {
            let newX = x + CGFloat(50 * direction.0)
            let newY = y + CGFloat(50 * direction.1)
            if isWithinBounds(x: newX, y: newY) {
                if isSquareEmpty(atX: newX, atY: newY) || isOppositeColorOnSquare(piece: piece, x: newX, y: newY, chessPieces: chessPieces) {
                    possibleMoves.append((newX, newY))
                }
            }
        }
        return possibleMoves
    }

    
    
    
    
    
    func simulateMove(board: [ChessPiece], move: Move) -> [ChessPiece] {
        var newBoard = board
        // Hamlenin eski konumunu bul ve taşı kaldır
        if let index = newBoard.firstIndex(where: { $0 == move.piece }) {
            newBoard[index].x = move.to.x
            newBoard[index].y = move.to.y
            // Eğer varsa rakip taşı kaldır
            if let capturedIndex = newBoard.firstIndex(where: { $0.x == move.to.x && $0.y == move.to.y && $0 != move.piece }) {
                newBoard.remove(at: capturedIndex)
            }
        }
        return newBoard
    }

    
    
    
    func isGameOver(chessPieces: [ChessPiece], isWhite: Bool) -> Bool {
        // Beyaz veya siyah şah için mat durumunu kontrol et
        if let king = chessPieces.first(where: { $0.name.contains(isWhite ? "whiteKing" : "blackKing") }) {
            return isCheckmate(kingPiece: king)
        }
        return false
    }

    
    
    
    
    func minimaxWithAlphaBeta(board: [ChessPiece], depth: Int, alpha: Int, beta: Int, isMaximizingPlayer: Bool, isWhite: Bool) -> (score: Int, move: Move?) {
        var alpha = alpha
        var beta = beta

        if depth == 0 || isGameOver(chessPieces: board, isWhite: !isMaximizingPlayer) {
            return (evaluateBoard(chessPieces: board), nil)
        }

        var bestMove: Move?

        if isMaximizingPlayer {
            var maxEval = Int.min
            let possibleMoves = getAllPossibleMoves(chessPieces: board, isWhite: !isMaximizingPlayer)
            for move in possibleMoves {
                let newBoard = simulateMove(board: board, move: move)
                let (eval, _) = minimaxWithAlphaBeta(board: newBoard, depth: depth - 1, alpha: alpha, beta: beta, isMaximizingPlayer: false, isWhite: isWhite)
                if eval > maxEval {
                    maxEval = eval
                    bestMove = move
                }
                alpha = max(alpha, eval)
                if beta <= alpha {
                    break
                }
            }
            return (maxEval, bestMove)
        } else {
            var minEval = Int.max
            let possibleMoves = getAllPossibleMoves(chessPieces: board, isWhite: !isMaximizingPlayer)
            for move in possibleMoves {
                let newBoard = simulateMove(board: board, move: move)
                let (eval, _) = minimaxWithAlphaBeta(board: newBoard, depth: depth - 1, alpha: alpha, beta: beta, isMaximizingPlayer: true, isWhite: isWhite)
                if eval < minEval {
                    minEval = eval
                    bestMove = move
                }
                beta = min(beta, eval)
                if beta <= alpha {
                    break
                }
            }
            return (minEval, bestMove)
        }
    }

    
    
    
    func iterativeDeepeningMinimax(board: [ChessPiece], maxDepth: Int, isWhite: Bool, timeLimit: TimeInterval) -> (score: Int, bestMove: Move?) {
        var bestMove: Move? = nil
        var bestScore = isWhite ? Int.min : Int.max

        let startTime = Date()  // Algoritmanın başlangıç zamanını kaydet

        for depth in 1...maxDepth {
            let currentTime = Date()
            let elapsedTime = currentTime.timeIntervalSince(startTime)

            if elapsedTime >= timeLimit {
                break  // Zaman sınırına ulaşıldıysa döngüyü kır
            }

            let (score, move) = minimaxWithAlphaBeta(board: board, depth: depth, alpha: Int.min, beta: Int.max, isMaximizingPlayer: !isWhite, isWhite: isWhite)

            if isWhite && score > bestScore {
                bestScore = score
                bestMove = move
            } else if !isWhite && score < bestScore {
                bestScore = score
                bestMove = move
            }
        }

        return (bestScore, bestMove)
    }
    
    
    
    
    
    
    
    
    func performAIMove(move: Move) {
        guard let pieceIndex = chessPieces.firstIndex(where: { $0 == move.piece }) else {
            print("Hamle yapacak taş bulunamadı.")
            return
        }
        let piece = chessPieces[pieceIndex]
        let targetPosition = move.to

        // Hedef pozisyona göre direction ve steps hesapla
        let deltaX = targetPosition.x - piece.x
        let deltaY = targetPosition.y - piece.y
        let stepsX = abs(deltaX / 50)
        let stepsY = abs(deltaY / 50)
        let steps = max(stepsX, stepsY)  // En büyük adım sayısı

        var direction: String = ""
        if deltaY > 0 { direction += "f" }  // forward
        if deltaY < 0 { direction += "b" }  // backward
        if deltaX > 0 { direction += "r" }  // right
        if deltaX < 0 { direction += "l" }  // left

        // Taşın türüne göre uygun hareket fonksiyonunu çağır
        if piece.name.contains("Pawn") {
            moveBlackPawn(piece.imageView, direction: Substring(direction), steps: Int(steps))
        } else if piece.name.contains("Rook") {
            moveBlackRook(piece.imageView, direction: Substring(direction), steps: Int(steps))
        } else if piece.name.contains("Knight") {
            // Atlar için özel hesaplama gerekebilir çünkü L şeklinde hareket ederler
            moveBlackKnight(piece.imageView, direction: Substring(direction))
        } else if piece.name.contains("Bishop") {
            moveBlackBishop(piece.imageView, direction: Substring(direction), steps: Int(steps))
        } else if piece.name.contains("Queen") {
            moveBlackQueen(piece.imageView, direction: Substring(direction), steps: Int(steps))
        } else if piece.name.contains("King") {
            // Kral genellikle bir adım atar, ancak rok durumu için kontrol ekleyebilirsiniz
            moveBlackKing(piece.imageView, direction: Substring(direction))
        }
        // Diğer taş türleri için benzer bloklar eklenecek
    }

    
    
    
    
    
    func applyAIMove() {
        // Yapay zekanın en iyi hamlesini hesapla
        let (score, bestMove) = iterativeDeepeningMinimax(board: chessPieces, maxDepth: 2, isWhite: false, timeLimit: 10.0)
        
        // En iyi hamleyi uygula
        if let move = bestMove {
            performAIMove(move: move)
        } else {
            print("Yapay zeka için geçerli bir hamle bulunamadı.")
        }
    }

    
    
    
    func checkAndApplyAIMove() {
        // Sıranın siyah taşlarda (AI) olduğunu ve rakibin AI olduğunu kontrol et
        if turnIndicatorView.backgroundColor == UIColor.black && opponentType == "AI" {
            applyAIMove()
        }
    }

    
  
    
    
    
}
    
    
    
    
    
    
    
    
