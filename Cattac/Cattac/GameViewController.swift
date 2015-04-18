/*
    Cattac's game controller, the actual game view
*/

import UIKit
import SpriteKit

extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController {
    @IBOutlet weak var timerLabel: UILabel!
    
    var scene: GameScene!
    var level: GameLevel!
    var playerNumber: Int = 1
    let levelGenerator = LevelGenerator.sharedInstance
    var multiplayer: Bool = false
    private var isPlayerTurn: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure the view.
        let skView = self.view as SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        scene = GameScene(size: skView.bounds.size, level: level,
            currentPlayerNumber: playerNumber, multiplayer: multiplayer)
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFill
        
        /* Start timer */
        NSTimer.scheduledTimerWithTimeInterval(
            1,
            target: self,
            selector: Selector("updateTime"),
            userInfo: nil,
            repeats: true
        )
        
        timerLabel.text = "10"
        
        skView.presentScene(scene)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        let skView = self.view as SKView
        if let scene = skView.scene {
            (skView.scene as GameScene).gameEngine.end()
            skView.presentScene(nil)
        }
        
        // Release all game engine's listeners first
        scene.gameEngine.releaseAllListeners()
        
        // TODO: confirm whether to exit game
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func updateTime() {
        var currentTime = timerLabel.text!.toInt()
        
        if currentTime == 0 {
            if isPlayerTurn {
                scene.gameEngine.triggerPlayerActionEnded()
                isPlayerTurn = false
            } else if scene.gameEngine.state == .PlayerAction {
                timerLabel.text = "10"
                isPlayerTurn = true
            }
        } else {
            timerLabel.text = String(currentTime! - 1)
        }
    }
}
