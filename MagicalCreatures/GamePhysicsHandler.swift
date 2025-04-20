import SpriteKit

/**
 * GamePhysicsHandler
 * 
 * This class manages the physics and collision interactions between game objects,
 * particularly for combat and game mechanics. It handles:
 * - Collision detection between characters, attacks, and environment
 * - Damage calculation and application
 * - Special effects triggered by collisions
 */
class GamePhysicsHandler: NSObject, SKPhysicsContactDelegate {
    
    // Reference to the main game scene
    private weak var gameScene: GameScene?
    
    // Contact bitmasks for different entity types
    struct PhysicsCategory {
        static let none:       UInt32 = 0
        static let player:     UInt32 = 0b1         // 1
        static let enemy:      UInt32 = 0b10        // 2
        static let playerAttack: UInt32 = 0b100     // 4
        static let enemyAttack: UInt32 = 0b1000     // 8
        static let obstacle:   UInt32 = 0b10000     // 16
        static let item:       UInt32 = 0b100000    // 32
        static let boundary:   UInt32 = 0b1000000   // 64
    }
    
    /**
     * Initialize with a reference to the game scene
     */
    init(gameScene: GameScene) {
        self.gameScene = gameScene
        super.init()
    }
    
    /**
     * Configure physics world properties
     */
    func configurePhysicsWorld(_ world: SKPhysicsWorld) {
        world.gravity = CGVector(dx: 0, dy: 0) // No gravity for top-down game
        world.contactDelegate = self
    }
    
    /**
     * Set up physics body for a player character
     */
    func setupPlayerPhysics(for sprite: SKSpriteNode, characterType: String) {
        let body = SKPhysicsBody(circleOfRadius: sprite.size.width * 0.3)
        
        // Common properties
        body.isDynamic = true
        body.allowsRotation = false
        body.affectedByGravity = false
        body.restitution = 0.1
        body.friction = 0.2
        body.linearDamping = 0.7
        
        // Collision properties
        body.categoryBitMask = PhysicsCategory.player
        body.contactTestBitMask = PhysicsCategory.enemy | PhysicsCategory.enemyAttack | 
                                 PhysicsCategory.obstacle | PhysicsCategory.item
        body.collisionBitMask = PhysicsCategory.enemy | PhysicsCategory.obstacle | 
                               PhysicsCategory.boundary
        
        sprite.physicsBody = body
    }
    
    /**
     * Set up physics body for an enemy character
     */
    func setupEnemyPhysics(for sprite: SKSpriteNode, enemyType: String) {
        let body = SKPhysicsBody(circleOfRadius: sprite.size.width * 0.3)
        
        // Common properties
        body.isDynamic = true
        body.allowsRotation = false
        body.affectedByGravity = false
        body.restitution = 0.1
        body.friction = 0.2
        body.linearDamping = 0.7
        
        // Collision properties
        body.categoryBitMask = PhysicsCategory.enemy
        body.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.playerAttack
        body.collisionBitMask = PhysicsCategory.player | PhysicsCategory.enemy | 
                               PhysicsCategory.obstacle | PhysicsCategory.boundary
        
        sprite.physicsBody = body
    }
    
    /**
     * Set up physics body for an attack
     */
    func setupAttackPhysics(for sprite: SKSpriteNode, isPlayerAttack: Bool) {
        let body = SKPhysicsBody(circleOfRadius: sprite.size.width * 0.4)
        
        // Common properties
        body.isDynamic = true
        body.affectedByGravity = false
        body.mass = 0.1 // Light to prevent knocking characters too far
        
        // Set different properties based on whether it's a player or enemy attack
        if isPlayerAttack {
            body.categoryBitMask = PhysicsCategory.playerAttack
            body.contactTestBitMask = PhysicsCategory.enemy
            body.collisionBitMask = PhysicsCategory.none
        } else {
            body.categoryBitMask = PhysicsCategory.enemyAttack
            body.contactTestBitMask = PhysicsCategory.player
            body.collisionBitMask = PhysicsCategory.none
        }
        
        sprite.physicsBody = body
    }
    
    /**
     * Set up physics body for an obstacle
     */
    func setupObstaclePhysics(for sprite: SKSpriteNode) {
        // Use shape that matches the obstacle's visual shape if possible
        let body = SKPhysicsBody(rectangleOf: sprite.size)
        
        // Common properties
        body.isDynamic = false // Obstacles don't move
        body.restitution = 0.0
        body.friction = 0.5
        
        // Collision properties
        body.categoryBitMask = PhysicsCategory.obstacle
        body.contactTestBitMask = PhysicsCategory.none
        body.collisionBitMask = PhysicsCategory.player | PhysicsCategory.enemy
        
        sprite.physicsBody = body
    }
    
    /**
     * Set up physics body for a collectible item
     */
    func setupItemPhysics(for sprite: SKSpriteNode) {
        let body = SKPhysicsBody(circleOfRadius: sprite.size.width * 0.4)
        
        // Common properties
        body.isDynamic = false
        body.affectedByGravity = false
        
        // Collision properties
        body.categoryBitMask = PhysicsCategory.item
        body.contactTestBitMask = PhysicsCategory.player
        body.collisionBitMask = PhysicsCategory.none // Items don't block movement
        
        sprite.physicsBody = body
    }
    
