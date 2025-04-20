import Foundation

/**
 * GameDataManager
 * 
 * A singleton class that handles all game data persistence, including:
 * - Saving and loading game progress
 * - Storing player preferences
 * - Tracking unlocked characters and achievements
 * - Managing high scores
 */
class GameDataManager {
    
    // Shared singleton instance
    static let shared = GameDataManager()
    
    // Keys for UserDefaults
    private struct Keys {
        static let saveGameData = "saveGameData"
        static let playerSettings = "playerSettings"
        static let unlockedCharacters = "unlockedCharacters"
        static let achievements = "achievements"
        static let highScores = "highScores"
        static let soundEnabled = "soundEnabled"
        static let musicEnabled = "musicEnabled"
        static let vibrationEnabled = "vibrationEnabled"
        static let difficultyLevel = "difficultyLevel"
    }
    
    // Default settings
    private struct Defaults {
        static let soundEnabled = true
        static let musicEnabled = true
        static let vibrationEnabled = true
        static let difficultyLevel = 1 // 1=Easy, 2=Medium, 3=Hard
        static let initialUnlockedCharacters = ["Centaur", "Bird"] // Starting characters
    }
    
    // Private initializer for singleton
    private init() {
        // Initialize default settings if not already set
        initializeDefaultsIfNeeded()
    }
    
    /**
     * Initialize default values for first launch
     */
    private func initializeDefaultsIfNeeded() {
        let defaults = UserDefaults.standard
        
        // Check if this is the first launch
        if !defaults.bool(forKey: "hasLaunchedBefore") {
            // Set default settings
            defaults.set(Defaults.soundEnabled, forKey: Keys.soundEnabled)
            defaults.set(Defaults.musicEnabled, forKey: Keys.musicEnabled)
            defaults.set(Defaults.vibrationEnabled, forKey: Keys.vibrationEnabled)
            defaults.set(Defaults.difficultyLevel, forKey: Keys.difficultyLevel)
            
            // Set initially unlocked characters
            if let encodedData = try? JSONEncoder().encode(Defaults.initialUnlockedCharacters) {
                defaults.set(encodedData, forKey: Keys.unlockedCharacters)
            }
            
            // Initialize empty high scores and achievements
            let emptyHighScores: [String: Int] = [:]
            let emptyAchievements: [String: Bool] = [:]
            
            if let encodedScores = try? JSONEncoder().encode(emptyHighScores) {
                defaults.set(encodedScores, forKey: Keys.highScores)
            }
            
            if let encodedAchievements = try? JSONEncoder().encode(emptyAchievements) {
                defaults.set(encodedAchievements, forKey: Keys.achievements)
            }
            
            // Mark as launched
            defaults.set(true, forKey: "hasLaunchedBefore")
        }
    }
    
    // MARK: - Game Save/Load Methods
    
    /**
     * Check if there is saved game data
     */
    func hasSaveData() -> Bool {
        return UserDefaults.standard.object(forKey: Keys.saveGameData) != nil
    }
    
    /**
     * Save the current game state
     */
    func saveGame(gameState: GameState) {
        do {
            let encodedData = try JSONEncoder().encode(gameState)
            UserDefaults.standard.set(encodedData, forKey: Keys.saveGameData)
            print("Game saved successfully")
        } catch {
            print("Error saving game: \(error.localizedDescription)")
        }
    }
    
    /**
     * Load the saved game state
     */
    func loadGame() -> GameState? {
        guard let savedData = UserDefaults.standard.data(forKey: Keys.saveGameData) else {
            print("No saved game data found")
            return nil
        }
        
        do {
            let gameState = try JSONDecoder().decode(GameState.self, from: savedData)
            print("Game loaded successfully")
            return gameState
        } catch {
            print("Error loading game: \(error.localizedDescription)")
            return nil
        }
    }
    
    /**
     * Delete the saved game
     */
    func deleteSavedGame() {
        UserDefaults.standard.removeObject(forKey: Keys.saveGameData)
        print("Saved game deleted")
    }
    
    // MARK: - Settings Methods
    
