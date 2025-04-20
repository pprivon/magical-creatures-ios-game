import SpriteKit
import GameplayKit

/**
 * MainMenuScene
 * 
 * The game's main menu interface that presents the player with options to:
 * - Start a new game
 * - Continue a saved game
 * - Access settings
 * - View character gallery
 * - View credits
 */
class MainMenuScene: SKScene {
    
    // UI Elements
    private var titleLabel: SKLabelNode?
    private var startButton: SKSpriteNode?
    private var continueButton: SKSpriteNode?
    private var settingsButton: SKSpriteNode?
    private var galleryButton: SKSpriteNode?
    private var creditsButton: SKSpriteNode?
    
    // Background elements
    private var backgroundNode: SKSpriteNode?
    private var characterPreviewNode: SKSpriteNode?
    
    // Animation properties
    private var animationTimer: Timer?
    private var characterRotationIndex = 0
    private let characterTypes = ["Centaur", "Bird", "Dragon", "Elf"]
    
    /**
     * Called when the scene is presented
     */
    override func didMove(to view: SKView) {
        // Set up the scene
        setupBackground()
        setupTitle()
        setupMenuButtons()
        setupCharacterPreview()
        
        // Start character rotation animation
        startCharacterRotation()
        
        // Play background music
        playBackgroundMusic()
    }
    
    /**
     * Set up the background for the menu
     */
    private func setupBackground() {
        // Create a gradient background
        backgroundNode = SKSpriteNode(color: .clear, size: self.size)
        backgroundNode?.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        backgroundNode?.zPosition = -10
        addChild(backgroundNode!)
        
        // Add the gradient background shader
        let shader = SKShader(fileNamed: "GradientBackground")
        shader.uniforms = [
            SKUniform(name: "u_top_color", color: SKColor(red: 0.1, green: 0.2, blue: 0.4, alpha: 1.0)),
            SKUniform(name: "u_bottom_color", color: SKColor(red: 0.4, green: 0.1, blue: 0.5, alpha: 1.0))
        ]
        backgroundNode?.shader = shader
        
        // Add particle effects
        if let particles = SKEmitterNode(fileNamed: "MagicParticles") {
            particles.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
            particles.zPosition = -5
            particles.particleBirthRate = 2.0
            addChild(particles)
        }
    }
    
    /**
     * Set up the game title
     */
    private func setupTitle() {
        titleLabel = SKLabelNode(fontNamed: "Copperplate-Bold")
        titleLabel?.text = "Magical Creatures"
        titleLabel?.fontSize = 64
        titleLabel?.fontColor = SKColor.white
        titleLabel?.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.85)
        titleLabel?.zPosition = 5
        
        // Add glow effect
        titleLabel?.addGlow(radius: 30, color: .cyan)
        
        addChild(titleLabel!)
        
