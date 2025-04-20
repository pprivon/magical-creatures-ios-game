import Foundation
import SpriteKit

/// Base Character class that defines common properties and methods for all game characters
class Character {
    // MARK: - Properties
    
    // Character attributes
    var name: String
    var health: Int
    var maxHealth: Int
    var strength: Int
    var magic: Int
    var speed: Int
    var level: Int = 1
    
    // Character state
    var isAlive: Bool {
        return health > 0
    }
    var isStunned: Bool = false
    var isInvulnerable: Bool = false
    
    // Visual representation
    var sprite: SKSpriteNode?
    var animations: [String: [SKTexture]] = [:]
    var currentAnimation: String?
    
    // Position
    var position: CGPoint {
        get { return sprite?.position ?? .zero }
        set { sprite?.position = newValue }
    }
    
    // Combat
    var attackRange: CGFloat = 100.0
    var detectionRange: CGFloat = 200.0
    var lastAttackTime: TimeInterval = 0
    var attackCooldown: TimeInterval = 1.0
    
    // Abilities
    var abilities: [Ability] = []
    
    // MARK: - Initialization
    
    /// Initialize a character with basic attributes
    /// - Parameters:
    ///   - name: Character name
    ///   - health: Initial health points
    ///   - strength: Strength attribute
    ///   - magic: Magic attribute
    ///   - speed: Speed attribute
    init(name: String, health: Int, strength: Int, magic: Int, speed: Int) {
        self.name = name
        self.health = health
        self.maxHealth = health
        self.strength = strength
        self.magic = magic
        self.speed = speed
    }
    
    // MARK: - Setup Methods
    
    /// Set up the character's sprite and animations
    /// - Parameters:
    ///   - texture: Base texture for the sprite
    ///   - size: Size for the sprite
    func setupSprite(texture: SKTexture, size: CGSize) {
        sprite = SKSpriteNode(texture: texture, size: size)
        setupPhysics()
    }
    
    /// Set up the sprite's physics body
    func setupPhysics() {
        guard let sprite = sprite else { return }
        
        // Create a smaller physics body than the visual sprite for better collision detection
        let physicsBodySize = CGSize(
            width: sprite.size.width * 0.7,
            height: sprite.size.height * 0.7
        )
        
        sprite.physicsBody = SKPhysicsBody(rectangleOf: physicsBodySize)
        sprite.physicsBody?.isDynamic = true
        sprite.physicsBody?.allowsRotation = false
        sprite.physicsBody?.restitution = 0.0
        
        // Physics categories will be defined in a separate file
        // We'll configure them when we implement the physics system
    }
    
    /// Add an animation sequence for the character
    /// - Parameters:
    ///   - name: Animation name (e.g., "walk", "attack")
    ///   - textures: Array of textures for the animation frames
    func addAnimation(name: String, textures: [SKTexture]) {
        animations[name] = textures
    }
    
    /// Run a specific animation
    /// - Parameters:
    ///   - name: Name of the animation to run
    ///   - repeatForever: Whether to loop the animation
    ///   - completion: Optional callback when animation completes
    func runAnimation(name: String, repeatForever: Bool = false, completion: (() -> Void)? = nil) {
        guard let sprite = sprite, let textures = animations[name], !textures.isEmpty else {
            print("Animation not found: \(name)")
            return
        }
        
        // Stop any current animation
        sprite.removeAllActions()
        
        // Create the animation action
        let timePerFrame: TimeInterval = 0.1
        let animateAction = SKAction.animate(with: textures, timePerFrame: timePerFrame)
        
        var action: SKAction
        
        if repeatForever {
            action = SKAction.repeatForever(animateAction)
        } else {
            action = animateAction
        }
        
        // Run the animation
        if let completion = completion {
            let sequenceAction = SKAction.sequence([action, SKAction.run(completion)])
            sprite.run(sequenceAction, withKey: name)
        } else {
            sprite.run(action, withKey: name)
        }
        
        currentAnimation = name
    }
    
