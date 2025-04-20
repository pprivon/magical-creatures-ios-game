import SpriteKit

/**
 * CombatSystem
 * 
 * A class that manages combat interactions between characters in the game,
 * handling damage calculations, attack animations, and combat effects.
 */
class CombatSystem {
    
    // Reference to the game scene
    private weak var gameScene: GameScene?
    
    // Combat configuration
    private struct CombatConfig {
        // Base damage multipliers
        static let criticalHitMultiplier = 2.0
        static let backstabMultiplier = 1.5
        static let counterAttackMultiplier = 1.2
        
        // Effect chances (0.0-1.0)
        static let criticalHitChance = 0.15
        static let dodgeChance = 0.1
        static let counterAttackChance = 0.2
        
        // Elemental multipliers
        static let strongElementalMultiplier = 1.5
        static let weakElementalMultiplier = 0.5
    }
    
    // Elements and their relationships
    enum Element: String {
        case none = "none"
        case fire = "fire"
        case water = "water"
        case earth = "earth"
        case air = "air"
        case light = "light"
        case dark = "dark"
        
        // Get element that this is strong against
        func strongAgainst() -> Element {
            switch self {
            case .fire: return .earth
            case .water: return .fire
            case .earth: return .air
            case .air: return .water
            case .light: return .dark
            case .dark: return .light
            case .none: return .none
            }
        }
        
        // Get element that this is weak against
        func weakAgainst() -> Element {
            switch self {
            case .fire: return .water
            case .water: return .air
            case .earth: return .fire
            case .air: return .earth
            case .light: return .dark
            case .dark: return .light
            case .none: return .none
            }
        }
    }
    
    // Combat effects that can be applied
    enum CombatEffect: String {
        case burning = "burning"       // Damage over time
        case frozen = "frozen"         // Movement speed reduced
        case stunned = "stunned"       // Cannot attack
        case poisoned = "poisoned"     // Damage over time and vision effects
        case healed = "healed"         // Healing over time
        case shielded = "shielded"     // Damage reduction
        case empowered = "empowered"   // Increased damage
        case hasted = "hasted"         // Increased speed
    }
    
    // Attack types
    enum AttackType {
        case melee
        case ranged
        case area
        case special
    }
    
    /**
     * Initialize with a reference to the game scene
     */
    init(gameScene: GameScene) {
        self.gameScene = gameScene
    }
    
    /**
     * Process a player attack
     */
    func performPlayerAttack(attackType: AttackType, element: Element = .none) -> SKNode {
        // Create attack node
        let attackNode: SKSpriteNode
        
        // Set up the attack based on type
        switch attackType {
        case .melee:
            attackNode = createMeleeAttack(element: element)
        case .ranged:
            attackNode = createRangedAttack(element: element)
        case .area:
            attackNode = createAreaAttack(element: element)
        case .special:
            attackNode = createSpecialAttack(element: element)
        }
        
        // Return the attack node for the game scene to position and animate
        return attackNode
    }
    
    /**
     * Process an enemy attack
     */
    func performEnemyAttack(enemy: SKNode, attackType: AttackType, element: Element = .none) -> SKNode {
        // Get enemy data
        let enemyPower = enemy.userData?.value(forKey: "attackPower") as? Int ?? 1
        
        // Create attack node
        let attackNode: SKSpriteNode
        
        // Set up the attack based on type
        switch attackType {
        case .melee:
            attackNode = createMeleeAttack(element: element, basePower: enemyPower, isPlayerAttack: false)
        case .ranged:
            attackNode = createRangedAttack(element: element, basePower: enemyPower, isPlayerAttack: false)
        case .area:
            attackNode = createAreaAttack(element: element, basePower: enemyPower, isPlayerAttack: false)
        case .special:
            attackNode = createSpecialAttack(element: element, basePower: enemyPower, isPlayerAttack: false)
        }
        
        // Return the attack node for the game scene to position and animate
        return attackNode
    }
    
