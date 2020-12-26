//
//  ViewController.swift
//  Concentration
//
//  Created by Jegan Karunakaran on 12/23/20.
//  Copyright © 2020 Jegan Karunakaran. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var flipCountLabel: UILabel!
    @IBOutlet var cardButtons: [UIButton]!
    
    /*
     * lazy do not have didSet
     * Cannot use instance member 'cardButtons' within property initializer; property initializers run before 'self' is available
     */
    lazy var game = Concentration(numberOfPairsOfCards: (cardButtons.count + 1) / 2)
    var flipCount = 0 {
        didSet {
            
            flipCountLabel.text = "Flips: \(flipCount)"
        }
    }


    @IBAction func touchCard(_ sender: UIButton) {
        flipCount += 1
        if let cardNumber = cardButtons.index(of: sender){
            game.chooseCard(at: cardNumber)
            updateViewFromModel()
        } else {
            print("card not found")
        }
    }
    
    func updateViewFromModel(){
        for index in cardButtons.indices{
            let button = cardButtons[index]
            let card = game.cards[index]
            if card.isFaceUp{
                button.setTitle(emoji(for: card), for: UIControl.State.normal)
                button.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            } else {
                button.setTitle("", for: UIControl.State.normal)
                button.backgroundColor = card.isMatched ? #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 0) : #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
            }
        }
    }
    
    var emojiChoices = ["👻","🎃","🍭","👺","☃️","😈","🦇","😱","🙀"]
    
    var emoji =  [Int: String]()
    
    func emoji(for card: Card) -> String {
//        if emoji[card.identifier] != nil{
//            return emoji[card.identifier]
//        } else {
//            return "?"
//        }
        if emoji[card.identifier] == nil, emojiChoices.count > 0 {
            let randomIndex = Int (arc4random_uniform(UInt32(emojiChoices.count)))
            emoji[card.identifier] = emojiChoices.remove(at: randomIndex)
                
        }
        return emoji[card.identifier] ?? "?"
    }

}

