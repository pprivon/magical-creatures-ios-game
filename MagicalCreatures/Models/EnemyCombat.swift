import Foundation
import SpriteKit

/// Extension to Enemy class containing combat logic
extension Enemy {
    
    // MARK: - Combat Methods
    
    /// Perform an attack on the target
    /// - Parameter target: The character to attack
    func performAttack(target: Character) {
        // Choose attack type based on enemy type
        switch enemyType {
        case .shadowMage, .lordObsidian:
            if Int.random(in: 0...100) < 70 {
                // 70% chance to use magic attack
                performMagicAttack(target: target)
            } else {
                performMeleeAttack(target: target)
            }
        case .darkKnight:
            performMeleeAttack(target: target)
        default:
            performMeleeAttack(target: target)
        }
    }
    
    /// Perform a melee attack
    /// - Parameter target: The character to attack
    func performMeleeAttack(target: Character) {
        // Play attack animation
        runAnimation(name: "attack", repeatForever: false) {
            self.runAnimation(name: "idle", repeatForever: true)
        }
        
        // Play sound effect based on enemy type
        switch enemyType {
        case .shadowScout:
            SoundManager.shared.playSoundEffect(filename: "shadow_scout_attack")
        case .cageMaster:
            SoundManager.shared.playSoundEffect(filename: "cage_master_attack")
        case .darkKnight:
            SoundManager.shared.playSoundEffect(filename: "dark_knight_attack")
        case .shadowMage:
            SoundManager.shared.playSoundEffect(filename: "shadow_mage_attack")
        case .lordObsidian:
            SoundManager.shared.playSoundEffect(filename: "lord_obsidian_attack")
        }
        
        // Deal damage to target
        let damage = attack(target: target)
        
        // Create hit effect
        if damage > 0, let targetSprite = target.sprite, let scene = targetSprite.scene {
            // Create a simple hit effect
            let hitEffect = SKEmitterNode()
            hitEffect.particleColor = .red
            hitEffect.particleBirthRate = 20
            hitEffect.particleLifetime = 0.5
            hitEffect.position = targetSprite.position
            
            scene.addChild(hitEffect)
            
            // Remove after a short time
            hitEffect.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.5),
                SKAction.removeFromParent()
            ]))
        }
    }
    
    /// Perform a magic attack
    /// - Parameter target: The character to attack
    func performMagicAttack(target: Character) {
        // Play magic attack animation
        runAnimation(name: "magicAttack", repeatForever: false) {
            self.runAnimation(name: "idle", repeatForever: true)
        }
        
        // Play magic sound effect
        switch enemyType {
        case .shadowMage:
            SoundManager.shared.playSoundEffect(filename: "shadow_magic")
        case .lordObsidian:
            SoundManager.shared.playSoundEffect(filename: "dark_magic")
        default:
            SoundManager.shared.playSoundEffect(filename: "magic_attack")
        }
        
        // Create and launch magic projectile
        createMagicProjectile(target: target)
    }
    
    /// Create a magic projectile to attack the target
    /// - Parameter target: The character to attack
    func createMagicProjectile(target: Character) {
        guard let sprite = sprite, let scene = sprite.scene else { return }
        
        // Create magic projectile sprite
        let projectileTextureName: String
        let projectileSize: CGSize
        let projectileColor: UIColor
        
        switch enemyType {
        case .shadowMage:
            projectileTextureName = "shadow_orb"
            projectileSize = CGSize(width: 30, height: 30)
            projectileColor = .purple
        case .lordObsidian:
            projectileTextureName = "dark_fire"
            projectileSize = CGSize(width: 40, height: 40)
            projectileColor = .black
        default:
            projectileTextureName = "magic_projectile"
            projectileSize = CGSize(width: 20, height: 20)
            projectileColor = .blue
        }
        
        let projectileSprite = SKSpriteNode(imageNamed: projectileTextureName)
        projectileSprite.size = projectileSize
        projectileSprite.color = projectileColor
        projectileSprite.colorBlendFactor = 0.5
        projectileSprite.position = position
        
        // Calculate direction to target
        let dx = target.position.x - position.x
        let dy = target.position.y - position.y
        let distance = sqrt(dx * dx + dy * dy)
        
        // Normalize direction
        let direction = CGVector(
            dx: dx / distance,
            dy: dy / distance
        )
        
        // Add to scene
        scene.addChild(projectileSprite)
        
        // Set up physics body
        projectileSprite.physicsBody = SKPhysicsBody(circleOfRadius: projectileSize.width / 2)
        projectileSprite.physicsBody?.isDynamic = true
        projectileSprite.physicsBody?.affectedByGravity = false
        projectileSprite.physicsBody?.categoryBitMask = 0x1 << 3 // Magic projectile category
        projectileSprite.physicsBody?.contactTestBitMask = 0x1 << 0 // Player category
        projectileSprite.physicsBody?.collisionBitMask = 0 // No collisions, just pass through
        
        // Apply velocity
        let projectileSpeed: CGFloat = 300.0
        let velocity = CGVector(
            dx: direction.dx * projectileSpeed,
            dy: direction.dy * projectileSpeed
        )
        
        projectileSprite.physicsBody?.velocity = velocity
        
        // Create glow effect
        let glowAction = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.7, duration: 0.3),
            SKAction.fadeAlpha(to: 1.0, duration: 0.3)
        ])
        
        projectileSprite.run(SKAction.repeatForever(glowAction))
        
        // Add particle trail
        let trailEffect = SKEmitterNode()
        trailEffect.particleColor = projectileColor
        trailEffect.particleBirthRate = 30
        trailEffect.particleLifetime = 0.5
        trailEffect.targetNode = scene
        trailEffect.position = .zero
        
        projectileSprite.addChild(trailEffect)
        
        // Remove after traveling for a while or on hit
        let travelDistance: CGFloat = distance * 1.5
        let travelTime = travelDistance / projectileSpeed
        
        projectileSprite.run(SKAction.sequence([
            SKAction.wait(forDuration: TimeInterval(travelTime)),
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.removeFromParent()
        ]))
        
        // Store projectile damage value
        let damage = Int(Double(self.magic) * 1.2)
        projectileSprite.userData = ["damage": damage, "owner": self]
        
        // Handle hit logic in the game scene's contact handler
    }
    
    // MARK: - Death
    
    /// Handle enemy death
    func die() {
        guard isAlive else { return }
        
        // Set health to 0
        health = 0
        
        // Play death animation
        runAnimation(name: "defeat", repeatForever: false)
        
        // Play death sound
        SoundManager.shared.playSoundEffect(filename: "enemy_defeat")
        
        // Create death effect
        if let sprite = sprite, let scene = sprite.scene {
            // Create a simple death effect
            let deathEffect = SKEmitterNode()
            deathEffect.particleColor = .black
            deathEffect.particleBirthRate = 50
            deathEffect.particleLifetime = 1.0
            deathEffect.position = sprite.position
            
            scene.addChild(deathEffect)
            
            // Fade out sprite
            sprite.run(SKAction.sequence([
                SKAction.wait(forDuration: 1.5),
                SKAction.fadeOut(withDuration: 0.5),
                SKAction.run {
                    // Remove sprite and effect
                    sprite.removeFromParent()
                    deathEffect.run(SKAction.sequence([
                        SKAction.wait(forDuration: 0.5),
                        SKAction.removeFromParent()
                    ]))
                }
            ]))
        }
    }
    
    // MARK: - Drops and Rewards
    
    /// Get the experience points value for defeating this enemy
    /// - Returns: XP amount
    func experienceValue() -> Int {
        return enemyType.experienceValue
    }
    
    /// Determine if the enemy should drop an item when defeated
    /// - Returns: Optional item identifier to drop
    func determineItemDrop() -> String? {
        // Check if we should drop anything
        if Int.random(in: 1...100) > enemyType.dropChance {
            return nil // No drop
        }
        
        // Choose a random item from the possible drops
        let possibleItems = enemyType.possibleDrops
        guard !possibleItems.isEmpty else { return nil }
        
        let randomIndex = Int.random(in: 0..<possibleItems.count)
        return possibleItems[randomIndex]
    }
    
    /// Create a dropped item at the enemy's position
    /// - Parameters:
    ///   - itemId: The item identifier
    ///   - scene: The scene to add the item to
    /// - Returns: The created item node
    func createItemDrop(_ itemId: String, in scene: SKScene) -> SKNode {
        // Create item sprite
        let itemSprite = SKSpriteNode(imageNamed: "item_\(itemId.lowercased())")
        itemSprite.size = CGSize(width: 40, height: 40)
        itemSprite.position = position
        
        // Add subtle animation
        let pulseAction = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.5),
            SKAction.scale(to: 0.9, duration: 0.5)
        ])
        
        itemSprite.run(SKAction.repeatForever(pulseAction))
        
        // Add glow effect
        let glowNode = SKEffectNode()
        let glowFilter = CIFilter(name: "CIGaussianBlur")
        glowFilter?.setValue(5.0, forKey: "inputRadius")
        glowNode.filter = glowFilter
        glowNode.addChild(itemSprite.copy() as! SKNode)
        glowNode.alpha = 0.6
        
        // Create container node
        let containerNode = SKNode()
        containerNode.addChild(itemSprite)
        containerNode.addChild(glowNode)
        
        // Set up physics body for collection
        itemSprite.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        itemSprite.physicsBody?.isDynamic = false
        itemSprite.physicsBody?.categoryBitMask = 0x1 << 4 // Item category
        itemSprite.physicsBody?.contactTestBitMask = 0x1 << 0 // Player category
        
        // Store item data
        itemSprite.userData = ["itemId": itemId]
        
        // Add to scene
        scene.addChild(containerNode)
        
        return containerNode
    }
}
