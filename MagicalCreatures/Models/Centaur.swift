import Foundation
import SpriteKit

/// The Centaur class represents the player character
class Centaur: Character {
    // MARK: - Properties
    
    // Special centaur abilities
    var bowAmmo: Int = 10
    var maxBowAmmo: Int = 10
    var dashCooldown: TimeInterval = 3.0
    var lastDashTime: TimeInterval = 0
    var dashDistance: CGFloat = 200.0
    var isLevelingUp: Bool = false
    
    // Customization
    var centaurAppearance: CentaurAppearance = .default
    
    // MARK: - Enums
    
    enum CentaurAppearance: String {
        case `default` = "default"
        case forest = "forest"
        case royal = "royal"
        case warrior = "warrior"
        
        var textureName: String {
            switch self {
            case .default: return "centaur_default"
            case .forest: return "centaur_forest"
            case .royal: return "centaur_royal"
            case .warrior: return "centaur_warrior"
            }
        }
    }
    
    // MARK: - Initialization
    
    /// Initialize the centaur character with default attributes
    init(appearance: CentaurAppearance = .default) {
        self.centaurAppearance = appearance
        
        // Initialize with base stats
        super.init(
            name: "Orion",
            health: GameManager.shared.playerHealth,
            strength: GameManager.shared.playerStrength,
            magic: GameManager.shared.playerMagic,
            speed: GameManager.shared.playerSpeed
        )
        
        // Setup centaur-specific abilities
        setupAbilities()
    }
    
    // MARK: - Setup
    
    /// Load the centaur's sprite and animations
    /// - Parameter scene: The SKScene to add the sprite to
    func load(in scene: SKScene) {
        // Load base texture
        let baseTexture = SKTexture(imageNamed: centaurAppearance.textureName + "_idle_1")
        
        // Create sprite with appropriate size
        setupSprite(texture: baseTexture, size: CGSize(width: 200, height: 200))
        
        // Set initial position
        position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        
        // Add to scene
        if let sprite = sprite {
            scene.addChild(sprite)
        }
        
        // Load animations
        loadAnimations()
        
        // Set idle animation by default
        runAnimation(name: "idle", repeatForever: true)
    }
    
    /// Load all animations for the centaur
    private func loadAnimations() {
        // Define animation sequences (we'll add actual textures later)
        // These would typically be loaded from sprite sheets
        let baseTexturePath = centaurAppearance.textureName
        
        // Idle animation
        var idleFrames: [SKTexture] = []
        for i in 1...4 {
            let textureName = "\(baseTexturePath)_idle_\(i)"
            idleFrames.append(SKTexture(imageNamed: textureName))
        }
        addAnimation(name: "idle", textures: idleFrames)
        
        // Walk animation
        var walkFrames: [SKTexture] = []
        for i in 1...6 {
            let textureName = "\(baseTexturePath)_walk_\(i)"
            walkFrames.append(SKTexture(imageNamed: textureName))
        }
        addAnimation(name: "walk", textures: walkFrames)
        
        // Attack (bow) animation
        var bowAttackFrames: [SKTexture] = []
        for i in 1...5 {
            let textureName = "\(baseTexturePath)_bow_\(i)"
            bowAttackFrames.append(SKTexture(imageNamed: textureName))
        }
        addAnimation(name: "bowAttack", textures: bowAttackFrames)
        
        // Attack (kick) animation
        var kickAttackFrames: [SKTexture] = []
        for i in 1...4 {
            let textureName = "\(baseTexturePath)_kick_\(i)"
            kickAttackFrames.append(SKTexture(imageNamed: textureName))
        }
        addAnimation(name: "kickAttack", textures: kickAttackFrames)
        
        // Hit animation
        var hitFrames: [SKTexture] = []
        for i in 1...2 {
            let textureName = "\(baseTexturePath)_hit_\(i)"
            hitFrames.append(SKTexture(imageNamed: textureName))
        }
        addAnimation(name: "hit", textures: hitFrames)
        
        // Dash animation
        var dashFrames: [SKTexture] = []
        for i in 1...3 {
            let textureName = "\(baseTexturePath)_dash_\(i)"
            dashFrames.append(SKTexture(imageNamed: textureName))
        }
        addAnimation(name: "dash", textures: dashFrames)
        
        // Healing animation
        var healFrames: [SKTexture] = []
        for i in 1...4 {
            let textureName = "\(baseTexturePath)_heal_\(i)"
            healFrames.append(SKTexture(imageNamed: textureName))
        }
        addAnimation(name: "heal", textures: healFrames)
    }
    
