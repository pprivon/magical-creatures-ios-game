import Foundation
import SpriteKit

/// The Enemy class represents the opponents that the player must defeat
class Enemy: Character {
    // MARK: - Properties
    
    // Enemy-specific properties
    var enemyType: EnemyType
    var difficultyMultiplier: Double = 1.0
    var patrolPath: [CGPoint] = []
    var currentPatrolIndex: Int = 0
    var isAggressive: Bool = false
    var aggroRange: CGFloat = 200.0
    var attackRange: CGFloat = 50.0
    var detectionAngle: CGFloat = .pi / 2 // 90 degrees
    var sightRange: CGFloat = 250.0
    var isPatrolling: Bool = true
    
    // AI state
    enum AIState {
        case idle
        case patrolling
        case chasing
        case attacking
        case searching
        case fleeing
    }
    
    var currentState: AIState = .idle
    weak var target: Character?
    var lastKnownTargetPosition: CGPoint?
    var stateTime: TimeInterval = 0
    
    // MARK: - Initialization
    
    /// Initialize an enemy with the specified type and difficulty
    /// - Parameters:
    ///   - type: The enemy type
    ///   - difficulty: Difficulty multiplier (affects stats)
    init(type: EnemyType, difficulty: Double = 1.0) {
        self.enemyType = type
        self.difficultyMultiplier = difficulty
        
        // Initialize with base stats for the enemy type, adjusted by difficulty
        super.init(
            name: "Enemy \(type.rawValue.capitalized)",
            health: Int(Double(type.baseHealth) * difficulty),
            strength: Int(Double(type.baseStrength) * difficulty),
            magic: Int(Double(type.baseMagic) * difficulty),
            speed: Int(Double(type.baseSpeed) * sqrt(difficulty)) // Scale speed less aggressively
        )
        
        // Setup AI behavior based on enemy type
        setupBehavior()
    }
    
    // MARK: - Setup
    
    /// Load the enemy's sprite and animations
    /// - Parameter scene: The SKScene to add the sprite to
    func load(in scene: SKScene) {
        // Load base texture
        let baseTexture = SKTexture(imageNamed: enemyType.textureName + "_idle_1")
        
        // Create sprite with appropriate size
        let spriteSize: CGSize
        
        switch enemyType {
        case .shadowScout:
            spriteSize = CGSize(width: 150, height: 150)
        case .cageMaster:
            spriteSize = CGSize(width: 170, height: 170)
        case .darkKnight:
            spriteSize = CGSize(width: 180, height: 180)
        case .shadowMage:
            spriteSize = CGSize(width: 160, height: 160)
        case .lordObsidian:
            spriteSize = CGSize(width: 220, height: 220)
        }
        
        setupSprite(texture: baseTexture, size: spriteSize)
        
        // Add to scene
        if let sprite = sprite {
            scene.addChild(sprite)
        }
        
        // Load animations
        loadAnimations()
        
        // Set idle animation by default
        runAnimation(name: "idle", repeatForever: true)
    }
    
    /// Load all animations for the enemy
    private func loadAnimations() {
        // Define animation sequences (we'll add actual textures later)
        let baseTexturePath = enemyType.textureName
        
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
        
        // Attack animation
        var attackFrames: [SKTexture] = []
        for i in 1...5 {
            let textureName = "\(baseTexturePath)_attack_\(i)"
            attackFrames.append(SKTexture(imageNamed: textureName))
        }
        addAnimation(name: "attack", textures: attackFrames)
        
        // Hit animation
        var hitFrames: [SKTexture] = []
        for i in 1...2 {
            let textureName = "\(baseTexturePath)_hit_\(i)"
            hitFrames.append(SKTexture(imageNamed: textureName))
        }
        addAnimation(name: "hit", textures: hitFrames)
        
        // Defeat animation
        var defeatFrames: [SKTexture] = []
        for i in 1...4 {
            let textureName = "\(baseTexturePath)_defeat_\(i)"
            defeatFrames.append(SKTexture(imageNamed: textureName))
        }
        addAnimation(name: "defeat", textures: defeatFrames)
        
        // Load special animations based on enemy type
        if enemyType == .shadowMage || enemyType == .lordObsidian {
            // Magic attack animation
            var magicFrames: [SKTexture] = []
            for i in 1...5 {
                let textureName = "\(baseTexturePath)_magic_\(i)"
                magicFrames.append(SKTexture(imageNamed: textureName))
            }
            addAnimation(name: "magicAttack", textures: magicFrames)
        }
        
        if enemyType == .darkKnight {
            // Shield block animation
            var blockFrames: [SKTexture] = []
            for i in 1...3 {
                let textureName = "\(baseTexturePath)_block_\(i)"
                blockFrames.append(SKTexture(imageNamed: textureName))
            }
            addAnimation(name: "block", textures: blockFrames)
        }
    }
    