    /// Stop the current animation
    func stopAnimation() {
        sprite?.removeAllActions()
        currentAnimation = nil
    }
    
    // MARK: - Movement Methods
    
    /// Move the character in a direction
    /// - Parameters:
    ///   - direction: Direction vector (normalized)
    ///   - deltaTime: Time since last frame for smooth movement
    func move(direction: CGVector, deltaTime: TimeInterval) {
        guard let sprite = sprite, isAlive, !isStunned else { return }
        
        // Calculate movement distance based on speed and time
        let distance = CGFloat(speed) * 50.0 * CGFloat(deltaTime)
        let movement = CGVector(
            dx: direction.dx * distance,
            dy: direction.dy * distance
        )
        
        // Update position
        let newPosition = CGPoint(
            x: sprite.position.x + movement.dx,
            y: sprite.position.y + movement.dy
        )
        
        sprite.position = newPosition
        
        // Update facing direction based on movement
        if movement.dx != 0 {
            sprite.xScale = movement.dx < 0 ? -abs(sprite.xScale) : abs(sprite.xScale)
        }
        
        // Play walking animation if we're moving and not already animating a walk
        if (movement.dx != 0 || movement.dy != 0) && currentAnimation != "walk" {
            runAnimation(name: "walk", repeatForever: true)
        } else if movement.dx == 0 && movement.dy == 0 && currentAnimation == "walk" {
            runAnimation(name: "idle", repeatForever: true)
        }
    }
    
    /// Move the character toward a target position
    /// - Parameters:
    ///   - target: Target position
    ///   - deltaTime: Time since last frame
    func moveToward(target: CGPoint, deltaTime: TimeInterval) {
        guard let sprite = sprite else { return }
        
        // Calculate direction
        let dx = target.x - sprite.position.x
        let dy = target.y - sprite.position.y
        let distance = sqrt(dx * dx + dy * dy)
        
        // If we're already very close, don't bother moving
        if distance < 5.0 {
            if currentAnimation == "walk" {
                runAnimation(name: "idle", repeatForever: true)
            }
            return
        }
        
        // Normalize direction
        let direction = CGVector(
            dx: dx / distance,
            dy: dy / distance
        )
        
        // Move in that direction
        move(direction: direction, deltaTime: deltaTime)
    }
    
    // MARK: - Combat Methods
    
    /// Perform a basic attack
    /// - Parameter target: The character to attack
    /// - Returns: The damage dealt, or 0 if the attack failed
    func attack(target: Character) -> Int {
        guard isAlive, !isStunned else { return 0 }
        
        // Check if enough time has passed since last attack
        let currentTime = Date().timeIntervalSince1970
        if currentTime - lastAttackTime < attackCooldown {
            return 0
        }
        
        // Update last attack time
        lastAttackTime = currentTime
        
        // Play attack animation
        runAnimation(name: "attack", repeatForever: false) {
            // Reset to idle after attack
            self.runAnimation(name: "idle", repeatForever: true)
        }
        
        // Apply strength to determine damage (with some randomness)
        let baseDamage = strength
        let randomFactor = Double.random(in: 0.8...1.2)
        let damage = Int(Double(baseDamage) * randomFactor)
        
        // Apply damage to target
        target.takeDamage(amount: damage)
        
        return damage
    }
    
    /// Take damage from an attack
    /// - Parameter amount: The amount of damage to take
    /// - Returns: The actual damage taken (may be reduced by defense)
    func takeDamage(amount: Int) -> Int {
        guard isAlive, !isInvulnerable else { return 0 }
        
        // Apply damage
        health -= amount
        
        // Ensure health doesn't go below 0
        if health < 0 {
            health = 0
        }
        
        // Play hit animation
        runAnimation(name: "hit", repeatForever: false) {
            if self.isAlive {
                self.runAnimation(name: "idle", repeatForever: true)
            } else {
                self.runAnimation(name: "defeat", repeatForever: false)
            }
        }
        
        return amount
    }
    
