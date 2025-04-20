import SpriteKit

// MARK: - GameScene UI Extensions
extension GameScene {
    
    /// Set up UI elements
    func setupUI() {
        guard let camera = gameCamera else { return }
        
        // Health bar
        let healthBarBackground = SKSpriteNode(color: .darkGray, size: CGSize(width: 200, height: 20))
        healthBarBackground.position = CGPoint(x: -camera.frame.width / 2 + 120, y: camera.frame.height / 2 - 30)
        healthBarBackground.zPosition = 100
        
        healthBar = SKSpriteNode(color: .green, size: CGSize(width: 200, height: 20))
        healthBar?.anchorPoint = CGPoint(x: 0, y: 0.5)
        healthBar?.position = CGPoint(x: -camera.frame.width / 2 + 20, y: camera.frame.height / 2 - 30)
        healthBar?.zPosition = 101
        
        let healthIcon = SKSpriteNode(imageNamed: "heart_icon")
        healthIcon.size = CGSize(width: 30, height: 30)
        healthIcon.position = CGPoint(x: -camera.frame.width / 2 + 10, y: camera.frame.height / 2 - 30)
        healthIcon.zPosition = 102
        
        // Ammo display
        ammoDisplay = SKLabelNode(fontNamed: "Chalkduster")
        ammoDisplay?.text = "Arrows: 10"
        ammoDisplay?.fontSize = 18
        ammoDisplay?.fontColor = .white
        ammoDisplay?.position = CGPoint(x: -camera.frame.width / 2 + 80, y: camera.frame.height / 2 - 60)
        ammoDisplay?.horizontalAlignmentMode = .left
        ammoDisplay?.zPosition = 100
        
        // Score label
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel?.text = "Score: 0"
        scoreLabel?.fontSize = 18
        scoreLabel?.fontColor = .white
        scoreLabel?.position = CGPoint(x: camera.frame.width / 2 - 80, y: camera.frame.height / 2 - 30)
        scoreLabel?.horizontalAlignmentMode = .right
        scoreLabel?.zPosition = 100
        
        // Pause button
        pauseButton = SKSpriteNode(imageNamed: "pause_button")
        pauseButton?.size = CGSize(width: 40, height: 40)
        pauseButton?.position = CGPoint(x: camera.frame.width / 2 - 30, y: camera.frame.height / 2 - 30)
        pauseButton?.zPosition = 100
        pauseButton?.name = "pauseButton"
        
        // Add UI elements to camera
        camera.addChild(healthBarBackground)
        if let healthBar = healthBar {
            camera.addChild(healthBar)
        }
        camera.addChild(healthIcon)
        if let ammoDisplay = ammoDisplay {
            camera.addChild(ammoDisplay)
        }
        if let scoreLabel = scoreLabel {
            camera.addChild(scoreLabel)
        }
        if let pauseButton = pauseButton {
            camera.addChild(pauseButton)
        }
    }
    
    /// Set up game controls
    func setupControls() {
        guard let camera = gameCamera else { return }
        
        // Create virtual joystick for movement
        let joystickBase = SKSpriteNode(imageNamed: "joystick_base")
        joystickBase.size = CGSize(width: 100, height: 100)
        joystickBase.position = CGPoint(x: -camera.frame.width / 2 + 80, y: -camera.frame.height / 2 + 80)
        joystickBase.alpha = 0.7
        joystickBase.zPosition = 100
        
        let joystickKnobImage = SKSpriteNode(imageNamed: "joystick_knob")
        joystickKnobImage.size = CGSize(width: 50, height: 50)
        joystickKnobImage.position = CGPoint.zero
        joystickKnobImage.zPosition = 101
        
        // Create container nodes
        joystickNode = SKNode()
        joystickNode?.position = joystickBase.position
        joystickNode?.addChild(joystickBase)
        
        joystickKnob = SKNode()
        joystickKnob?.position = CGPoint.zero
        joystickKnob?.addChild(joystickKnobImage)
        
        if let joystickNode = joystickNode, let joystickKnob = joystickKnob {
            joystickNode.addChild(joystickKnob)
            camera.addChild(joystickNode)
        }
        
        // Create attack buttons
        let bowAttackButton = SKSpriteNode(imageNamed: "bow_attack_button")
        bowAttackButton.size = CGSize(width: 70, height: 70)
        bowAttackButton.position = CGPoint(x: camera.frame.width / 2 - 130, y: -camera.frame.height / 2 + 80)
        bowAttackButton.alpha = 0.8
        bowAttackButton.zPosition = 100
        bowAttackButton.name = "bowAttackButton"
        
        let kickAttackButton = SKSpriteNode(imageNamed: "kick_attack_button")
        kickAttackButton.size = CGSize(width: 70, height: 70)
        kickAttackButton.position = CGPoint(x: camera.frame.width / 2 - 60, y: -camera.frame.height / 2 + 80)
        kickAttackButton.alpha = 0.8
        kickAttackButton.zPosition = 100
        kickAttackButton.name = "kickAttackButton"
        
        // Add buttons to camera
        camera.addChild(bowAttackButton)
        camera.addChild(kickAttackButton)
    }
    
