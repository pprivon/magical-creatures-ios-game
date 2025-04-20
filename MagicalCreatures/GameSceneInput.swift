import SpriteKit

/**
 * GameSceneInput
 * 
 * This class handles all touch input for the game scene, including:
 * - Character movement through touch and drag
 * - Attack gestures (taps, swipes)
 * - Special ability activation through long press
 */
class GameSceneInput {
    
    // Reference to the main game scene
    private weak var gameScene: GameScene?
    
    // Properties to track touch state
    private var initialTouchPosition: CGPoint?
    private var lastTouchPosition: CGPoint?
    private var touchStartTime: TimeInterval = 0
    private var isTouching = false
    private var isDragging = false
    
    // Constants for input detection
    private let dragThreshold: CGFloat = 10.0
    private let longPressThreshold: TimeInterval = 0.5
    private let swipeMinVelocity: CGFloat = 500.0
    private let tapMaxDuration: TimeInterval = 0.2
    
    /**
     * Initialize with a reference to the game scene
     */
    init(gameScene: GameScene) {
        self.gameScene = gameScene
    }
    
    /**
     * Process touch began events
     */
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let scene = gameScene else { return }
        
        // Reset touch state
        isTouching = true
        isDragging = false
        
        // Record initial touch data
        initialTouchPosition = touch.location(in: scene)
        lastTouchPosition = initialTouchPosition
        touchStartTime = scene.lastUpdateTime
        
        // Check if touch is on UI element first
        if let touchedNode = scene.nodes(at: initialTouchPosition!).first(where: { $0.name?.hasPrefix("ui_") ?? false }) {
            handleUITouch(touchedNode)
            return
        }
    }
    
    /**
     * Process touch moved events
     */
    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let scene = gameScene,
              let initialPosition = initialTouchPosition else { return }
        
        let currentPosition = touch.location(in: scene)
        lastTouchPosition = currentPosition
        
        // Check if we're now dragging
        if !isDragging {
            let dragDistance = distance(from: initialPosition, to: currentPosition)
            if dragDistance > dragThreshold {
                isDragging = true
            }
        }
        
        // Handle dragging for character movement
        if isDragging {
            scene.movePlayerCharacter(to: currentPosition)
        }
    }
    
    /**
     * Process touch ended events
     */
    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let scene = gameScene,
              let initialPosition = initialTouchPosition,
              let lastPosition = lastTouchPosition else {
            resetTouchState()
            return
        }
        
        let currentPosition = touch.location(in: scene)
        let touchDuration = scene.lastUpdateTime - touchStartTime
        
        // Detect type of gesture
        if !isDragging && touchDuration < tapMaxDuration {
            // This was a tap/quick press - trigger attack
            scene.playerAttack()
        } else if isDragging {
            // This was a drag - check if it's a swipe
            let dragVelocity = distance(from: initialPosition, to: currentPosition) / CGFloat(touchDuration)
            
            if dragVelocity > swipeMinVelocity {
                // This was a swipe - trigger special attack
                let angle = angleFrom(initialPosition, to: currentPosition)
                scene.playerSpecialAttack(direction: angle)
            }
        } else if touchDuration >= longPressThreshold {
            // This was a long press - trigger special ability
            scene.playerActivateSpecialAbility()
        }
        
        resetTouchState()
    }
    
    /**
     * Process touch cancelled events
     */
    func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetTouchState()
    }
    
    /**
     * Reset the touch tracking state
     */
    private func resetTouchState() {
        initialTouchPosition = nil
        lastTouchPosition = nil
        isTouching = false
        isDragging = false
    }
    
    /**
     * Calculate distance between two points
     */
    private func distance(from point1: CGPoint, to point2: CGPoint) -> CGFloat {
        return sqrt(pow(point2.x - point1.x, 2) + pow(point2.y - point1.y, 2))
    }
    
    /**
     * Calculate angle between two points (in radians)
     */
    private func angleFrom(_ startPoint: CGPoint, to endPoint: CGPoint) -> CGFloat {
        return atan2(endPoint.y - startPoint.y, endPoint.x - startPoint.x)
    }
    
    /**
     * Handle touches on UI elements
     */
    private func handleUITouch(_ node: SKNode) {
        guard let nodeName = node.name, let scene = gameScene else { return }
        
        switch nodeName {
        case "ui_pause_button":
            scene.pauseGame()
        case "ui_special_button":
            scene.playerActivateSpecialAbility()
        default:
            if nodeName.hasPrefix("ui_") {
                // Pass to the scene for custom UI handling
                scene.handleUIElementTouch(nodeName)
            }
        }
    }
}
