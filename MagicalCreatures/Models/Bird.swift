import Foundation
import SpriteKit

/// The Bird class represents the player's companion character
class Bird: Character {
    // MARK: - Properties
    
    // Bird state
    private let orbitDistance: CGFloat = 80.0
    private let orbitSpeed: CGFloat = 1.0
    private var orbitAngle: CGFloat = 0.0
    private var isPerchingOnShoulder: Bool = true
    
    // Target to follow (usually the centaur)
    weak var followTarget: Character?
    
    // Special abilities
    var canSpotHiddenItems: Bool = true
    var canWarnOfDanger: Bool = true
    
    // Customization
    var birdType: BirdType = .blue
    
    // MARK: - Enums
    
    enum BirdType: String {
        case blue = "blue"
        case red = "red"
        case yellow = "yellow"
        
        var textureName: String {
            switch self {
            case .blue: return "bird_blue"
            case .red: return "bird_red"
            case .yellow: return "bird_yellow"
            }
        }
    }
    
    // MARK: - Initialization
    
    /// Initialize the bird character with default attributes
    init(birdType: BirdType = .blue) {
        self.birdType = birdType
        
        // Initialize with bird stats
        super.init(
            name: "Pip",
            health: 10,
            strength: 1,
            magic: 5,
            speed: 10
        )
    }
    
    // MARK: - Setup
    
    /// Load the bird's sprite and animations
    /// - Parameters:
    ///   - scene: The SKScene to add the sprite to
    ///   - followTarget: The character for the bird to follow
    func load(in scene: SKScene, followTarget: Character? = nil) {
        // Set follow target
        self.followTarget = followTarget
        
        // Load base texture
        let baseTexture = SKTexture(imageNamed: birdType.textureName + "_idle_1")
        
        // Create sprite with appropriate size
        setupSprite(texture: baseTexture, size: CGSize(width: 50, height: 50))
        
        // Set initial position (based on follow target if available)
        if let target = followTarget {
            position = CGPoint(
                x: target.position.x + 30,
                y: target.position.y + 50
            )
        } else {
            position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2 + 100)
        }
        
        // Add to scene
        if let sprite = sprite {
            scene.addChild(sprite)
        }
        
        // Load animations
        loadAnimations()
        