    /// Update UI elements based on player state
    func updateUI() {
        guard let centaur = centaur else { return }
        
        // Update health bar
        if let healthBar = healthBar {
            let healthPercentage = CGFloat(centaur.health) / CGFloat(centaur.maxHealth)
            let newWidth = 200 * healthPercentage
            
            healthBar.size = CGSize(width: newWidth, height: 20)
            
            // Change color based on health
            if healthPercentage > 0.7 {
                healthBar.color = .green
            } else if healthPercentage > 0.3 {
                healthBar.color = .yellow
            } else {
                healthBar.color = .red
            }
        }
        
        // Update ammo display
        if let ammoDisplay = ammoDisplay {
            ammoDisplay.text = "Arrows: \(centaur.bowAmmo)"
        }
        
        // Update score label
        if let scoreLabel = scoreLabel {
            scoreLabel.text = "XP: \(GameManager.shared.playerExperience)"
        }
    }
    
    /// Handle level completion
    func levelComplete() {
        // Pause the game
        isGamePaused = true
        
        // Show level complete screen
        showLevelCompleteScreen()
        
        // Award bonus XP
        let bonusXP = currentLevel * 20
        GameManager.shared.addExperience(bonusXP)
        
        // Save game state
        GameManager.shared.saveGameState()
    }
    
    /// Show the level complete screen
    func showLevelCompleteScreen() {
        guard let camera = gameCamera else { return }
        
        // Create level complete panel
        let panel = SKSpriteNode(color: UIColor(white: 0, alpha: 0.7), size: CGSize(width: 400, height: 300))
        panel.position = .zero
        panel.zPosition = 200
        
        // Title
        let titleLabel = SKLabelNode(fontNamed: "Chalkduster")
        titleLabel.text = "Level \(currentLevel) Complete!"
        titleLabel.fontSize = 28
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: 0, y: 100)
        panel.addChild(titleLabel)
        
        // Stats
        let statsLabel = SKLabelNode(fontNamed: "Chalkduster")
        statsLabel.text = "Animals Rescued: \(animalCages.count)"
        statsLabel.fontSize = 18
        statsLabel.fontColor = .white
        statsLabel.position = CGPoint(x: 0, y: 50)
        panel.addChild(statsLabel)
        
        let enemiesLabel = SKLabelNode(fontNamed: "Chalkduster")
        enemiesLabel.text = "Enemies Defeated: \(enemies.count)"
        enemiesLabel.fontSize = 18
        enemiesLabel.fontColor = .white
        enemiesLabel.position = CGPoint(x: 0, y: 20)
        panel.addChild(enemiesLabel)
        
        let xpLabel = SKLabelNode(fontNamed: "Chalkduster")
        xpLabel.text = "Bonus XP: \(currentLevel * 20)"
        xpLabel.fontSize = 18
        xpLabel.fontColor = .yellow
        xpLabel.position = CGPoint(x: 0, y: -10)
        panel.addChild(xpLabel)
        
        // Next level button
        let nextButton = SKSpriteNode(color: .green, size: CGSize(width: 150, height: 50))
        nextButton.position = CGPoint(x: 0, y: -70)
        nextButton.name = "nextLevelButton"
        
        let nextLabel = SKLabelNode(fontNamed: "Chalkduster")
        nextLabel.text = "Next Level"
        nextLabel.fontSize = 18
        nextLabel.fontColor = .white
        nextLabel.position = CGPoint(x: 0, y: -5)
        nextButton.addChild(nextLabel)
        
        panel.addChild(nextButton)
        
