/*
    Cattac's game scene
*/

import SpriteKit

class GameScene: SKScene, GameStateListener, ActionListener {
    
    let gameEngine: GameEngine!
    private let level: GameLevel!
    
    private let sceneUtils: SceneUtils!
    
    private let gameLayer = SKNode()
    private let tilesLayer = SKNode()
    private let entityLayer = SKNode()
    
    private let buttonLayer = SKNode()
    
    private var puiButton: SKActionButtonNode!
    private var fartButton: SKActionButtonNode!
    private var poopButton: SKActionButtonNode!
    
    private var previewNode: SKSpriteNode!
    private var previewDirectionNodes: SKNode!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(size: CGSize) {
        assertionFailure("Should not call this init, init with basic level please!")
    }
    
    init(_ size: CGSize, _ level: GameLevel, _ currentPlayerNumber: Int) {
        super.init(size: size)
        
        self.level = level
        gameEngine = GameEngine(grid: level.grid, playerNumber: currentPlayerNumber)
        gameEngine.gameStateListener = self
        gameEngine.actionListener = self

        sceneUtils = SceneUtils(windowWidth: size.width,
            numRows: level.numRows, numColumns: level.numColumns)
        
        // Sets the anchorpoint for the scene to be the center of the screen
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.addChild(gameLayer)
        
        // position of the general grid layer
        let layerPosition = sceneUtils.getLayerPosition()

        // adds tilesLayer to the grid layer
        tilesLayer.position = layerPosition
        gameLayer.addChild(tilesLayer)
        
        // adds entityLayer to the grid layer
        entityLayer.position = layerPosition
        gameLayer.addChild(entityLayer)
        
        buttonLayer.position = CGPoint(x: -220, y: layerPosition.y - 90)
        gameLayer.addChild(buttonLayer)
        
        puiButton = SKActionButtonNode(
            defaultButtonImage: "PuiButton.png",
            activeButtonImage: "PuiButtonPressed.png",
            buttonAction: { self.gameEngine.trigger("puiButtonPressed") })
        puiButton.position = CGPoint(x: 0, y: 0)
        buttonLayer.addChild(puiButton)
        
        fartButton = SKActionButtonNode(
            defaultButtonImage: "FartButton.png",
            activeButtonImage: "FartButtonPressed.png",
            buttonAction: { self.gameEngine.trigger("fartButtonPressed") })
        fartButton.position = CGPoint(x: 220, y: 0)
        buttonLayer.addChild(fartButton)
        
        poopButton = SKActionButtonNode(
            defaultButtonImage: "PoopButton.png",
            activeButtonImage: "PoopButtonPressed.png",
            buttonAction: { self.gameEngine.trigger("poopButtonPressed") })
        poopButton.position = CGPoint(x: 440, y: 0)
        buttonLayer.addChild(poopButton)
        
        addTiles()
        addPlayers()
        
        switch currentPlayerNumber {
        case 1:
            previewNode = SKSpriteNode(imageNamed: "Nala.png")
        case 2:
            previewNode = SKSpriteNode(imageNamed: "Grumpy.png")
        case 3:
            previewNode = SKSpriteNode(imageNamed: "Nyan.png")
        case 4:
            previewNode = SKSpriteNode(imageNamed: "Pusheen.png")
        default:
            break
        }
        
        previewNode.size = sceneUtils.tileSize
        previewNode.alpha = 0.5
        entityLayer.addChild(previewNode)
        previewNode.hidden = true
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(gameLayer)
            
            if let node = sceneUtils.nodeForLocation(location,
                grid: level.grid) {
                    registerPlayerMovement(node)
            }
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(gameLayer)

            if let node = sceneUtils.nodeForLocation(location,
                grid: level.grid) {
                    registerPlayerMovement(node)
            }
        }
    }

    private func registerPlayerMovement(node: TileNode) {
        if gameEngine.state == GameState.PlayerAction {
            if gameEngine.reachableNodes[Node(node).hashValue] != nil {
                gameEngine.setCurrentPlayerMoveToPosition(node)
                previewNode.position = sceneUtils.pointFor(node.position)
                previewNode.hidden = false
            }
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        gameEngine.gameLoop()
    }
    
    private func addTiles() {
        for row in 0..<level.numRows {
            for column in 0..<level.numColumns {
                if let tileNode = level.nodeAt(row, column) {
                    drawTile(tileNode)
                }
            }
        }
    }
    
    private func addPlayers() {
        for player in gameEngine.gameManager.players.values {
            let spriteNode = gameEngine.gameManager[positionOf: player]!.sprite
            let playerNode = player.getSprite() as SKSpriteNode
            playerNode.size = spriteNode.size
            playerNode.position = spriteNode.position
            entityLayer.addChild(playerNode)
        }
    }

    private func drawTile(tileNode: TileNode) {
        let spriteNode = tileNode.sprite
        spriteNode.size = sceneUtils.tileSize
        spriteNode.position = sceneUtils.pointFor(tileNode.position)
        tilesLayer.addChild(spriteNode)
        
        if let doodad = tileNode.doodad {
            self.drawTileEntity(spriteNode, doodad)
        }
    }
    
    private func drawTileEntity(spriteNode: SKSpriteNode, _ tileEntity: TileEntity) {
        let entityNode = tileEntity.getSprite()
        if entityNode is SKSpriteNode {
            (entityNode as SKSpriteNode).size = spriteNode.size
        }
        if !tileEntity.isVisible() {
            entityNode.alpha = 0.5
        }
        entityNode.position = spriteNode.position
        entityLayer.addChild(entityNode)
    }
    
    private func movePlayers() {
        for player in gameEngine.gameManager.players.values {
            let path = gameEngine.executePlayerMove(player)
            var pathSequence: [SKAction] = []
            
            for node in path {
                let action = SKAction.moveTo(node.sprite.position, duration: 0.25)
                pathSequence.append(action)
            }
            
            if pathSequence.count > 0 {
                player.getSprite().runAction(SKAction.sequence(pathSequence))
            }
        }
    }
    
    private func animatePuiAction(action: PuiAction) {
        let startNode = gameEngine.gameManager[moveToPositionOf: gameEngine.currentPlayer]!
        let path = gameEngine.pathOfPui(startNode, direction: action.direction)
        var pathSequence: [SKAction] = []
        
        for node in path {
            let action = SKAction.moveTo(node.sprite.position, duration: 0.15)
            pathSequence.append(action)
        }
        
        let pui = SKSpriteNode(imageNamed: "Pui.png")
        pui.size = sceneUtils.tileSize
        pui.position = startNode.sprite.position
        pui.zRotation = SceneUtils.zRotation(action.direction)
        
        entityLayer.addChild(pui)
        pui.runAction(
            SKAction.sequence(pathSequence),
            completion: {
                pui.removeFromParent()
            }
        )
    }
    
    private func performActions() {
        for player in gameEngine.gameManager.players.values {
            if let action = gameEngine.executePlayerAction(player) {
                println(action)
                switch action.actionType {
                case .Pui:
                    animatePuiAction(action as PuiAction)
                case .Fart:
                    break
                case .Poop:
                    break
                }
            }
        }
    }
    
    func onStateUpdate(state: GameState) {
        // we should restrict next-state calls in game engine
        switch state {
        case .Precalculation:
            break
        case .PlayerAction:
            deleteRemovedDoodads()
            highlightReachableNodes()
            break
        case .ServerUpdate:
            clearDirectionArrows()
            removeHighlights()
            break
        case .StartMovesExecution:
            previewNode.hidden = true
        case .MovesExecution:
            movePlayers()
        case .StartActionsExecution:
            performActions()
        case .ActionsExecution:
            break
        case .PostExecution:
            break
        }
    }
    
    func onActionUpdate(action: Action?) {
        clearDirectionArrows()
        if let action = action {
            switch action.actionType {
            case .Pui:
                drawDirectionArrows(action as PuiAction)
            case .Fart:
                break
            case .Poop:
                break
            }
        }
    }
    
    private func drawDirectionArrows(action: PuiAction) {
        var directionSprite = SKDirectionButtonNode(
            defaultButtonImage: "Direction.png",
            activeButtonImage: "DirectionSelected.png",
            size: CGSize(width: 50, height: 50),
            centerSize: puiButton.calculateAccumulatedFrame().size,
            hoverAction: {(direction) -> Void in
                self.gameEngine.gameManager[actionOf: self.gameEngine.currentPlayer]!.direction = direction
            },
            availableDirection: action.availableDirections,
            selected: action.direction
        )
        
        puiButton.addChild(directionSprite)
        previewDirectionNodes = directionSprite
    }
    
    private func clearDirectionArrows() {
        if previewDirectionNodes != nil {
            previewDirectionNodes.removeFromParent()
        }
    }
    
    private func highlightReachableNodes() {
        for node in gameEngine.reachableNodes.values {
            node.highlight()
        }
    }
    
    private func removeHighlights() {
        for node in gameEngine.reachableNodes.values {
            node.unhighlight()
        }
    }
    
    private func deleteRemovedDoodads() {
        let removedSprites = gameEngine.gameManager.doodadsToRemove.values.map {
            (doodad) -> SKNode in
            return doodad.getSprite()
        }
        entityLayer.removeChildrenInArray([SKNode](removedSprites))
        gameEngine.gameManager.doodadsToRemove = [:]
    }
}
