/*
    Cattac's lobby view controller
*/

import UIKit

class LobbyViewController: UIViewController {
    let ref = Firebase(url: "https://torrid-inferno-1934.firebaseio.com/")
    let levelGenerator = LevelGenerator.sharedInstance
    
    // TODO check if the player who is joining the game has already joined,
    // if not he can join as multiplayer players from the same game and
    // screw the game up, hypothetically speaking shouldn't happen at the moment
    // but we can keep that in view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let lobbiesRef = self.ref.childByAppendingPath("lobbies")
        
        var lobbyId = 0
        var didJoinLobby = false

        let thisLobbyRef = lobbiesRef.childByAppendingPath("lobby" + String(lobbyId))
        
        thisLobbyRef.observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            
            let hasGameStarted = snapshot.value["hasGameStarted"] as? Int
            let lastActiveTime = snapshot.value["lastActive"] as? String
            let player1 = snapshot.value["player1"] as? String
            let player2 = snapshot.value["player2"] as? String
            let player3 = snapshot.value["player3"] as? String
            let player4 = snapshot.value["player4"] as? String
            
            var numberOfPlayers = 0
            
            let players = [player1!, player2!, player3!, player4!]
            
            for player in players {
                if !player.isEmpty {
                    numberOfPlayers++
                }
            }
            
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
            let lastActiveDateFormat = dateFormatter.dateFromString(lastActiveTime!)
            let now = NSDate()
            let nowDateFormat = dateFormatter.stringFromDate(now)
            
            let calendar = NSCalendar.currentCalendar()
            let comps = NSDateComponents()
            comps.minute = 1
            
            let oneMinuteFromLastActive = calendar.dateByAddingComponents(comps, toDate: lastActiveDateFormat!, options: NSCalendarOptions.allZeros)
            
            if didJoinLobby == true {
                // do not want to do anything anymore
            } else if hasGameStarted == 1 || self.isAfter(oneMinuteFromLastActive!, dateTwo: now) {
                // join in as the first player and empty all the players and set hasGameStarted == 0
                
                let newPlayer1 = self.ref.authData.uid
                let newPlayer2 = ""
                let newPlayer3 = ""
                let newPlayer4 = ""
                
                let toWriteTo1 = thisLobbyRef.childByAppendingPath("player1")
                let toWriteTo2 = thisLobbyRef.childByAppendingPath("player2")
                let toWriteTo3 = thisLobbyRef.childByAppendingPath("player3")
                let toWriteTo4 = thisLobbyRef.childByAppendingPath("player4")
                
                toWriteTo1.setValue(newPlayer1)
                toWriteTo2.setValue(newPlayer2)
                toWriteTo3.setValue(newPlayer3)
                toWriteTo4.setValue(newPlayer4)
                
                let setGameNotStartedRef = thisLobbyRef.childByAppendingPath("hasGameStarted")
                setGameNotStartedRef.setValue(0)
                
                didJoinLobby = true
                
                let setGameNewLastActive = thisLobbyRef.childByAppendingPath("lastActive")
                setGameNewLastActive.setValue(nowDateFormat)
                
                self.waitForGameStart()
            } else if hasGameStarted == 0 {
                // join in as the next player
                
                let playerToJoin = self.ref.authData.uid
                
                switch numberOfPlayers {
                case 3:
                    let toWriteTo = thisLobbyRef.childByAppendingPath("player4")
                    toWriteTo.setValue(playerToJoin)
                    
                    let setGameStartedRef = thisLobbyRef.childByAppendingPath("hasGameStarted")
                    setGameStartedRef.setValue(1)
                    
                    let setGameNewLastActive = thisLobbyRef.childByAppendingPath("lastActive")
                    setGameNewLastActive.setValue(nowDateFormat)
                    
                    didJoinLobby = true
                    
                    self.initiateGameStart()
                case 2:
                    let toWriteTo = thisLobbyRef.childByAppendingPath("player3")
                    toWriteTo.setValue(playerToJoin)
                    
                    let setGameNewLastActive = thisLobbyRef.childByAppendingPath("lastActive")
                    setGameNewLastActive.setValue(nowDateFormat)
                    
                    didJoinLobby = true
                    
                    self.waitForGameStart()
                case 1:
                    let toWriteTo = thisLobbyRef.childByAppendingPath("player2")
                    toWriteTo.setValue(playerToJoin)
                    
                    let setGameNewLastActive = thisLobbyRef.childByAppendingPath("lastActive")
                    setGameNewLastActive.setValue(nowDateFormat)
                    
                    didJoinLobby = true
                    
                    self.waitForGameStart()
                default:
                    println("HOLY MOLLY, LESS EPIC LOBBY ERROR")
                }
            } else {
                // should never get here but if it does we'll know now that there's
                // a very epic error going on
                println("HOLY MOLLY, EPIC LOBBY ERROR")
            }
        })
        
        if didJoinLobby == false {
            self.performSegueWithIdentifier("backFromLobbySegue", sender: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "gameStartSegue" {
            if let destinationVC = segue.destinationViewController as? GameViewController{
                destinationVC.level = levelGenerator.generateBasic()
                
                let gameRef = ref
                    .childByAppendingPath("games")
                    .childByAppendingPath("game0")
                
                let gameToWrite = [
                    "generatedGame": levelGenerator.toDictionaryForFirebase()
                ]
                
                gameRef.updateChildValues(gameToWrite)
            }
        }
    }
    
    func initiateGameStart() {
        self.performSegueWithIdentifier("gameStartSegue", sender: nil)
    }
    
    func waitForGameStart() {
        let gameToReceiveRef = ref.childByAppendingPath("games")
            .childByAppendingPath("game0")
            .childByAppendingPath("generatedGame")
        
        // for now let's assume we only have 1 game ongoing at any one point, alpha
        // testing code :)
        
        gameToReceiveRef.observeEventType(.ChildChanged, withBlock: {
            snapshot in
            
            println("I feel that the game started but is currently unable to do anything")
            
            // the game is stored in snapshot.value
            
            // receive it and segue to the game while passing the object to the game view controller
        })
    }
    
    func isAfter(dateOne: NSDate, dateTwo: NSDate) -> Bool {
        return dateOne.compare(dateTwo) == NSComparisonResult.OrderedAscending
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}