        // Add panel to camera
        camera.addChild(panel)
        
        // Play victory sound
        SoundManager.shared.playSoundEffect(filename: "level_complete")
    }
    
    /// Advance to the next level
    func goToNextLevel() {
        guard let camera = gameCamera else { return }
        
        // Remove level complete panel
        for child in camera.children {
            if child.zPosition == 200 {
                child.removeFromParent()
            }
        }
        
        // Increment level
        currentLevel += 1
        
        // Load next level
        loadLevel(level: currentLevel)
        
        // Resume game
        isGamePaused = false
    }
    
    /// Show a notification or message to the player
    /// - Parameters:
    ///   - text: The message text
    ///   - duration: How long to show the message
    func showNotification(text: String, duration: TimeInterval = 2.0) {
        guard let camera = gameCamera else { return }
        
        // Create notification label
        let notification = SKLabelNode(fontNamed: "Chalkduster")
        notification.text = text
        notification.fontSize = 24
        notification.fontColor = .white
        notification.position = CGPoint(x: 0, y: 50)
        notification.zPosition = 150
        notification.alpha = 0
        
        // Add to camera
        camera.addChild(notification)
        
        // Animate notification
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let wait = SKAction.wait(forDuration: duration)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let remove = SKAction.removeFromParent()
        
        notification.run(SKAction.sequence([fadeIn, wait, fadeOut, remove]))
    }
    
    /// Show dialog between characters
    /// - Parameters:
    ///   - text: The dialog text
    ///   - speaker: Who is speaking (centaur or bird)
    ///   - completion: Optional callback when dialog completes
    func showDialog(text: String, speaker: String, completion: (() -> Void)? = nil) {
        guard let camera = gameCamera else { return }
        
        // Create dialog panel
        let panel = SKSpriteNode(color: UIColor(white: 0, alpha: 0.7), size: CGSize(width: 500, height: 150))
        panel.position = CGPoint(x: 0, y: -camera.frame.height / 2 + 100)
        panel.zPosition = 150
        panel.name = "dialogPanel"
        
        // Speaker name
        let nameLabel = SKLabelNode(fontNamed: "Chalkduster")
        nameLabel.text = speaker
        nameLabel.fontSize = 20
        nameLabel.fontColor = .yellow
        nameLabel.position = CGPoint(x: -panel.frame.width / 2 + 60, y: panel.frame.height / 2 - 25)
        nameLabel.horizontalAlignmentMode = .left
        panel.addChild(nameLabel)
        
        // Dialog text
        let textLabel = SKLabelNode(fontNamed: "Chalkduster")
        textLabel.text = text
        textLabel.fontSize = 18
        textLabel.fontColor = .white
        textLabel.position = CGPoint(x: 0, y: 0)
        textLabel.horizontalAlignmentMode = .center
        textLabel.verticalAlignmentMode = .center
        textLabel.preferredMaxLayoutWidth = 450
        textLabel.numberOfLines = 0
        panel.addChild(textLabel)
        
        // Continue indicator
        let continueLabel = SKLabelNode(fontNamed: "Chalkduster")
        continueLabel.text = "Tap to continue..."
        continueLabel.fontSize = 16
        continueLabel.fontColor = .lightGray
        continueLabel.position = CGPoint(x: panel.frame.width / 2 - 80, y: -panel.frame.height / 2 + 20)
        continueLabel.horizontalAlignmentMode = .right
        panel.addChild(continueLabel)
        
        // Add dialog to camera
        camera.addChild(panel)
        
        // Store completion handler in user data if provided
        if let completion = completion {
            panel.userData = NSMutableDictionary()
            panel.userData?.setValue(completion, forKey: "completionHandler")
        }
        
        // Pause the game while dialog is shown
        isGamePaused = true
    }
    
    /// Dismiss the current dialog
    func dismissDialog() {
        guard let camera = gameCamera else { return }
        
        // Find dialog panel
        if let dialogPanel = camera.childNode(withName: "dialogPanel") {
            // Check for completion handler
            if let completionHandler = dialogPanel.userData?.value(forKey: "completionHandler") as? () -> Void {
                completionHandler()
            }
            
            // Remove dialog
            dialogPanel.removeFromParent()
        }
        
        // Resume game if no pause menu is shown
        if camera.childNode(withName: "pauseMenu") == nil {
            isGamePaused = false
        }
    }
}
