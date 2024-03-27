//
//  GameResult+CoreDataProperties.swift
//  ChessGame
//
//  Created by Erdem on 28.12.2023.
//
//

import Foundation
import CoreData


extension GameResult {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GameResult> {
        return NSFetchRequest<GameResult>(entityName: "GameResult")
    }

    @NSManaged public var finalBlackPlayerName: String?
    @NSManaged public var finalBlacksCapturedValue: Int16
    @NSManaged public var finalCapturedBlackPieces: Int16
    @NSManaged public var finalCapturedWhitePieces: Int16
    @NSManaged public var finalGameDuration: Int16
    @NSManaged public var finalMoveCount: Int16
    @NSManaged public var finalOpponentType: String?
    @NSManaged public var finalWhitePlayerName: String?
    @NSManaged public var finalWhitesCapturedValue: Int16
    @NSManaged public var winner: String?

}

extension GameResult : Identifiable {

}