    /// Heal the character
    /// - Parameter amount: The amount of health to restore
    func heal(amount: Int) {
        guard isAlive else { return }
        
        health += amount
        
        // Ensure health doesn't exceed maximum
        if health > maxHealth {
            health = maxHealth
        }
        
        // Play heal animation if available
        if animations["heal"] != nil {
            runAnimation(name: "heal", repeatForever: false) {
                self.runAnimation(name: "idle", repeatForever: true)
            }
        }
    }
    
    // MARK: - Ability Methods
    
    /// Use an ability by name
    /// - Parameters:
    ///   - abilityName: The name of the ability to use
    ///   - target: Optional target for the ability
    /// - Returns: Whether the ability was successfully used
    func useAbility(abilityName: String, target: Character? = nil) -> Bool {
        guard let ability = abilities.first(where: { $0.name == abilityName }),
              ability.canUse(character: self) else {
            return false
        }
        
        // Use the ability
        return ability.use(character: self, target: target)
    }
    
    /// Add a new ability to the character
    /// - Parameter ability: The ability to add
    func addAbility(_ ability: Ability) {
        // Don't add duplicate abilities
        if !abilities.contains(where: { $0.name == ability.name }) {
            abilities.append(ability)
        }
    }
    
    // MARK: - Character Status
    
    /// Apply a stun effect to the character
    /// - Parameter duration: Duration of the stun in seconds
    func applyStun(duration: TimeInterval) {
        isStunned = true
        
        // Create a timer to remove the stun after the duration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.isStunned = false
        }
    }
    
    /// Apply temporary invulnerability
    /// - Parameter duration: Duration of invulnerability in seconds
    func applyInvulnerability(duration: TimeInterval) {
        isInvulnerable = true
        
        // Make sprite semi-transparent to indicate invulnerability
        sprite?.alpha = 0.7
        
        // Create a timer to remove invulnerability after the duration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.isInvulnerable = false
            self?.sprite?.alpha = 1.0
        }
    }
    
    // MARK: - Update
    
    /// Update the character state (called each frame)
    /// - Parameter deltaTime: Time since the last update
    func update(deltaTime: TimeInterval) {
        // Base character class doesn't do much in update
        // This will be overridden by subclasses for AI behaviors
    }
}

/// Ability class representing special actions characters can perform
class Ability {
    // MARK: - Properties
    
    var name: String
    var cooldown: TimeInterval
    var manaCost: Int
    var lastUsedTime: TimeInterval = 0
    
    // MARK: - Initialization
    
    init(name: String, cooldown: TimeInterval, manaCost: Int) {
        self.name = name
        self.cooldown = cooldown
        self.manaCost = manaCost
    }
    
    // MARK: - Methods
    
    /// Check if the ability can be used
    /// - Parameter character: The character attempting to use the ability
    /// - Returns: Whether the ability can be used
    func canUse(character: Character) -> Bool {
        // Check cooldown
        let currentTime = Date().timeIntervalSince1970
        if currentTime - lastUsedTime < cooldown {
            return false
        }
        
        // Check if character has enough magic/mana
        if character.magic < manaCost {
            return false
        }
        
        // Check if character is able to use abilities
        if !character.isAlive || character.isStunned {
            return false
        }
        
        return true
    }
    
    /// Use the ability
    /// - Parameters:
    ///   - character: The character using the ability
    ///   - target: Optional target for the ability
    /// - Returns: Whether the ability was successfully used
    func use(character: Character, target: Character? = nil) -> Bool {
        guard canUse(character: character) else {
            return false
        }
        
        // Mark as used and start cooldown
        lastUsedTime = Date().timeIntervalSince1970
        
        // Base class doesn't implement specific ability effects
        // Subclasses will override this method to implement actual effects
        
        return true
    }
    
    /// Get the remaining cooldown time
    /// - Returns: Seconds remaining until the ability can be used again, or 0 if ready
    func remainingCooldown() -> TimeInterval {
        let currentTime = Date().timeIntervalSince1970
        let elapsed = currentTime - lastUsedTime
        
        if elapsed >= cooldown {
            return 0
        } else {
            return cooldown - elapsed
        }
    }
}
