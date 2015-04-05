
import SpriteKit

class LandMineDoodad: Doodad {
    
    override init() {
        super.init()
        setSprite(SKLabelNode(text: "M"))
    }
    
    override func effect(cat: Cat) {
        cat.inflict(Constants.Doodad.landMineDamage)
        setRemoved()
    }
    
    override func isVisible() -> Bool {
        return false
    }
}