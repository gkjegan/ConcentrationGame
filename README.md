# ConcentrationGame
First iOS game from standford CS193p. This game is to understand the MVC design behind the iOS app development using UIKit

## The MVC architecture 

mvc.png

1. Model and View never talk to each other
2. Controller talks to the model freely, while the model can communicate to the controller only using notification and Key Value Observing (more details later). View can sometime listen to controller notification but never to the model notification.
3. Controller talks to the view using outlet (IBOutlet or Interface Builder Outlet) to talk freely, while the view can talk to controller in blind and structured ways
    - View can use interface builder target action to connect the view component to specific methods in the controller. The view sends the action when things happen in the UI (such as clicked)
    - In complex cases such as view needs to synchronize with the controller withView (such as scroll view), the controller sets itself as the view's delegate (using should, will, did variables). The delegate is set via a protocol. (more details later)
    - As view cannot own the data, view uses another protocol type delegate called data source to connect to the controller(suing data-at, count variables)
4. Overall, the purpose of a controller is to interpret or format model information for the view.


## The Controller
Let's take a look at the controller for the concentration game. 

### Controller-View Interaction
#### IBOutlet (The green arrow):
IBOutlets (Interface Builder Outlet) will connect the UI element with the variable defined in the controller. The communication is from controller to view.

##### FlipCount UILabel
@IBOutlet weak var flipCountLabel: UILabel!

The variable flipCountLabel connects the UILabel element that displays the number of flips. The UI label element is linked to this variable.  The controller tracks the flip count using a variable called flipCount. When user clicks the card, the function touchCard is called(details on this interaction below) and the variable flipCount is incremented to 1

var flipCount = 0 {
        didSet {
            flipCountLabel.text = "Flips: \(flipCount)"
        }  

Property Observer "didset" will detect the changes in this variable and update the label in the UI.

###### CardButtons UIButton
 @IBOutlet var cardButtons: [UIButton]!

The variable cardButtons is an array of UI buttons (the cards to flip). Every UI button added is linked to this variable. The controller can then use array's functions such as count, index  or indices to get an index for all the buttons. 

#### IBAction (The yellow arrow):
IBAction (Interface Builder Action) will connect the UI element to a function in the controller. The communication is from view to the controller. 
    @IBAction func touchCard(_ sender: UIButton) {
        flipCount += 1
        if let cardNumber = cardButtons.index(of: sender){
            game.chooseCard(at: cardNumber)
            updateViewFromModel()
        } else {
            print("card not found")
        }
    }

In this case, when the user clicks the button, touchCard action is called with the UI button as the input parameter. As mentioned before, the flip count is incremented to 1. Get the index of the card clicked using the index method of the array by passing the sender (the clicked button element). All the logic on what happens when the card is clicked should be on the model. Controller calls "game" the model and its function "chooseCard" by passing the selected card index. The interaction between controller and the model is explained below. Finally the controller calls the "updateViewFromModel" function to update the view.

    func updateViewFromModel(){
        for index in cardButtons.indices{
            let button = cardButtons[index]
            let card = game.cards[index]
            if card.isFaceUp{
                button.setTitle(emoji(for: card), for: UIControl.State.normal)
                button.backgroundColor =  colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            } else {
                button.setTitle("", for: UIControl.State.normal)
                button.backgroundColor = card.isMatched ?  colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 0) :  colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
            }
        }
    }

For each index in the cardButtons array, the button variable represents the "view" UI element. The card variable is from the "model" where the model returns the card state based on game logic. Then if the card returned from the model is face up, set the view  button background to white and the title to emoji. Otherwise, set the view button background to orange and the title is cleared. The variation is, if the card property isMatched is true, the background is cleared.


Emojis for Cards:
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

Emoji variable is a dictionary where the key is the card index and the value is the emoji string. The emoji function will return the emoji for the card index and if not available add a random emoji from emojiChoices array. 

### Controller-Model Interaction

