//
//  Concentration.swift
//  Concentration
//
//  Created by Jegan Karunakaran on 12/24/20.
//  Copyright © 2020 Jegan Karunakaran. All rights reserved.
//

import Foundation

class Concentration
{
    var cards =  [Card]()
    /*
     * This variable is used as both boolean to check
     */
    var indexOfOneCardFaceUp: Int?
    
    func chooseCard(at index: Int) {
        if !cards[index].isMatched {
            if let matchIndex = indexOfOneCardFaceUp, matchIndex != index {
                //check if cards match
                if cards[matchIndex].identifier == cards[index].identifier {
                    cards[matchIndex].isMatched = true
                    cards[index].isMatched = true
                }
                cards[index].isFaceUp = true
                indexOfOneCardFaceUp = nil
            } else{
                //either no cards ot two cards face up
                for flipDownIndex in cards.indices {
                    cards[flipDownIndex].isFaceUp = false
                }
                cards[index].isFaceUp = true
                indexOfOneCardFaceUp = index
            }
        }
    }
    
    init(numberOfPairsOfCards: Int){
        
        for _ in 0..<numberOfPairsOfCards{
            let card = Card()
            //let card = Card(identifier: identifier)
            //let matchingCard = card
            //cards.append(card)
            //cards.append(card)
            cards += [card,card]
        }
        // TODO: Shuffle the cards
        
        
    }
}