        // Set idle animation by default
        runAnimation(name: "idle", repeatForever: true)
    }
    
    /// Load all animations for the bird
    private func loadAnimations() {
        // Define animation sequences (we'll add actual textures later)
        // These would typically be loaded from sprite sheets
        let baseTexturePath = birdType.textureName
        
        // Idle animation (hovering in place)
        var idleFrames: [SKTexture] = []
        for i in 1...4 {
            let textureName = "\(baseTexturePath)_idle_\(i)"
            idleFrames.append(SKTexture(imageNamed: textureName))
        }
        addAnimation(name: "idle", textures: idleFrames)
        
        // Flying animation
        var flyFrames: [SKTexture] = []
        for i in 1...6 {
            let textureName = "\(baseTexturePath)_fly_\(i)"
            flyFrames.append(SKTexture(imageNamed: textureName))
        }
        addAnimation(name: "fly", textures: flyFrames)
        
        // Perching animation
        var perchFrames: [SKTexture] = []
        for i in 1...2 {
            let textureName = "\(baseTexturePath)_perch_\(i)"
            perchFrames.append(SKTexture(imageNamed: textureName))
        }
        addAnimation(name: "perch", textures: perchFrames)
        
        // Chirping animation
        var chirpFrames: [SKTexture] = []
        for i in 1...3 {
            let textureName = "\(baseTexturePath)_chirp_\(i)"
            chirpFrames.append(SKTexture(imageNamed: textureName))
        }
        addAnimation(name: "chirp", textures: chirpFrames)
    }
    
    // MARK: - Movement Methods
    
    /// Toggle whether the bird is perching on the centaur's shoulder
    func togglePerching() {
        isPerchingOnShoulder = !isPerchingOnShoulder
        
        if isPerchingOnShoulder {
            // Switch to perching animation
            runAnimation(name: "perch", repeatForever: true)
        } else {
            // Switch to flying animation
            runAnimation(name: "fly", repeatForever: true)
        }
    }
    
    /// Update the bird's position to follow its target
    /// - Parameter deltaTime: Time since the last update
    override func update(deltaTime: TimeInterval) {
        super.update(deltaTime: deltaTime)
        
        guard let target = followTarget, target.isAlive else { return }
        
        if isPerchingOnShoulder {
            // Position on the centaur's shoulder
            let shoulderOffset = CGPoint(
                x: target.sprite?.xScale ?? 0 > 0 ? 30 : -30, // Adjust based on facing direction
                y: 50
            )
            
            position = CGPoint(
                x: target.position.x + shoulderOffset.x,
                y: target.position.y + shoulderOffset.y
            )
        } else {
            // Orbit around the centaur
            orbitAngle += orbitSpeed * CGFloat(deltaTime)
            
            // Normalize angle
            if orbitAngle > 2 * .pi {
                orbitAngle -= 2 * .pi
            }
            
            // Calculate position in orbit
            let xPos = target.position.x + cos(orbitAngle) * orbitDistance
            let yPos = target.position.y + sin(orbitAngle) * orbitDistance
            
            // Smooth movement to the new position
            let lerpFactor: CGFloat = 0.1
            let newPos = CGPoint(
                x: position.x + (xPos - position.x) * lerpFactor,
                y: position.y + (yPos - position.y) * lerpFactor
            )
            
            position = newPos
            
            // Update facing direction
            if let sprite = sprite {
                sprite.xScale = (position.x < target.position.x) ? -abs(sprite.xScale) : abs(sprite.xScale)
            }
        }
    }
    
    // MARK: - Bird Functions
    
    /// Make the bird chirp (play chirping animation and sound)
    /// - Parameter text: Optional text to show as a speech bubble
    func chirp(text: String? = nil) {
        // Play chirp animation
        runAnimation(name: "chirp", repeatForever: false) {
            self.runAnimation(name: self.isPerchingOnShoulder ? "perch" : "fly", repeatForever: true)
        }
        
        // Play chirp sound
        SoundManager.shared.playSoundEffect(filename: "bird_chirp")
        
        // Show speech bubble if text is provided
        if let text = text, let sprite = sprite, let scene = sprite.scene {
            // Create speech bubble
            let bubble = createSpeechBubble(text: text, width: 200, height: 100)
            
            // Position above bird
            bubble.position = CGPoint(x: 0, y: sprite.size.height * 0.75)
            
            // Add to bird (so it moves with the bird)
            sprite.addChild(bubble)
            
            // Remove after delay
            bubble.run(SKAction.sequence([
                SKAction.wait(forDuration: 3.0),
                SKAction.fadeOut(withDuration: 0.3),
                SKAction.removeFromParent()
            ]))
        }
    }
    
    /// Create a speech bubble with text
    /// - Parameters:
    ///   - text: The text to display
    ///   - width: Width of the bubble
    ///   - height: Height of the bubble
    /// - Returns: An SKNode containing the speech bubble
    private func createSpeechBubble(text: String, width: CGFloat, height: CGFloat) -> SKNode {
        // Create container node
        let container = SKNode()
        
        // Create bubble background
        let bubbleBackground = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 15)
        bubbleBackground.fillColor = .white
        bubbleBackground.strokeColor = .black
        bubbleBackground.lineWidth = 2
        container.addChild(bubbleBackground)
        
        // Create text node
        let textNode = SKLabelNode(fontNamed: "Chalkduster")
        textNode.text = text
        textNode.fontSize = 14
        textNode.fontColor = .black
        textNode.numberOfLines = 0
        textNode.preferredMaxLayoutWidth = width - 20
        textNode.position = CGPoint(x: 0, y: -height / 4)
        textNode.verticalAlignmentMode = .center
        textNode.horizontalAlignmentMode = .center
        container.addChild(textNode)
        
        // Create tail of speech bubble
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: -height / 2))
        path.addLine(to: CGPoint(x: -10, y: -height / 2 - 15))
        path.addLine(to: CGPoint(x: 10, y: -height / 2 - 5))
        path.closeSubpath()
        
        let tail = SKShapeNode(path: path)
        tail.fillColor = .white
        tail.strokeColor = .black
        tail.lineWidth = 2
        container.addChild(tail)
        
        return container
    }
    
    /// Check for hidden items in the area
    /// - Parameter scene: The current game scene
    /// - Returns: Array of positions where hidden items are located
    func spotHiddenItems(in scene: SKScene) -> [CGPoint] {
        guard canSpotHiddenItems else { return [] }
        
        // In a real implementation, we would check the scene for
        // nodes tagged as "hidden" and return their positions
        // For now, we'll just return an empty array
        return []
    }
    
    /// Warn of nearby danger
    /// - Parameter scene: The current game scene
    /// - Returns: Whether a warning was triggered
    func warnOfDanger(in scene: SKScene) -> Bool {
        guard canWarnOfDanger else { return false }
        
        // Check for enemies within a certain radius of the follow target
        let dangerRadius: CGFloat = 300.0
        var dangerDetected = false
        
        // In a real implementation, we would check for enemy nodes
        // For now, just return false
        if dangerDetected {
            // Play warning sound
            SoundManager.shared.playSoundEffect(filename: "bird_warning")
            
            // Show warning chirp
            chirp(text: "Be careful! Enemies nearby!")
            
            return true
        }
        
        return false
    }
    
    /// Guide the player toward an objective
    /// - Parameter targetPosition: The position to guide toward
    func guideToward(targetPosition: CGPoint) {
        // Temporarily fly toward the target position
        isPerchingOnShoulder = false
        runAnimation(name: "fly", repeatForever: true)
        
        // Create a movement sequence
        guard let sprite = sprite else { return }
        
        // First move to halfway between current position and target
        let halfwayPoint = CGPoint(
            x: (position.x + targetPosition.x) / 2,
            y: (position.y + targetPosition.y) / 2 + 50 // Arc upward
        )
        
        // Create the movement sequence
        let moveAction = SKAction.sequence([
            SKAction.move(to: halfwayPoint, duration: 1.0),
            SKAction.move(to: targetPosition, duration: 1.0),
            SKAction.wait(forDuration: 1.0),
            SKAction.run { [weak self] in
                // Chirp when reaching the destination
                self?.chirp(text: "This way!")
            },
            SKAction.wait(forDuration: 2.0),
            SKAction.run { [weak self] in
                // Return to perching after guiding
                self?.isPerchingOnShoulder = true
                self?.runAnimation(name: "perch", repeatForever: true)
            }
        ])
        
        sprite.run(moveAction, withKey: "guiding")
    }
}