    /**
     * Handle contact between two physics bodies
     */
    func didBegin(_ contact: SKPhysicsContact) {
        // Sort the bodies to simplify collision handling
        let collision = sortBodies(contact.bodyA, contact.bodyB)
        
        // Handle different types of collisions
        switch (collision.firstCategory, collision.secondCategory) {
            
        case (PhysicsCategory.player, PhysicsCategory.enemy):
            handlePlayerEnemyContact(collision.firstBody, collision.secondBody)
            
        case (PhysicsCategory.player, PhysicsCategory.enemyAttack):
            handlePlayerEnemyAttackContact(collision.firstBody, collision.secondBody)
            
        case (PhysicsCategory.playerAttack, PhysicsCategory.enemy):
            handlePlayerAttackEnemyContact(collision.firstBody, collision.secondBody)
            
        case (PhysicsCategory.player, PhysicsCategory.item):
            handlePlayerItemContact(collision.firstBody, collision.secondBody)
            
        default:
            break
        }
    }
    
    /**
     * Sort the physics bodies by category for easier processing
     */
    private func sortBodies(_ bodyA: SKPhysicsBody, _ bodyB: SKPhysicsBody) -> 
                        (firstBody: SKPhysicsBody, secondBody: SKPhysicsBody, 
                         firstCategory: UInt32, secondCategory: UInt32) {
        let categoryA = bodyA.categoryBitMask
        let categoryB = bodyB.categoryBitMask
        
        if categoryA < categoryB {
            return (bodyA, bodyB, categoryA, categoryB)
        } else {
            return (bodyB, bodyA, categoryB, categoryA)
        }
    }
    
    /**
     * Handle contact between player and enemy
     */
    private func handlePlayerEnemyContact(_ playerBody: SKPhysicsBody, _ enemyBody: SKPhysicsBody) {
        guard let playerNode = playerBody.node as? SKSpriteNode,
              let enemyNode = enemyBody.node as? SKSpriteNode,
              let scene = gameScene else { return }
        
        // Apply knockback to both characters
        let midPoint = CGPoint(
            x: (playerNode.position.x + enemyNode.position.x) / 2,
            y: (playerNode.position.y + enemyNode.position.y) / 2
        )
        
        // Apply knockback forces
        let playerVector = CGVector(
            dx: playerNode.position.x - midPoint.x,
            dy: playerNode.position.y - midPoint.y
        )
        
        let enemyVector = CGVector(
            dx: enemyNode.position.x - midPoint.x,
            dy: enemyNode.position.y - midPoint.y
        )
        
        playerBody.applyImpulse(playerVector)
        enemyBody.applyImpulse(enemyVector)
        
        // Notify game scene about the collision
        scene.playerCollidedWithEnemy(playerNode: playerNode, enemyNode: enemyNode)
    }
    
    /**
     * Handle contact between player and enemy attack
     */
    private func handlePlayerEnemyAttackContact(_ playerBody: SKPhysicsBody, _ attackBody: SKPhysicsBody) {
        guard let playerNode = playerBody.node as? SKSpriteNode,
              let attackNode = attackBody.node as? SKSpriteNode,
              let scene = gameScene else { return }
        
        // Get attack damage from user data if available
        let damage = attackNode.userData?["damage"] as? Int ?? 1
        
        // Apply damage to player
        scene.playerTookDamage(amount: damage, from: attackNode)
        
        // Remove the attack object
        attackNode.removeFromParent()
    }
    
    /**
     * Handle contact between player's attack and enemy
     */
    private func handlePlayerAttackEnemyContact(_ attackBody: SKPhysicsBody, _ enemyBody: SKPhysicsBody) {
        guard let attackNode = attackBody.node as? SKSpriteNode,
              let enemyNode = enemyBody.node as? SKSpriteNode,
              let scene = gameScene else { return }
        
        // Get attack damage from user data if available
        let damage = attackNode.userData?["damage"] as? Int ?? 1
        
        // Apply damage to enemy
        scene.enemyTookDamage(amount: damage, enemyNode: enemyNode, byAttack: attackNode)
        
        // Remove the attack object if it's not persistent
        if attackNode.userData?["isPersistent"] as? Bool != true {
            attackNode.removeFromParent()
        }
    }
    
    /**
     * Handle contact between player and collectible item
     */
    private func handlePlayerItemContact(_ playerBody: SKPhysicsBody, _ itemBody: SKPhysicsBody) {
        guard let playerNode = playerBody.node as? SKSpriteNode,
              let itemNode = itemBody.node as? SKSpriteNode,
              let scene = gameScene else { return }
        
        // Notify game scene about the item collection
        scene.playerCollectedItem(itemNode: itemNode)
        
        // Remove the item
        itemNode.removeFromParent()
    }
}