    /**
     * Create a melee attack
     */
    private func createMeleeAttack(element: Element = .none, basePower: Int = 10, isPlayerAttack: Bool = true) -> SKSpriteNode {
        let size = CGSize(width: 60, height: 60)
        let texture = SKTexture(imageNamed: "attack_melee_\(element.rawValue)")
        let attackNode = SKSpriteNode(texture: texture, color: .white, size: size)
        
        // Set up attack properties
        attackNode.name = isPlayerAttack ? "playerAttack" : "enemyAttack"
        attackNode.alpha = 0.8
        attackNode.zPosition = 5
        
        // Store attack data
        attackNode.userData = NSMutableDictionary()
        attackNode.userData?.setValue(basePower, forKey: "damage")
        attackNode.userData?.setValue(element.rawValue, forKey: "element")
        attackNode.userData?.setValue(false, forKey: "isPersistent")
        
        // Add a short lifetime
        attackNode.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.2),
            SKAction.fadeOut(withDuration: 0.1),
            SKAction.removeFromParent()
        ]))
        
        return attackNode
    }
    
    /**
     * Create a ranged attack
     */
    private func createRangedAttack(element: Element = .none, basePower: Int = 8, isPlayerAttack: Bool = true) -> SKSpriteNode {
        let size = CGSize(width: 30, height: 30)
        let texture = SKTexture(imageNamed: "attack_ranged_\(element.rawValue)")
        let attackNode = SKSpriteNode(texture: texture, color: .white, size: size)
        
        // Set up attack properties
        attackNode.name = isPlayerAttack ? "playerAttack" : "enemyAttack"
        attackNode.zPosition = 5
        
        // Add glow effect based on element
        let glowColor: SKColor
        
        switch element {
        case .fire:
            glowColor = .red
        case .water:
            glowColor = .blue
        case .earth:
            glowColor = .brown
        case .air:
            glowColor = .cyan
        case .light:
            glowColor = .yellow
        case .dark:
            glowColor = .purple
        case .none:
            glowColor = .white
        }
        
        attackNode.addGlow(radius: 10, color: glowColor)
        
        // Store attack data
        attackNode.userData = NSMutableDictionary()
        attackNode.userData?.setValue(basePower, forKey: "damage")
        attackNode.userData?.setValue(element.rawValue, forKey: "element")
        attackNode.userData?.setValue(false, forKey: "isPersistent")
        
        return attackNode
    }
    
    /**
     * Create an area attack
     */
    private func createAreaAttack(element: Element = .none, basePower: Int = 6, isPlayerAttack: Bool = true) -> SKSpriteNode {
        let size = CGSize(width: 150, height: 150)
        let attackNode = SKSpriteNode(color: .clear, size: size)
        
        // Set up attack properties
        attackNode.name = isPlayerAttack ? "playerAttack" : "enemyAttack"
        attackNode.zPosition = 4
        
        // Add particle effect based on element
        if let particles = SKEmitterNode(fileNamed: "areaEffect_\(element.rawValue)") {
            particles.particleBirthRate = 20
            attackNode.addChild(particles)
        } else {
            // Fallback if particle file not found
            attackNode.color = .cyan
            attackNode.alpha = 0.4
        }
        
        // Store attack data
        attackNode.userData = NSMutableDictionary()
        attackNode.userData?.setValue(basePower, forKey: "damage")
        attackNode.userData?.setValue(element.rawValue, forKey: "element")
        attackNode.userData?.setValue(true, forKey: "isPersistent")
        attackNode.userData?.setValue(2.0, forKey: "duration")
        
        // Add a moderate lifetime
        attackNode.run(SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
        
        return attackNode
    }
    
    /**
     * Create a special attack
     */
    private func createSpecialAttack(element: Element = .none, basePower: Int = 15, isPlayerAttack: Bool = true) -> SKSpriteNode {
        let size = CGSize(width: 100, height: 100)
        let attackNode = SKSpriteNode(color: .clear, size: size)
        
        // Set up attack properties
        attackNode.name = isPlayerAttack ? "playerAttack" : "enemyAttack"
        attackNode.zPosition = 5
        
        // Add special visual effects
        let specialEffect = SKSpriteNode(imageNamed: "attack_special_\(element.rawValue)")
        specialEffect.setScale(0.8)
        specialEffect.alpha = 0.9
        attackNode.addChild(specialEffect)
        
        // Add rotation animation
        let rotateAction = SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 1.0))
        specialEffect.run(rotateAction)
        
        // Add pulsing effect
        let pulseAction = SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.5),
            SKAction.scale(to: 0.8, duration: 0.5)
        ]))
        specialEffect.run(pulseAction)
        
        // Store attack data
        attackNode.userData = NSMutableDictionary()
        attackNode.userData?.setValue(basePower, forKey: "damage")
        attackNode.userData?.setValue(element.rawValue, forKey: "element")
        attackNode.userData?.setValue(true, forKey: "isPersistent")
        attackNode.userData?.setValue(1.5, forKey: "duration")
        
        // Add combat effect based on element
        var effect: CombatEffect? = nil
        
        switch element {
        case .fire:
            effect = .burning
        case .water:
            effect = .frozen
        case .earth:
            effect = .stunned
        case .air:
            effect = .hasted
        case .light:
            effect = .healed
        case .dark:
            effect = .poisoned
        case .none:
            effect = nil
        }
        
        if let effectName = effect?.rawValue {
            attackNode.userData?.setValue(effectName, forKey: "effect")
            attackNode.userData?.setValue(3.0, forKey: "effectDuration")
        }
        
        // Add a moderate lifetime
        attackNode.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.5),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
        
        return attackNode
    }
    
    /**
     * Calculate damage for an attack
     */
    func calculateDamage(attackerPower: Int, defenderDefense: Int, attackElement: Element, defenderElement: Element) -> (damage: Int, isCritical: Bool) {
        var damage = max(1, attackerPower - (defenderDefense / 2))
        var isCritical = false
        
        // Check for critical hit
        if Double.random(in: 0...1) < CombatConfig.criticalHitChance {
            damage = Int(Double(damage) * CombatConfig.criticalHitMultiplier)
            isCritical = true
        }
        
        // Apply elemental modifiers
        if attackElement.strongAgainst() == defenderElement {
            damage = Int(Double(damage) * CombatConfig.strongElementalMultiplier)
        } else if attackElement.weakAgainst() == defenderElement {
            damage = Int(Double(damage) * CombatConfig.weakElementalMultiplier)
        }
        
        return (damage, isCritical)
    }
    
    /**
     * Check if an attack is dodged
     */
    func isDodged(defenderAgility: Int) -> Bool {
        let baseDodgeChance = CombatConfig.dodgeChance
        let agilityBonus = min(0.3, Double(defenderAgility) * 0.01) // Max 30% bonus from agility
        let totalDodgeChance = baseDodgeChance + agilityBonus
        
        return Double.random(in: 0...1) < totalDodgeChance
    }
    
    /**
     * Apply a combat effect to a character
     */
    func applyEffect(effect: CombatEffect, to characterNode: SKNode, duration: TimeInterval) {
        // Create label to show effect
        let effectLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        effectLabel.text = effect.rawValue.uppercased()
        effectLabel.fontSize = 14
        effectLabel.position = CGPoint(x: 0, y: 30)
        effectLabel.zPosition = 10
        
        // Set color based on effect type
        switch effect {
        case .burning:
            effectLabel.fontColor = .red
        case .frozen:
            effectLabel.fontColor = .blue
        case .stunned:
            effectLabel.fontColor = .orange
        case .poisoned:
            effectLabel.fontColor = .green
        case .healed:
            effectLabel.fontColor = .magenta
        case .shielded:
            effectLabel.fontColor = .gray
        case .empowered:
            effectLabel.fontColor = .purple
        case .hasted:
            effectLabel.fontColor = .cyan
        }
        
        // Add effect indicator to character
        characterNode.addChild(effectLabel)
        
        // Store effect in character's user data
        let userData = characterNode.userData ?? NSMutableDictionary()
        userData.setValue(effect.rawValue, forKey: "activeEffect")
        userData.setValue(CACurrentMediaTime() + duration, forKey: "effectEndTime")
        characterNode.userData = userData
        
        // Add visual effect based on effect type
        if let particles = createEffectParticles(for: effect) {
            particles.name = "effectParticles"
            characterNode.addChild(particles)
        }
        
        // Set up automatic removal after duration
        effectLabel.run(SKAction.sequence([
            SKAction.wait(forDuration: duration),
            SKAction.run { [weak self] in
                self?.removeEffect(from: characterNode)
            },
            SKAction.removeFromParent()
        ]))
    }
    
    /**
     * Create particle effects for a combat effect
     */
    private func createEffectParticles(for effect: CombatEffect) -> SKEmitterNode? {
        // Try to load particle effect from file
        if let particles = SKEmitterNode(fileNamed: "effect_\(effect.rawValue)") {
            return particles
        }
        
        // Fallback: create a basic particle effect
        let particles = SKEmitterNode()
        
        // Configure basic properties
        particles.particleBirthRate = 10
        particles.numParticlesToEmit = 100
        particles.particleLifetime = 1.0
        particles.particleLifetimeRange = 0.5
        particles.particlePosition = .zero
        particles.particlePositionRange = CGVector(dx: 20, dy: 20)
        particles.emissionAngle = 0
        particles.emissionAngleRange = CGFloat.pi * 2
        particles.particleSpeed = 20
        particles.particleSpeedRange = 10
        particles.particleAlpha = 0.8
        particles.particleAlphaRange = 0.2
        particles.particleAlphaSpeed = -0.5
        particles.particleScale = 0.1
        particles.particleScaleRange = 0.05
        particles.particleScaleSpeed = -0.05
        particles.zPosition = 3
        
        // Configure color based on effect
        switch effect {
        case .burning:
            particles.particleColor = .red
            particles.particleColorBlendFactor = 1.0
            particles.particleBlendMode = .add
        case .frozen:
            particles.particleColor = .cyan
            particles.particleColorBlendFactor = 1.0
            particles.particleBlendMode = .alpha
        case .stunned:
            particles.particleColor = .yellow
            particles.particleColorBlendFactor = 1.0
            particles.particleBlendMode = .add
        case .poisoned:
            particles.particleColor = .green
            particles.particleColorBlendFactor = 1.0
            particles.particleBlendMode = .alpha
        case .healed:
            particles.particleColor = .magenta
            particles.particleColorBlendFactor = 1.0
            particles.particleBlendMode = .add
        case .shielded:
            particles.particleColor = .gray
            particles.particleColorBlendFactor = 1.0
            particles.particleBlendMode = .add
        case .empowered:
            particles.particleColor = .purple
            particles.particleColorBlendFactor = 1.0
            particles.particleBlendMode = .add
        case .hasted:
            particles.particleColor = .blue
            particles.particleColorBlendFactor = 1.0
            particles.particleBlendMode = .add
        }
        
        return particles
    }
    
    /**
     * Remove a combat effect from a character
     */
    private func removeEffect(from characterNode: SKNode) {
        // Remove effect data
        characterNode.userData?.removeObject(forKey: "activeEffect")
        characterNode.userData?.removeObject(forKey: "effectEndTime")
        
        // Remove effect particles
        characterNode.childNode(withName: "effectParticles")?.removeFromParent()
    }
    
    /**
     * Create a damage indicator that floats up from the hit location
     */
    func createDamageIndicator(damage: Int, at position: CGPoint, isCritical: Bool) -> SKNode {
        let damageLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        damageLabel.text = "\(damage)"
        damageLabel.fontSize = isCritical ? 24 : 16
        damageLabel.fontColor = isCritical ? .red : .white
        damageLabel.position = position
        damageLabel.zPosition = 10
        
        // Add outline to make text readable against any background
        if isCritical {
            damageLabel.addGlow(radius: 2, color: .black)
        }
        
        // Animate the damage number
        let moveAction = SKAction.moveBy(x: 0, y: 40, duration: 0.8)
        let fadeAction = SKAction.fadeOut(withDuration: 0.2)
        
        damageLabel.run(SKAction.sequence([
            moveAction,
            fadeAction,
            SKAction.removeFromParent()
        ]))
        
        return damageLabel
    }
    
    /**
     * Create a healing indicator
     */
    func createHealingIndicator(amount: Int, at position: CGPoint) -> SKNode {
        let healLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        healLabel.text = "+\(amount)"
        healLabel.fontSize = 16
        healLabel.fontColor = .green
        healLabel.position = position
        healLabel.zPosition = 10
        
        // Animate the healing number
        let moveAction = SKAction.moveBy(x: 0, y: 40, duration: 0.8)
        let fadeAction = SKAction.fadeOut(withDuration: 0.2)
        
        healLabel.run(SKAction.sequence([
            moveAction,
            fadeAction,
            SKAction.removeFromParent()
        ]))
        
        return healLabel
    }
}

/**
 * Extension for SKNode to add glow effect
 */
extension SKNode {
    func addGlow(radius: CGFloat, color: SKColor) {
        let effectNode = SKEffectNode()
        effectNode.shouldRasterize = true
        effectNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": radius])
        effectNode.addChild(self.copy() as! SKNode)
        effectNode.alpha = 0.5
        self.parent?.addChild(effectNode)
        effectNode.position = self.position
        effectNode.zPosition = self.zPosition - 0.1
    }
}
