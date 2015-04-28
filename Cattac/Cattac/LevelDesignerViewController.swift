import UIKit

class LevelDesignerViewController: UIViewController {

    private var gridViewController: GridViewController!
    private var currentPaletteButton: UIButton!
    private let selection = UIImageView(image: UIImage(named: "ButtonSelect.png"))

    override func viewDidLoad() {
        super.viewDidLoad()

        gridViewController.wormholeBlueButton =
            self.view.viewWithTag(4) as UIButton
        gridViewController.wormholeOrangeButton =
            self.view.viewWithTag(5) as UIButton

        let fortressButton: UIButton = self.view.viewWithTag(1) as UIButton
        setPaletteButton(fortressButton)

        self.view.addSubview(selection)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "designGameStartSegue" {
            if let destinationVC = segue.destinationViewController
                as? GameViewController {
                    let level = BasicLevel()
                    level.grid = gridViewController.grid
                    level.grid.constructGraph()

                    for gridIndex in gridViewController.wallLocations.keys {
                        let tileNodeToRemove = level.grid[gridIndex]!
                        level.grid.removeNodeFromGraph(tileNodeToRemove)
                    }

                    let wormholes = gridViewController.wormholeLocations.keys.array

                    if wormholes.count == 2 {
                        let firstWormholeTileNode = level.grid[wormholes[0]]!
                        let secondWormholeTileNode = level.grid[wormholes[1]]!
                        let firstWormhole = firstWormholeTileNode.doodad
                            as WormholeDoodad
                        let secondWormhole = secondWormholeTileNode.doodad
                            as WormholeDoodad

                        firstWormhole.setDestination(secondWormholeTileNode)
                        secondWormhole.setDestination(firstWormholeTileNode)

                        firstWormhole.setColor(0)
                        secondWormhole.setColor(1)
                    } else if wormholes.count == 1 {
                        let wormholeTileNode = level.grid[wormholes[0]]!

                        wormholeTileNode.doodad = nil
                    }

                    destinationVC.level = level
            }
        } else if segue.identifier == "gridContainer" {
            self.gridViewController = segue.destinationViewController
                as GridViewController
        }
    }

    @IBAction func playPressed(sender: UIButton) {
        self.performSegueWithIdentifier("designGameStartSegue", sender: self)
    }

    @IBAction func savePressed(sender: UIButton) {
        // TODO: Deal with saving
        println("save")
    }

    @IBAction func loadPressed(sender: UIButton) {
        // TODO: Deal with loading
        println("load")
    }

    @IBAction func controlPressed(sender: UIButton) {
        setPaletteButton(sender)
    }

    private func setPaletteButton(button: UIButton) {
        gridViewController.setCurrentAction(button.currentTitle!)

        currentPaletteButton?.alpha = 0.5
        currentPaletteButton = button
        currentPaletteButton?.alpha = 1

        selection.frame = CGRectMake(
            button.frame.minX - 10,
            button.frame.minY - 10,
            button.frame.width + 20,
            button.frame.height + 20
        )
    }
}
