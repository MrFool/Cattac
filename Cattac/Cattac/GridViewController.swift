import Foundation
import UIKit

let gridCellIdentifier = "gridCellIdentifier"
let tileEntityTag = 20

class GridViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // Current selected palette action
    private var currentAction: String?

    private let rows = Constants.Level.basicRows
    private let columns = Constants.Level.basicColumns
    private var sceneUtils: SceneUtils!
    var wallLocations: [NSIndexPath:UICollectionViewCell] = [:]
    var grid: Grid!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set size of grid area to the size of the container view
        let gridViewWidth = self.view.frame.width
        let gridViewHeight = self.view.frame.height

        sceneUtils = SceneUtils(windowWidth: gridViewWidth, numRows: rows,
            numColumns: columns)
        grid = Grid(rows: rows, columns: columns)
        for row in 0..<rows {
            for column in 0..<columns {
                let tileNode = TileNode(row: row, column: column)
                grid[row, column] = tileNode
            }
        }

        // Defines the layout for the UICollectionView
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = sceneUtils.tileSize
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0

        let frame = CGRectMake(0, 0, gridViewWidth, gridViewHeight)

        // Initialise the UICollectionView
        let collectionView: UICollectionView = UICollectionView(frame: frame,
            collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerClass(UICollectionViewCell.self,
            forCellWithReuseIdentifier: gridCellIdentifier)
        collectionView.backgroundColor = UIColor.clearColor()

        // Register gestures
        let panGesture = UIPanGestureRecognizer(target: self,
            action: "panGestureHandler:")
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        collectionView.addGestureRecognizer(panGesture)

        let longPressGesture = UILongPressGestureRecognizer(target: self,
            action: "longPressGestureHandler:")
        longPressGesture.minimumPressDuration = 0.5
        collectionView.addGestureRecognizer(longPressGesture)

        self.view = collectionView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated0.
    }

    func numberOfSectionsInCollectionView(
        collectionView: UICollectionView) -> Int {
            return Constants.Level.basicRows
    }

    func collectionView(collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
            return Constants.Level.basicColumns
    }

    func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(
                gridCellIdentifier, forIndexPath: indexPath)
                as UICollectionViewCell

            let tileImage = UIImage(named: "Grass.png")!
            let tile = UIImageView(image: tileImage)
            let tileSize = sceneUtils.tileSize
            tile.frame = CGRectMake(0, 0, tileSize.width, tileSize.height)
            cell.addSubview(tile)
            return cell
    }

    // Used to register single tap on grid
    func collectionView(collectionView: UICollectionView,
        didSelectItemAtIndexPath indexPath: NSIndexPath) {
            let cell = collectionView.cellForItemAtIndexPath(indexPath)
            tileAction(cell!, toggle: true, indexPath: indexPath)
    }

    func setCurrentAction(action: String) {
        self.currentAction = action
        println("\(action) button selected")
    }

    func longPressGestureHandler(sender: UILongPressGestureRecognizer) {
        let collectionView = self.view as UICollectionView
        let point: CGPoint = sender.locationInView(self.view)
        if let indexPath = collectionView.indexPathForItemAtPoint(point) {
            let cell = collectionView.cellForItemAtIndexPath(indexPath)
            removeTileEntity(cell!, indexPath: indexPath)
        }
    }

    func panGestureHandler(sender: UIPanGestureRecognizer) {
        let collectionView = self.view as UICollectionView
        let point: CGPoint = sender.locationInView(collectionView)
        if let indexPath = collectionView.indexPathForItemAtPoint(point) {
            let cell = collectionView.cellForItemAtIndexPath(indexPath)
            tileAction(cell!, toggle: false, indexPath: indexPath)
        }
    }

    private func tileAction(cell: UICollectionViewCell, toggle: Bool,
        indexPath: NSIndexPath) {
            if let actionTitle = currentAction {
                if actionTitle == "Eraser" {
                    removeTileEntity(cell, indexPath: indexPath)
                } else {
                    changeTileEntity(cell, toggle: toggle, indexPath: indexPath)
                }
            }
    }

    private func addTileEntity(cell: UICollectionViewCell, entity: String,
        indexPath: NSIndexPath) {
            let entityImage = UIImage(named: Constants.Entities.getImage(entity)!)
            let entityImageView = UIImageView(image: entityImage)
            entityImageView.frame = CGRectMake(0, 0,
                cell.frame.width, cell.frame.height)
            entityImageView.tag = tileEntityTag
            cell.addSubview(entityImageView)

            let tileNode = grid[indexPath.section, indexPath.row]!
            let entityObject = Constants.Entities.getObject(entity)
            if entityObject is Doodad {
                tileNode.doodad = (entityObject as Doodad)
            } else if entityObject is Item {
                tileNode.item = (entityObject as Item)
            }

            if entity == Constants.Entities.Title.wall {
                wallLocations[indexPath] = cell
            }
    }

    private func removeTileEntity(cell: UICollectionViewCell,
        indexPath: NSIndexPath) {
            cell.viewWithTag(tileEntityTag)?.removeFromSuperview()

            let tileNode = grid[indexPath.section, indexPath.row]!
            tileNode.doodad = nil
            tileNode.item = nil

            wallLocations.removeValueForKey(indexPath)
    }

    private func changeTileEntity(cell: UICollectionViewCell, toggle: Bool,
        indexPath: NSIndexPath) {
            if cell.viewWithTag(tileEntityTag) == nil {
                addTileEntity(cell, entity: currentAction!, indexPath: indexPath)
            } else if toggle {
//                removeTileEntity(cell, indexPath: indexPath)
//                addTileEntity(cell, color: nextColor!, indexPath: indexPath)
            }
    }
}