    /// Setup the centaur's abilities
    private func setupAbilities() {
        // Add basic bow shot ability
        let bowShotAbility = BowShotAbility()
        addAbility(bowShotAbility)
        
        // Add rear kick ability
        let rearKickAbility = RearKickAbility()
        addAbility(rearKickAbility)
        
        // Add healing touch ability if unlocked
        if GameManager.shared.hasAbility("HealingTouch") {
            let healingTouchAbility = HealingTouchAbility()
            addAbility(healingTouchAbility)
        }
        
        // Add stampede dash ability if unlocked
        if GameManager.shared.hasAbility("StampedeDash") {
            let stampedeDashAbility = StampedeDashAbility()
            addAbility(stampedeDashAbility)
        }
        
        // Add nature's bond ability if unlocked
        if GameManager.shared.hasAbility("NaturesBond") {
            let naturesBondAbility = NaturesBondAbility()
            addAbility(naturesBondAbility)
        }
    }
    
    // MARK: - Combat Methods
    
    /// Perform a bow attack toward a target point
    /// - Parameter targetPoint: The position to shoot toward
    /// - Returns: Whether the attack was successful
    func bowAttack(targetPoint: CGPoint) -> Bool {
        guard isAlive, !isStunned, bowAmmo > 0 else { return false }
        
        // Check cooldown
        let currentTime = Date().timeIntervalSince1970
        if currentTime - lastAttackTime < attackCooldown {
            return false
        }
        
        // Update last attack time
        lastAttackTime = currentTime
        
        // Decrease ammo
        bowAmmo -= 1
        
        // Play bow attack animation
        runAnimation(name: "bowAttack", repeatForever: false) {
            self.runAnimation(name: "idle", repeatForever: true)
        }
        
        // Play sound
        SoundManager.shared.playSoundEffect(filename: "bow_shot")
        
        // Create arrow projectile
        createArrow(targetPoint: targetPoint)
        
        return true
    }
    
    /// Perform a kick attack
    /// - Returns: Whether the attack was successful
    func kickAttack() -> Bool {
        guard isAlive, !isStunned else { return false }
        
        // Check cooldown
        let currentTime = Date().timeIntervalSince1970
        if currentTime - lastAttackTime < attackCooldown * 1.5 { // Kick has longer cooldown
            return false
        }
        
        // Update last attack time
        lastAttackTime = currentTime
        
        // Play kick attack animation
        runAnimation(name: "kickAttack", repeatForever: false) {
            self.runAnimation(name: "idle", repeatForever: true)
        }
        
        // Play sound
        SoundManager.shared.playSoundEffect(filename: "kick_attack")
        
        // Apply damage to enemies in range
        // This will be handled by the game scene
        
        return true
    }
    
    /// Create an arrow projectile
    /// - Parameter targetPoint: The target position for the arrow
    private func createArrow(targetPoint: CGPoint) {
        guard let sprite = sprite, let scene = sprite.scene else { return }
        
        // Create arrow sprite
        let arrowSprite = SKSpriteNode(imageNamed: "arrow")
        arrowSprite.size = CGSize(width: 40, height: 10)
        arrowSprite.position = position
        
        // Calculate direction
        let dx = targetPoint.x - position.x
        let dy = targetPoint.y - position.y
        let distance = sqrt(dx * dx + dy * dy)
        
        // Normalize direction
        let direction = CGVector(
            dx: dx / distance,
            dy: dy / distance
        )
        
        // Set arrow rotation to match direction
        let angle = atan2(direction.dy, direction.dx)
        arrowSprite.zRotation = angle
        
        // Set up physics body
        arrowSprite.physicsBody = SKPhysicsBody(rectangleOf: arrowSprite.size)
        arrowSprite.physicsBody?.isDynamic = true
        arrowSprite.physicsBody?.affectedByGravity = false
        arrowSprite.physicsBody?.categoryBitMask = 0x1 << 1 // Arrow category
        arrowSprite.physicsBody?.contactTestBitMask = 0x1 << 2 // Enemy category
        arrowSprite.physicsBody?.collisionBitMask = 0 // No collisions, just pass through
        
        // Add to scene
        scene.addChild(arrowSprite)
        
        // Apply velocity
        let arrowSpeed: CGFloat = 500.0
        let velocity = CGVector(
            dx: direction.dx * arrowSpeed,
            dy: direction.dy * arrowSpeed
        )
        
        arrowSprite.physicsBody?.velocity = velocity
        
        // Remove arrow after it travels for a while
        let travelDistance: CGFloat = 1000.0
        let travelTime = travelDistance / arrowSpeed
        
        arrowSprite.run(SKAction.sequence([
            SKAction.wait(forDuration: TimeInterval(travelTime)),
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.removeFromParent()
        ]))
        
        // Store arrow damage value
        let damage = Int(Double(self.strength) * 0.8)
        arrowSprite.userData = ["damage": damage]
    }
    
