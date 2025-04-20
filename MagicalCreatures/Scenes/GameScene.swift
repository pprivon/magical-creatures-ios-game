import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    // MARK: - Properties
    
    // Player character
    var centaur: Centaur?
    var bird: Bird?
    
    // Game state
    var currentLevel: Int = 1
    var isGamePaused: Bool = false
    
    // Camera
    var gameCamera: SKCameraNode?
    
    // UI Elements
    var healthBar: SKSpriteNode?
    var ammoDisplay: SKLabelNode?
    var scoreLabel: SKLabelNode?
    var pauseButton: SKSpriteNode?
    
    // Touch handling
    var lastTouchPosition: CGPoint?
    var joystickNode: SKNode?
    var joystickKnob: SKNode?
    var isJoystickActive = false
    var joystickRange: CGFloat = 50.0
    
    // Game elements
    var enemies: [Enemy] = []
    var items: [SKNode] = []
    var animalCages: [SKNode] = []
    
    // Physics categories
    struct PhysicsCategory {
        static let none:   UInt32 = 0
        static let player: UInt32 = 0x1 << 0
        static let enemy:  UInt32 = 0x1 << 1
        static let arrow:  UInt32 = 0x1 << 2
        static let magic:  UInt32 = 0x1 << 3
        static let item:   UInt32 = 0x1 << 4
        static let cage:   UInt32 = 0x1 << 5
        static let wall:   UInt32 = 0x1 << 6
    }
    
    // MARK: - Scene Lifecycle
    
    override func didMove(to view: SKView) {
        // Set up the scene
        setupPhysics()
        setupCamera()
        setupUI()
        setupControls()
        
        // Load level
        loadLevel(level: currentLevel)
        
        // Start background music
        SoundManager.shared.playBackgroundMusic(filename: "game_background")
    }
    
    // MARK: - Setup Methods
    
    /// Set up the physics world
    private func setupPhysics() {
        // Set up physics world properties
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        // Add boundary walls
        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        borderBody.friction = 0
        borderBody.restitution = 0
        borderBody.categoryBitMask = PhysicsCategory.wall
        
        self.physicsBody = borderBody
    }
    
    /// Set up the camera
    private func setupCamera() {
        // Create camera node
        gameCamera = SKCameraNode()
        if let camera = gameCamera {
            addChild(camera)
            self.camera = camera
        }
    }
    
    /// Update the camera position to follow the player
    private func updateCamera() {
        guard let centaur = centaur, let gameCamera = gameCamera else { return }
        
        // Create a smooth follow effect
        let cameraSpeed: CGFloat = 0.1
        let target = centaur.position
        let currentPosition = gameCamera.position
        
        let newX = currentPosition.x + (target.x - currentPosition.x) * cameraSpeed
        let newY = currentPosition.y + (target.y - currentPosition.y) * cameraSpeed
        
        gameCamera.position = CGPoint(x: newX, y: newY)
    }
    
    // MARK: - Game Logic
    
    override func update(_ currentTime: TimeInterval) {
        // Don't update if game is paused
        if isGamePaused { return }
        
        // Calculate delta time
        static var lastUpdateTime: TimeInterval = 0
        let dt = lastUpdateTime > 0 ? currentTime - lastUpdateTime : 0
        lastUpdateTime = currentTime
        
        // Update player
        if let centaur = centaur {
            centaur.update(deltaTime: dt)
        }
        
        // Update bird companion
        if let bird = bird {
            bird.update(deltaTime: dt)
        }
        
        // Update enemies
        for enemy in enemies {
            enemy.update(deltaTime: dt)
        }
        
        // Update camera
        updateCamera()
        
        // Update UI
        updateUI()
        
        // Check level completion conditions
        checkLevelCompletion()
    }
    
    /// Check if the level has been completed
    private func checkLevelCompletion() {
        // Check if all enemies are defeated
        let allEnemiesDefeated = enemies.allSatisfy { !$0.isAlive }
        
        // Check if all animals are rescued
        let allAnimalsRescued = animalCages.allSatisfy { 
            ($0.userData?["isRescued"] as? Bool) == true 
        }
        
        // If both conditions are met, level is complete
        if allEnemiesDefeated && allAnimalsRescued {
            levelComplete()
        }
    }
    
    /// Toggle pause state of the game
    func togglePause() {
        isGamePaused = !isGamePaused
        
        if isGamePaused {
            // Show pause menu
            showPauseMenu()
            // Pause music
            SoundManager.shared.pauseBackgroundMusic()
        } else {
            // Hide pause menu
            hidePauseMenu()
            // Resume music
            SoundManager.shared.resumeBackgroundMusic()
        }
    }
    
    /// Show the pause menu
    private func showPauseMenu() {
        guard let camera = gameCamera else { return }
        
        // Create pause menu panel
        let panel = SKSpriteNode(color: UIColor(white: 0, alpha: 0.7), size: CGSize(width: 300, height: 250))
        panel.position = .zero
        panel.zPosition = 200
        panel.name = "pauseMenu"
        
        // Title
        let titleLabel = SKLabelNode(fontNamed: "Chalkduster")
        titleLabel.text = "Game Paused"
        titleLabel.fontSize = 28
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: 0, y: 80)
        panel.addChild(titleLabel)
        
        // Resume button
        let resumeButton = SKSpriteNode(color: .green, size: CGSize(width: 150, height: 50))
        resumeButton.position = CGPoint(x: 0, y: 20)
        resumeButton.name = "resumeButton"
        
        let resumeLabel = SKLabelNode(fontNamed: "Chalkduster")
        resumeLabel.text = "Resume"
        resumeLabel.fontSize = 18
        resumeLabel.fontColor = .white
        resumeLabel.position = CGPoint(x: 0, y: -5)
        resumeButton.addChild(resumeLabel)
        panel.addChild(resumeButton)
        
        // Settings button
        let settingsButton = SKSpriteNode(color: .blue, size: CGSize(width: 150, height: 50))
        settingsButton.position = CGPoint(x: 0, y: -40)
        settingsButton.name = "settingsButton"
        
        let settingsLabel = SKLabelNode(fontNamed: "Chalkduster")
        settingsLabel.text = "Settings"
        settingsLabel.fontSize = 18
        settingsLabel.fontColor = .white
        settingsLabel.position = CGPoint(x: 0, y: -5)
        settingsButton.addChild(settingsLabel)
        panel.addChild(settingsButton)
        
        // Main menu button
        let menuButton = SKSpriteNode(color: .red, size: CGSize(width: 150, height: 50))
        menuButton.position = CGPoint(x: 0, y: -100)
        menuButton.name = "mainMenuButton"
        
        let menuLabel = SKLabelNode(fontNamed: "Chalkduster")
        menuLabel.text = "Main Menu"
        menuLabel.fontSize = 18
        menuLabel.fontColor = .white
        menuLabel.position = CGPoint(x: 0, y: -5)
        menuButton.addChild(menuLabel)
        panel.addChild(menuButton)
        
        // Add pause menu to camera
        camera.addChild(panel)
    }
    
    /// Hide the pause menu
    private func hidePauseMenu() {
        guard let camera = gameCamera else { return }
        
        // Remove pause menu
        if let pauseMenu = camera.childNode(withName: "pauseMenu") {
            pauseMenu.removeFromParent()
        }
    }
    
    // Additional methods and extensions will be in GameSceneExtensions.swift
}