    /**
     * Get sound effects enabled state
     */
    var isSoundEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.soundEnabled)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.soundEnabled)
        }
    }
    
    /**
     * Get background music enabled state
     */
    var isMusicEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.musicEnabled)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.musicEnabled)
        }
    }
    
    /**
     * Get vibration feedback enabled state
     */
    var isVibrationEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.vibrationEnabled)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.vibrationEnabled)
        }
    }
    
    /**
     * Get current difficulty level
     */
    var difficultyLevel: Int {
        get {
            return UserDefaults.standard.integer(forKey: Keys.difficultyLevel)
        }
        set {
            // Clamp to valid range
            let validValue = min(max(newValue, 1), 3)
            UserDefaults.standard.set(validValue, forKey: Keys.difficultyLevel)
        }
    }
    
    // MARK: - Character Unlocking Methods
    
    /**
     * Get list of unlocked characters
     */
    func getUnlockedCharacters() -> [String] {
        guard let data = UserDefaults.standard.data(forKey: Keys.unlockedCharacters) else {
            return Defaults.initialUnlockedCharacters
        }
        
        do {
            let characters = try JSONDecoder().decode([String].self, from: data)
            return characters
        } catch {
            print("Error getting unlocked characters: \(error.localizedDescription)")
            return Defaults.initialUnlockedCharacters
        }
    }
    
    /**
     * Unlock a new character
     */
    func unlockCharacter(_ characterName: String) {
        var currentUnlocked = getUnlockedCharacters()
        
        // Check if already unlocked
        if !currentUnlocked.contains(characterName) {
            currentUnlocked.append(characterName)
            
            // Save updated list
            do {
                let encodedData = try JSONEncoder().encode(currentUnlocked)
                UserDefaults.standard.set(encodedData, forKey: Keys.unlockedCharacters)
                print("Character \(characterName) unlocked")
            } catch {
                print("Error unlocking character: \(error.localizedDescription)")
            }
        }
    }
    
    /**
     * Check if a specific character is unlocked
     */
    func isCharacterUnlocked(_ characterName: String) -> Bool {
        return getUnlockedCharacters().contains(characterName)
    }
    
    // MARK: - High Score Methods
    
    /**
     * Set high score for a level
     */
    func setHighScore(_ score: Int, forLevel levelID: String) {
        // Get current high scores
        var highScores = getHighScores()
        
        // Only update if new score is higher
        if let currentScore = highScores[levelID], currentScore >= score {
            return
        }
        
        // Set new high score
        highScores[levelID] = score
        
        // Save updated scores
        do {
            let encodedData = try JSONEncoder().encode(highScores)
            UserDefaults.standard.set(encodedData, forKey: Keys.highScores)
            print("High score updated for level \(levelID): \(score)")
        } catch {
            print("Error saving high score: \(error.localizedDescription)")
        }
    }
    
    /**
     * Get high score for a specific level
     */
    func getHighScore(forLevel levelID: String) -> Int {
        return getHighScores()[levelID] ?? 0
    }
    
    /**
     * Get all high scores
     */
    func getHighScores() -> [String: Int] {
        guard let data = UserDefaults.standard.data(forKey: Keys.highScores) else {
            return [:]
        }
        
        do {
            let highScores = try JSONDecoder().decode([String: Int].self, from: data)
            return highScores
        } catch {
            print("Error getting high scores: \(error.localizedDescription)")
            return [:]
        }
    }
    
    // MARK: - Achievement Methods
    
    /**
     * Unlock an achievement
     */
    func unlockAchievement(_ achievementID: String) {
        var achievements = getAchievements()
        
        // Set achievement to unlocked
        achievements[achievementID] = true
        
        // Save updated achievements
        do {
            let encodedData = try JSONEncoder().encode(achievements)
            UserDefaults.standard.set(encodedData, forKey: Keys.achievements)
            print("Achievement unlocked: \(achievementID)")
        } catch {
            print("Error unlocking achievement: \(error.localizedDescription)")
        }
    }
    
    /**
     * Check if an achievement is unlocked
     */
    func isAchievementUnlocked(_ achievementID: String) -> Bool {
        return getAchievements()[achievementID] ?? false
    }
    
    /**
     * Get all achievements and their unlock status
     */
    func getAchievements() -> [String: Bool] {
        guard let data = UserDefaults.standard.data(forKey: Keys.achievements) else {
            return [:]
        }
        
        do {
            let achievements = try JSONDecoder().decode([String: Bool].self, from: data)
            return achievements
        } catch {
            print("Error getting achievements: \(error.localizedDescription)")
            return [:]
        }
    }
    
    /**
     * Reset all game data (for development/testing)
     */
    func resetAllData() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: Keys.saveGameData)
        defaults.removeObject(forKey: Keys.unlockedCharacters)
        defaults.removeObject(forKey: Keys.achievements)
        defaults.removeObject(forKey: Keys.highScores)
        
        // Reset to defaults
        defaults.set(false, forKey: "hasLaunchedBefore")
        initializeDefaultsIfNeeded()
        
        print("All game data has been reset")
    }
}

/**
 * GameState
 *
 * A struct representing the complete state of a game session to be saved.
 * Conforms to Codable for easy serialization.
 */
struct GameState: Codable {
    // Player character info
    var characterType: String
    var characterLevel: Int
    var health: Int
    var maxHealth: Int
    var mana: Int
    var maxMana: Int
    var experience: Int
    var position: CGPointWrapper
    
    // Level info
    var currentLevelID: String
    var completedLevels: [String]
    
    // Inventory
    var collectedItems: [String]
    var equippedItems: [String]
    
    // Game progress
    var score: Int
    var gameTime: TimeInterval
    var checkpointID: String?
    
    // Abilities
    var unlockedAbilities: [String]
}

/**
 * CGPointWrapper
 * 
 * A wrapper to make CGPoint Codable for serialization
 */
struct CGPointWrapper: Codable {
    let x: CGFloat
    let y: CGFloat
    
    init(point: CGPoint) {
        self.x = point.x
        self.y = point.y
    }
    
    var point: CGPoint {
        return CGPoint(x: x, y: y)
    }
}

// Add Codable conformance to CGFloat since it's not automatically provided
extension CGFloat: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(try container.decode(Double.self))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(Double(self))
    }
}
