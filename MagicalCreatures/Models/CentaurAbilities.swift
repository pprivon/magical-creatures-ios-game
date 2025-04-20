import Foundation
import SpriteKit

// MARK: - Bow Shot Ability

/// Bow Shot ability lets the centaur shoot arrows at targets
class BowShotAbility: Ability {
    init() {
        super.init(name: "BowShot", cooldown: 1.0, manaCost: 0)
    }
    
    override func use(character: Character, target: Character? = nil) -> Bool {
        guard super.use(character: character, target: target),
              let centaur = character as? Centaur else {
            return false
        }
        
        // If we have a target character, use its position
        if let targetPosition = target?.position {
            return centaur.bowAttack(targetPoint: targetPosition)
        }
        
        // If no specific target, shoot in the direction the centaur is facing
        guard let sprite = centaur.sprite else { return false }
        
        // Determine facing direction
        let facingRight = sprite.xScale > 0
        let shootDistance: CGFloat = 500.0
        
        // Create a point in front of the centaur
        let targetPoint = CGPoint(
            x: centaur.position.x + (facingRight ? shootDistance : -shootDistance),
            y: centaur.position.y
        )
        
        return centaur.bowAttack(targetPoint: targetPoint)
    }
}

// MARK: - Rear Kick Ability

/// Rear Kick ability lets the centaur kick enemies behind him
class RearKickAbility: Ability {
    init() {
        super.init(name: "RearKick", cooldown: 2.0, manaCost: 0)
    }
    
    override func use(character: Character, target: Character? = nil) -> Bool {
        guard super.use(character: character, target: target),
              let centaur = character as? Centaur else {
            return false
        }
        
        return centaur.kickAttack()
    }
}

// MARK: - Healing Touch Ability

/// Healing Touch ability allows the centaur to heal himself or allies
class HealingTouchAbility: Ability {
    // Healing amount as percentage of max health
    private let healPercentage: Double = 0.2
    
    init() {
        super.init(name: "HealingTouch", cooldown: 10.0, manaCost: 3)
    }
    
    override func use(character: Character, target: Character? = nil) -> Bool {
        guard super.use(character: character, target: target) else {
            return false
        }
        
        // Determine the target (self if no target specified)
        let healTarget = target ?? character
        
        // Calculate healing amount
        let healAmount = Int(Double(healTarget.maxHealth) * healPercentage)
        
        // Apply the healing
        healTarget.heal(amount: healAmount)
        
        // Deduct mana cost
        character.magic -= manaCost
        
        // Play healing sound
        SoundManager.shared.playSoundEffect(filename: "healing")
        
        // Create healing effect (particles)
        if let sprite = healTarget.sprite, let scene = sprite.scene {
            // Create a particle effect for healing
            let healEffect = SKEmitterNode()
            
            // Configure the particle effect
            // These properties would be set based on a pre-configured particle file
            // For now, we'll just create a basic placeholder
            healEffect.particleColor = .green
            healEffect.particleBirthRate = 20
            healEffect.particleLifetime = 2.0
            healEffect.position = sprite.position
            
            // Add to scene
            scene.addChild(healEffect)
            
            // Remove after animation completes
            healEffect.run(SKAction.sequence([
                SKAction.wait(forDuration: 2.0),
                SKAction.removeFromParent()
            ]))
        }
        
        return true
    }
}

// MARK: - Stampede Dash Ability

/// Stampede Dash ability allows the centaur to dash forward, damaging enemies in his path
class StampedeDashAbility: Ability {
    // Dash properties
    private let dashDistance: CGFloat = 300.0
    private let dashDuration: TimeInterval = 0.4
    private let damageMultiplier: Double = 1.5
    
    init() {
        super.init(name: "StampedeDash", cooldown: 6.0, manaCost: 2)
    }
    
    override func use(character: Character, target: Character? = nil) -> Bool {
        guard super.use(character: character, target: target),
              let centaur = character as? Centaur,
              let sprite = centaur.sprite,
              let scene = sprite.scene else {
            return false
        }
        
        // Determine dash direction (use sprite x scale to know facing direction)
        let dashDirection = CGVector(
            dx: sprite.xScale > 0 ? 1 : -1,
            dy: 0
        )
        
        // Play dash animation
        centaur.runAnimation(name: "dash", repeatForever: false) {
            centaur.runAnimation(name: "idle", repeatForever: true)
        }
        
        // Play stampede sound
        SoundManager.shared.playSoundEffect(filename: "stampede")
        
        // Create dust trail effect
        let dustEffect = SKEmitterNode()
        dustEffect.particleColor = .brown
        dustEffect.particleBirthRate = 40
        dustEffect.particleLifetime = 1.0
        dustEffect.targetNode = scene
        dustEffect.position = CGPoint(
            x: sprite.position.x - (dashDirection.dx * 50),
            y: sprite.position.y - 30
        )
        scene.addChild(dustEffect)
        
        // Make centaur invulnerable during dash
        centaur.applyInvulnerability(duration: dashDuration + 0.1)
        
        // Apply dash movement
        let dashAction = SKAction.move(
            by: CGVector(dx: dashDirection.dx * dashDistance, dy: dashDirection.dy * dashDistance),
            duration: dashDuration
        )
        
        // Deduct mana cost
        centaur.magic -= manaCost
        
        // Execute dash
        sprite.run(dashAction) {
            // Remove dust effect after dash completes
            dustEffect.run(SKAction.sequence([
                SKAction.wait(forDuration: 1.0),
                SKAction.removeFromParent()
            ]))
        }
        
        // Setup collision detection for enemies in path
        // This would be handled by the physics engine
        // For now, we'll just set up a property that the game scene can check
        sprite.userData = sprite.userData ?? [:]
        sprite.userData?["isDashing"] = true
        sprite.userData?["dashDamage"] = Int(Double(centaur.strength) * damageMultiplier)
        
        // Reset dash state after completion
        DispatchQueue.main.asyncAfter(deadline: .now() + dashDuration) {
            sprite.userData?["isDashing"] = false
        }
        
        return true
    }
}