        // Animate the title with a subtle bounce
        let scaleUp = SKAction.scale(to: 1.1, duration: 1.0)
        let scaleDown = SKAction.scale(to: 0.95, duration: 1.0)
        let sequence = SKAction.sequence([scaleUp, scaleDown])
        let repeatForever = SKAction.repeatForever(sequence)
        titleLabel?.run(repeatForever)
    }
    
    /**
     * Set up all menu buttons
     */
    private func setupMenuButtons() {
        // Button positions (centered horizontally)
        let buttonX = self.size.width/2
        let startY = self.size.height * 0.6
        let buttonSpacing = 80.0
        
        // Common button properties
        let buttonWidth = 250.0
        let buttonHeight = 60.0
        
        // Start Button
        startButton = createButton(text: "Start Game", width: buttonWidth, height: buttonHeight)
        startButton?.position = CGPoint(x: buttonX, y: startY)
        startButton?.name = "startButton"
        addChild(startButton!)
        
        // Continue Button
        continueButton = createButton(text: "Continue", width: buttonWidth, height: buttonHeight)
        continueButton?.position = CGPoint(x: buttonX, y: startY - buttonSpacing)
        continueButton?.name = "continueButton"
        
        // Disable if no save data exists
        if !GameDataManager.shared.hasSaveData() {
            continueButton?.alpha = 0.5
            continueButton?.isUserInteractionEnabled = false
        }
        
        addChild(continueButton!)
        
        // Settings Button
        settingsButton = createButton(text: "Settings", width: buttonWidth, height: buttonHeight)
        settingsButton?.position = CGPoint(x: buttonX, y: startY - 2*buttonSpacing)
        settingsButton?.name = "settingsButton"
        addChild(settingsButton!)
        
        // Gallery Button
        galleryButton = createButton(text: "Character Gallery", width: buttonWidth, height: buttonHeight)
        galleryButton?.position = CGPoint(x: buttonX, y: startY - 3*buttonSpacing)
        galleryButton?.name = "galleryButton"
        addChild(galleryButton!)
        
        // Credits Button
        creditsButton = createButton(text: "Credits", width: buttonWidth, height: buttonHeight)
        creditsButton?.position = CGPoint(x: buttonX, y: startY - 4*buttonSpacing)
        creditsButton?.name = "creditsButton"
        addChild(creditsButton!)
    }
    
    /**
     * Create a styled button with text
     */
    private func createButton(text: String, width: CGFloat, height: CGFloat) -> SKSpriteNode {
        // Create button background
        let button = SKSpriteNode(color: SKColor(red: 0.2, green: 0.3, blue: 0.7, alpha: 0.7), 
                                 size: CGSize(width: width, height: height))
        button.zPosition = 1
        
        // Round the corners with a mask
        let path = CGMutablePath()
        path.addRoundedRect(in: CGRect(x: -width/2, y: -height/2, width: width, height: height), 
                           cornerWidth: 15, cornerHeight: 15)
        
        let shape = SKShapeNode(path: path)
        shape.lineWidth = 2
        shape.strokeColor = .white
        shape.fillColor = .clear
        button.addChild(shape)
        
        // Add text label
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = text
        label.fontSize = 28
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.zPosition = 2
        button.addChild(label)
        
        return button
    }
    
    /**
     * Set up the rotating character preview
     */
    private func setupCharacterPreview() {
        // Create container node for character preview
        characterPreviewNode = SKSpriteNode(color: .clear, 
                                          size: CGSize(width: 300, height: 300))
        characterPreviewNode?.position = CGPoint(x: self.size.width * 0.8, 
                                               y: self.size.height * 0.3)
        characterPreviewNode?.zPosition = 3
        addChild(characterPreviewNode!)
        
        // Show the first character
        displayCharacter(type: characterTypes[0])
    }
    
    /**
     * Display a character in the preview area
     */
    private func displayCharacter(type: String) {
        // Remove any existing character
        characterPreviewNode?.removeAllChildren()
        
        // Create character sprite based on type
        let character = SKSpriteNode(imageNamed: "character_\(type.lowercased())")
        character.setScale(0.8)
        character.zPosition = 3
        
        // Add to preview node
        characterPreviewNode?.addChild(character)
        
        // Add name label
        let nameLabel = SKLabelNode(fontNamed: "Avenir-Heavy")
        nameLabel.text = type
        nameLabel.fontSize = 24
        nameLabel.fontColor = .white
        nameLabel.position = CGPoint(x: 0, y: -120)
        nameLabel.zPosition = 4
        characterPreviewNode?.addChild(nameLabel)
        
        // Create a brief entrance animation
        character.setScale(0.1)
        character.alpha = 0
        
        let appear = SKAction.group([
            SKAction.scale(to: 0.8, duration: 0.5),
            SKAction.fadeIn(withDuration: 0.3)
        ])
        
        character.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.1),
            appear,
            SKAction.wait(forDuration: 0.2),
            SKAction.repeatForever(SKAction.sequence([
                SKAction.scale(to: 0.85, duration: 1.0),
                SKAction.scale(to: 0.8, duration: 1.0)
            ]))
        ]))
    }
    
    /**
     * Start the character rotation timer
     */
    private func startCharacterRotation() {
        // Rotate characters every 5 seconds
        animationTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // Move to next character
            self.characterRotationIndex = (self.characterRotationIndex + 1) % self.characterTypes.count
            self.displayCharacter(type: self.characterTypes[self.characterRotationIndex])
        }
    }
    
    /**
     * Play background music for the menu
     */
    private func playBackgroundMusic() {
        // The actual audio playback would be handled by an audio manager class
        // For now, we'll just pretend we're playing music
        print("Playing menu background music")
    }
    
    /**
     * Handle touches on menu items
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        // Get touch location and check if it hits any buttons
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        for node in touchedNodes {
            if let nodeName = node.name {
                handleButtonPress(nodeName)
                break
            }
        }
    }
    
    /**
     * Handle button press actions
     */
    private func handleButtonPress(_ buttonName: String) {
        // Animate button press
        if let button = childNode(withName: buttonName) as? SKSpriteNode {
            let scaleDown = SKAction.scale(to: 0.9, duration: 0.1)
            let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
            let sequence = SKAction.sequence([scaleDown, scaleUp])
            
            button.run(sequence) {
                // Handle the button action after animation completes
                self.executeButtonAction(buttonName)
            }
        }
    }
    
    /**
     * Execute the appropriate action for a button
     */
    private func executeButtonAction(_ buttonName: String) {
        switch buttonName {
        case "startButton":
            startNewGame()
            
        case "continueButton":
            continueGame()
            
        case "settingsButton":
            showSettings()
            
        case "galleryButton":
            showGallery()
            
        case "creditsButton":
            showCredits()
            
        default:
            break
        }
    }
    
    /**
     * Start a new game
     */
    private func startNewGame() {
        // Create character selection scene
        if let characterSelectScene = CharacterSelectionScene(fileNamed: "CharacterSelectionScene") {
            characterSelectScene.scaleMode = .aspectFill
            
            // Transition to character selection
            let transition = SKTransition.doorway(withDuration: 0.8)
            self.view?.presentScene(characterSelectScene, transition: transition)
        }
    }
    
    /**
     * Continue from a saved game
     */
    private func continueGame() {
        // Load saved game data
        if GameDataManager.shared.hasSaveData() {
            // Create game scene with saved data
            if let gameScene = GameScene(fileNamed: "GameScene") {
                gameScene.scaleMode = .aspectFill
                gameScene.loadSavedGameState()
                
                // Transition to game
                let transition = SKTransition.fade(withDuration: 0.5)
                self.view?.presentScene(gameScene, transition: transition)
            }
        }
    }
    
    /**
     * Show the settings scene
     */
    private func showSettings() {
        if let settingsScene = SettingsScene(fileNamed: "SettingsScene") {
            settingsScene.scaleMode = .aspectFill
            
            // Transition to settings
            let transition = SKTransition.push(with: .left, duration: 0.5)
            self.view?.presentScene(settingsScene, transition: transition)
        }
    }
    
    /**
     * Show the character gallery
     */
    private func showGallery() {
        if let galleryScene = GalleryScene(fileNamed: "GalleryScene") {
            galleryScene.scaleMode = .aspectFill
            
            // Transition to gallery
            let transition = SKTransition.flipHorizontal(withDuration: 0.5)
            self.view?.presentScene(galleryScene, transition: transition)
        }
    }
    
    /**
     * Show the credits scene
     */
    private func showCredits() {
        if let creditsScene = CreditsScene(fileNamed: "CreditsScene") {
            creditsScene.scaleMode = .aspectFill
            
            // Transition to credits
            let transition = SKTransition.moveIn(with: .bottom, duration: 0.5)
            self.view?.presentScene(creditsScene, transition: transition)
        }
    }
    
    /**
     * Clean up resources when scene is about to be removed
     */
    override func willMove(from view: SKView) {
        // Stop animations
        animationTimer?.invalidate()
        animationTimer = nil
        
        // Stop any audio
        // audioManager.stopBackgroundMusic()
    }
}

/**
 * Extension for SKLabelNode to add glow effect
 */
extension SKLabelNode {
    func addGlow(radius: CGFloat, color: SKColor) {
        guard let text = self.text else { return }
        
        // Create a glow effect by layering multiple semi-transparent copies
        for i in 1...3 {
            let glowLabel = SKLabelNode(fontNamed: self.fontName)
            glowLabel.text = text
            glowLabel.fontSize = self.fontSize
            glowLabel.fontColor = color.withAlphaComponent(0.3 / CGFloat(i))
            glowLabel.position = .zero
            glowLabel.zPosition = -CGFloat(i)
            
            let blur = SKEffectNode()
            blur.addChild(glowLabel)
            blur.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": radius * CGFloat(i)])
            blur.zPosition = -CGFloat(i)
            self.addChild(blur)
        }
    }
}