    /// Perform a dash in the current facing direction
    /// - Returns: Whether the dash was successful
    func dash() -> Bool {
        guard isAlive, !isStunned else { return false }
        
        // Check cooldown
        let currentTime = Date().timeIntervalSince1970
        if currentTime - lastDashTime < dashCooldown {
            return false
        }
        
        // Update last dash time
        lastDashTime = currentTime
        
        // Determine direction (use sprite x scale to know facing direction)
        let dashDirection = CGVector(
            dx: sprite?.xScale ?? 0 > 0 ? 1 : -1,
            dy: 0
        )
        
        // Play dash animation
        runAnimation(name: "dash", repeatForever: false) {
            self.runAnimation(name: "idle", repeatForever: true)
        }
        
        // Play sound
        SoundManager.shared.playSoundEffect(filename: "dash")
        
        // Apply dash movement
        if let sprite = sprite {
            let dashAction = SKAction.move(
                by: CGVector(dx: dashDirection.dx * dashDistance, dy: dashDirection.dy * dashDistance),
                duration: 0.3
            )
            
            // Make invulnerable during dash
            applyInvulnerability(duration: 0.4)
            
            sprite.run(dashAction)
        }
        
        return true
    }
    
    // MARK: - Inventory Methods
    
    /// Use a health potion from inventory
    /// - Returns: Whether the potion was used successfully
    func useHealthPotion() -> Bool {
        // Check if we have potions
        guard GameManager.shared.removeItemFromInventory("HealthPotion") else {
            return false
        }
        
        // Calculate healing amount (30% of max health)
        let healAmount = Int(Double(maxHealth) * 0.3)
        
        // Apply healing
        heal(amount: healAmount)
        
        // Play healing sound
        SoundManager.shared.playSoundEffect(filename: "healing")
        
        return true
    }
    
    /// Collect ammo from the environment
    /// - Parameter amount: Amount of ammo to collect
    func collectAmmo(amount: Int) {
        bowAmmo += amount
        
        if bowAmmo > maxBowAmmo {
            bowAmmo = maxBowAmmo
        }
        
        // Play collect sound
        SoundManager.shared.playSoundEffect(filename: "collect")
    }
    
    // MARK: - Level Up
    
    /// Apply level up effects
    func levelUp() {
        isLevelingUp = true
        
        // Play level up sound and animation
        SoundManager.shared.playSoundEffect(filename: "level_up")
        
        // Apply visual effect (we'll add particle effects later)
        let levelUpAction = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.3)
        ])
        
        sprite?.run(levelUpAction) {
            self.isLevelingUp = false
        }
        
        // Check GameManager for newly unlocked abilities
        setupAbilities()
    }
    
    // MARK: - Update
    
    /// Update the centaur state (called each frame)
    /// - Parameter deltaTime: Time since the last update
    override func update(deltaTime: TimeInterval) {
        super.update(deltaTime: deltaTime)
        
        // Sync with GameManager stats
        health = GameManager.shared.playerHealth
        maxHealth = GameManager.shared.playerHealth
        strength = GameManager.shared.playerStrength
        magic = GameManager.shared.playerMagic
        speed = GameManager.shared.playerSpeed
    }
    
    // MARK: - Change Appearance
    
    /// Change the centaur's appearance
    /// - Parameter appearance: The new appearance
    func changeAppearance(to appearance: CentaurAppearance) {
        centaurAppearance = appearance
        
        // Remember current animation
        let currentAnim = currentAnimation
        
        // Reload all animations with new appearance
        loadAnimations()
        
        // Resume previous animation
        if let anim = currentAnim {
            runAnimation(name: anim, repeatForever: anim == "idle" || anim == "walk")
        } else {
            runAnimation(name: "idle", repeatForever: true)
        }
    }
}