// MARK: - Nature's Bond Ability

/// Nature's Bond ability temporarily boosts the centaur's stats and summons animal spirits
class NaturesBondAbility: Ability {
    // Effect properties
    private let duration: TimeInterval = 10.0
    private let statBoostPercentage: Double = 0.3
    
    init() {
        super.init(name: "NaturesBond", cooldown: 30.0, manaCost: 5)
    }
    
    override func use(character: Character, target: Character? = nil) -> Bool {
        guard super.use(character: character, target: target),
              let centaur = character as? Centaur,
              let sprite = centaur.sprite,
              let scene = sprite.scene else {
            return false
        }
        
        // Play nature bond sound
        SoundManager.shared.playSoundEffect(filename: "nature_bond")
        
        // Create nature effect
        let natureEffect = SKEmitterNode()
        natureEffect.particleColor = .green
        natureEffect.particleBirthRate = 20
        natureEffect.particleLifetime = 3.0
        natureEffect.targetNode = scene
        natureEffect.position = sprite.position
        scene.addChild(natureEffect)
        
        // Store original stats for later restoration
        let originalStrength = centaur.strength
        let originalSpeed = centaur.speed
        let originalMagic = centaur.magic
        
        // Apply stat boosts
        centaur.strength = Int(Double(centaur.strength) * (1.0 + statBoostPercentage))
        centaur.speed = Int(Double(centaur.speed) * (1.0 + statBoostPercentage))
        centaur.magic = Int(Double(centaur.magic) * (1.0 + statBoostPercentage))
        
        // Deduct mana cost
        centaur.magic -= manaCost
        
        // Apply visual effect to centaur
        sprite.color = .green
        sprite.colorBlendFactor = 0.3
        
        // Summon animal spirits (simple visual effect)
        summonAnimalSpirits(around: centaur, in: scene)
        
        // Remove effect after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            // Restore original stats
            centaur.strength = originalStrength
            centaur.speed = originalSpeed
            centaur.magic = originalMagic
            
            // Remove visual effect
            sprite.colorBlendFactor = 0.0
            
            // Remove nature effect
            natureEffect.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.5),
                SKAction.removeFromParent()
            ]))
        }
        
        return true
    }
    
    /// Summon animal spirits around the centaur
    /// - Parameters:
    ///   - centaur: The centaur character
    ///   - scene: The scene to add the spirits to
    private func summonAnimalSpirits(around centaur: Centaur, in scene: SKScene) {
        // Define spirit types
        let spiritTypes = ["wolf", "owl", "rabbit", "deer"]
        
        // Create 3 random spirits
        for i in 0..<3 {
            // Choose random spirit type
            let spiritType = spiritTypes.randomElement() ?? "wolf"
            
            // Create spirit sprite
            let spiritSprite = SKSpriteNode(imageNamed: "spirit_\(spiritType)")
            spiritSprite.size = CGSize(width: 80, height: 80)
            spiritSprite.alpha = 0.7
            
            // Position around centaur in a circle
            let angle = CGFloat(i) * (2.0 * .pi / 3.0)
            let radius: CGFloat = 100.0
            let xPos = centaur.position.x + radius * cos(angle)
            let yPos = centaur.position.y + radius * sin(angle)
            spiritSprite.position = CGPoint(x: xPos, y: yPos)
            
            // Add to scene
            scene.addChild(spiritSprite)
            
            // Create orbit action
            let orbitAction = SKAction.customAction(withDuration: 10.0) { node, elapsedTime in
                let progress = elapsedTime / 10.0
                let newAngle = angle + progress * 2.0 * .pi * 2.0 // 2 full revolutions
                let newX = centaur.position.x + radius * cos(newAngle)
                let newY = centaur.position.y + radius * sin(newAngle)
                node.position = CGPoint(x: newX, y: newY)
            }
            
            // Run orbit and then fade out
            spiritSprite.run(SKAction.sequence([
                orbitAction,
                SKAction.fadeOut(withDuration: 0.5),
                SKAction.removeFromParent()
            ]))
        }
    }
}