    /// Set up AI behavior based on enemy type
    private func setupBehavior() {
        switch enemyType {
        case .shadowScout:
            isPatrolling = true
            aggroRange = 250.0
            sightRange = 300.0
            detectionAngle = .pi / 3 // 60 degrees
            attackRange = 40.0
        case .cageMaster:
            isPatrolling = true
            aggroRange = 200.0
            sightRange = 250.0
            detectionAngle = .pi / 4 // 45 degrees
            attackRange = 60.0
            // Cage masters use nets with wider range
        case .darkKnight:
            isPatrolling = true
            aggroRange = 200.0
            sightRange = 250.0
            detectionAngle = .pi / 4 // 45 degrees
            attackRange = 70.0
            // Dark knights are slower but have longer range with weapons
        case .shadowMage:
            isPatrolling = false
            isAggressive = true
            aggroRange = 400.0
            sightRange = 450.0
            detectionAngle = .pi / 2 // 90 degrees
            attackRange = 350.0
            // Shadow mages have long-range attacks
        case .lordObsidian:
            isPatrolling = false
            isAggressive = true
            aggroRange = 500.0
            sightRange = 600.0
            detectionAngle = .pi * 2 // 360 degrees - can see everywhere
            attackRange = 300.0
            // Boss has best detection and range
        }
    }
    
    /// Set up a patrol path for the enemy
    /// - Parameter points: Array of points forming the patrol path
    func setPatrolPath(_ points: [CGPoint]) {
        patrolPath = points
        
        if !patrolPath.isEmpty {
            isPatrolling = true
            currentState = .patrolling
        }
    }
    
    // MARK: - AI Methods
    
    /// Check if the enemy can see the target
    /// - Parameter target: The target character to check
    /// - Returns: Whether the target is visible
    func canSeeTarget(_ target: Character) -> Bool {
        guard let targetSprite = target.sprite, let enemySprite = sprite else { return false }
        
        // Check if target is within sight range
        let distanceToTarget = distance(to: target)
        if distanceToTarget > sightRange {
            return false
        }
        
        // Check if target is within detection angle
        let directionToTarget = CGVector(
            dx: targetSprite.position.x - enemySprite.position.x,
            dy: targetSprite.position.y - enemySprite.position.y
        )
        
        // Get enemy's forward direction (based on sprite's x scale)
        let enemyDirection = CGVector(
            dx: enemySprite.xScale > 0 ? 1 : -1,
            dy: 0
        )
        
        // Calculate angle between enemy direction and target direction
        let angleToTarget = angleBetween(vectorA: enemyDirection, vectorB: directionToTarget)
        
        // Check if target is within detection angle
        if angleToTarget > detectionAngle / 2 {
            return false
        }
        
        // TODO: Implement line of sight check using physics raycasting
        // For now, assume no obstacles
        
        return true
    }
    
    /// Calculate the distance to another character
    /// - Parameter character: The other character
    /// - Returns: The distance in points
    func distance(to character: Character) -> CGFloat {
        let dx = character.position.x - position.x
        let dy = character.position.y - position.y
        return sqrt(dx * dx + dy * dy)
    }
    
    /// Calculate the angle between two vectors
    /// - Parameters:
    ///   - vectorA: First vector
    ///   - vectorB: Second vector
    /// - Returns: Angle in radians
    private func angleBetween(vectorA: CGVector, vectorB: CGVector) -> CGFloat {
        // Normalize vectors
        let lengthA = sqrt(vectorA.dx * vectorA.dx + vectorA.dy * vectorA.dy)
        let lengthB = sqrt(vectorB.dx * vectorB.dx + vectorB.dy * vectorB.dy)
        
        guard lengthA > 0 && lengthB > 0 else { return .pi }
        
        let normalizedA = CGVector(dx: vectorA.dx / lengthA, dy: vectorA.dy / lengthA)
        let normalizedB = CGVector(dx: vectorB.dx / lengthB, dy: vectorB.dy / lengthB)
        
        // Calculate dot product
        let dotProduct = normalizedA.dx * normalizedB.dx + normalizedA.dy * normalizedB.dy
        
        // Handle floating point errors
        let clampedDotProduct = min(max(dotProduct, -1.0), 1.0)
        
        // Return angle in radians
        return acos(clampedDotProduct)
    }
    
    // The rest of the AI methods (update, state handling) and combat methods are in EnemyAI.swift and EnemyCombat.swift
}
