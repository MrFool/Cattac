/*
    The Cat object
*/

import Foundation
import SpriteKit

protocol HpListener {
    func onHpUpdate(hp: Int)
}

class Cat: TileEntity {
    private let _spriteImage: String
    private let _sprite: SKSpriteNode
    private let _previewSprite: SKSpriteNode
    private let baseDefence: Int
    private let baseMoveRange: Int
    private let baseFartRange: Int
    private var basePuiDmg: Int
    private var baseFartDmg: Int
    private var basePoopDmg: Int
    
    var name: String!
    var hp: Int

    var hpListener: HpListener?
    
    var defenceMods = [AttrModification]()
    var dmgMods = [AttrModification]()
    var moveRangeMods = [AttrModification]()
    var fartRangeMods = [AttrModification]()
    
    /// Cat's defence attribute with modifications
    var defence: Int {
        return applyAttrMods(baseDefence, mods: defenceMods)
    }
    
    /// Cat's movement range attribute with modifications
    var moveRange: Int {
        return applyAttrMods(baseMoveRange, mods: moveRangeMods)
    }
    
    /// Cat's fart range attribute with modifications
    var fartRange: Int {
        return applyAttrMods(baseFartRange, mods: fartRangeMods)
    }
    
    /// Cat's Pui damage attribute with modifications
    var puiDmg: Int {
        return applyAttrMods(basePuiDmg, mods: dmgMods)
    }
    
    /// Cat's Fart damage attribute with modifications
    var fartDmg: Int {
        return applyAttrMods(baseFartDmg, mods: dmgMods)
    }
    
    /// Cat's Poop damage attribute with modifications
    var poopDmg: Int {
        return applyAttrMods(basePoopDmg, mods: dmgMods)
    }

    /// Name of the sprite image used to draw the cat
    var spriteImage: String {
        return _spriteImage
    }
    
    /// Movement preview sprite
    var previewSprite: SKSpriteNode {
        return _previewSprite
    }
    
    /// Constructs a cat with its base attributes
    ///
    /// :param: catName Name speicifying cat type
    /// :param: catHp Base HP
    /// :param: catDef Base defence
    /// :param: catPuiDmg Base Pui damage
    /// :param: catFartDmg Base Fart damage
    init(catName: String, catHp: Int, catDef: Int, catPuiDmg: Int, catFartDmg: Int) {
        name = catName
        hp = catHp
        baseDefence = catDef
        basePuiDmg = catPuiDmg
        baseFartDmg = catFartDmg
        basePoopDmg = Constants.catAttributes.poopDmg
        baseMoveRange = Constants.catAttributes.moveRange
        baseFartRange = Constants.catAttributes.fartRange
        
        switch catName {
        case Constants.catName.nyanCat:
            _spriteImage = "Nyan.png"
        case Constants.catName.grumpyCat:
            _spriteImage = "Grumpy.png"
        case Constants.catName.pusheenCat:
            _spriteImage = "Pusheen.png"
        default:
            _spriteImage = "Nala.png"
        }

        _sprite = SKTouchSpriteNode(imageNamed: _spriteImage)
        _previewSprite = SKTouchSpriteNode(imageNamed: _spriteImage)

        _sprite.zPosition = Constants.Z.cat
        _previewSprite.zPosition = Constants.Z.catPreview
        _previewSprite.alpha = 0.5
    }
    
    /// Inflicts the damage on to cat's hp,
    /// after applying cat's defence attribute.
    /// cat.hp -= damage * 1/defence
    ///
    /// :param: damage Points to be reduced from hp
    func inflict(damage: Int) {
        self.hp -= damage * 1/defence

        hpListener?.onHpUpdate(self.hp)
    }
    
    /// Heals cat's HP directly.
    /// cat.hp += hp
    ///
    /// :param: hp Points to increase the hp
    func heal(hp: Int) {
        self.hp += hp

        hpListener?.onHpUpdate(self.hp)
    }
    
    func isVisible() -> Bool {
        return true
    }
    
    func getSprite() -> SKNode {
        return _sprite
    }
    
    /// Called after execution of each game turn, to decay
    /// attribute modifications.
    func postExecute() {
        moveRangeMods = moveRangeMods.filter {
            (var mod) in
            return --mod.life > 0
        }
        defenceMods = defenceMods.filter {
            (var mod) in
            return --mod.life > 0
        }
        fartRangeMods = fartRangeMods.filter {
            (var mod) in
            return --mod.life > 0
        }
        dmgMods = dmgMods.filter {
            (var mod) in
            return --mod.life > 0
        }
    }
    
    /// Helper method to apply attribute modifications.
    ///
    /// :param: baseValue Base attribute of the cat
    /// :param: mods StatModifications to be applied to base attribute value
    private func applyAttrMods(baseValue: Int, mods: [AttrModification]) -> Int {
        var value = baseValue
        for mod in mods {
            value += mod.modification
        }
        return value
    }
}