"Concentration" is the model that the controller interacts with. The communication is from controller to model (Green arrow)]

   lazy var game = Concentration(numberOfPairsOfCards: (cardButtons.count + 1) / 2)

#### Model Init
Controller initializes the concentration model with a variable name called "game" by passing the half the number of UI buttons available. Communication is from controller to model.

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

The init method of the concentration model takes a number of pairs of cards (number of buttons / 2) and creates a card and a matching card. 

#### "What is a Card"?
A Card model is of type "struct" with following properties and functions
struct Card
{
    var isFaceUp = false
    var isMatched = false
    var identifier: Int
    
    static var identifierFactory = 0
    
    static func getUniqueIdentifier() -> Int {
        identifierFactory += 1
        return identifierFactory
    }
    
    init(){
        self.identifier = Card.getUniqueIdentifier()
    }
    
    //    init(identifier :Int){
    //        self.identifier = identifier
    //    }
    
}

The Card model has 3 properties: isFaceUp, isMatched, and identifier, 1 static function to create identifier and initialize the identifier during the init.

#### Back to Concentration model
The init method of concentration calls Card's init method that returns the Card 'struct' with an identifier. Adds the same card twice into the cards array. (as the card is a struct, it copies using value (not by reference). So two copies of card with the same identifier are added to the array called cards.

End of init in the concentration model the cards array will have cards equals to the total number of button with two cards having same identifier

([Concentration.Card]) $R2 = 16 values {
  [0] = (isFaceUp = false, isMatched = false, identifier = 1)
  [1] = (isFaceUp = false, isMatched = false, identifier = 1)
  [2] = (isFaceUp = false, isMatched = false, identifier = 2)
  [3] = (isFaceUp = false, isMatched = false, identifier = 2)
  [4] = (isFaceUp = false, isMatched = false, identifier = 3)
  [5] = (isFaceUp = false, isMatched = false, identifier = 3)
  [6] = (isFaceUp = false, isMatched = false, identifier = 4)
  [7] = (isFaceUp = false, isMatched = false, identifier = 4)
  [8] = (isFaceUp = false, isMatched = false, identifier = 5)
  [9] = (isFaceUp = false, isMatched = false, identifier = 5)
  [10] = (isFaceUp = false, isMatched = false, identifier = 6)
  [11] = (isFaceUp = false, isMatched = false, identifier = 6)
  [12] = (isFaceUp = false, isMatched = false, identifier = 7)
  [13] = (isFaceUp = false, isMatched = false, identifier = 7)
  [14] = (isFaceUp = false, isMatched = false, identifier = 8)
  [15] = (isFaceUp = false, isMatched = false, identifier = 8)


#### ChooseCard Action
ChooseCard is the action called from the controller's touchCard function when the user clicks on the UI button. Once again the communication is from the controller to the model. 

   var indexOfOneCardFaceUp: Int?
    
##### Best use of Optional Variable
It starts with an important variable called indexOfOneCardFaceUp. This variable is of type "optional" with values of Int. This variable will be "nil" if no cards face up or more than one card face up and the index of the card if one card faces up. Used as both as a boolean type to check if this is nil or not and Integer type if not nil, so we can use the index.

##### Game Logic
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

This is the method that handles the logic of the game. 

When the user clicks the card and the card is the matched card, do nothing. (this can be improved by making the card disappear. But in this version of the game, the card disappears only at the next click.) The entire game logic is if the cards are not matching. These are the logic for the first three clicks. (and it repeats for further clicks)
First Click: All cards are faced down (start of the game). User clicks the first card.
Second Click: One card is already faced up and the user clicks the second card (User clicks the second card). 
Third Click: If matches, we do nothing. When the user clicks the third, the matched cards disappear.  
Third Click: If no matches, when user clicks the third one, all cards fold down

## Reference

https://www.youtube.com/playlist?list=PLPA-ayBrweUzGFmkT_W65z64MoGnKRZMq


