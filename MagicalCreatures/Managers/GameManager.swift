import Foundation
import SpriteKit

/// GameManager is a singleton class that manages the overall game state
class GameManager {
    // MARK: - Singleton
    static let shared = GameManager()
    
    // MARK: - Properties
    
    // Player stats
    var playerHealth: Int = 20
    var playerStrength: Int = 5
    var playerMagic: Int = 3
    var playerSpeed: Int = 7
    var playerExperience: Int = 0
    var playerLevel: Int = 1
    
    // Game progress
    var currentLevel: Int = 1
    var rescuedAnimals: [String] = []
    var completedQuests: [String] = []
    var unlockedAbilities: [String] = ["BowShot", "RearKick"]
    
    // Inventory
    var inventory: [String: Int] = [:]
    var equippedItems: [String: String] = [:]
    
    // Game settings
    var soundEnabled: Bool = true
    var musicEnabled: Bool = true
    var difficultyLevel: DifficultyLevel = .normal
    
    // Premium content
    var purchasedItems: [String] = []
    var isAdFree: Bool = false
    
    // MARK: - Enums
    
    enum DifficultyLevel: String, Codable {
        case easy = "Easy"
        case normal = "Normal"
        case hard = "Hard"
    }
    
    // MARK: - Initialization
    
    private init() {
        // Private initializer to enforce singleton pattern
        loadGameState()
    }
    
    // MARK: - Game State Management
    
    /// Saves the current game state to UserDefaults
    func saveGameState() {
        let gameData: [String: Any] = [
            "playerHealth": playerHealth,
            "playerStrength": playerStrength,
            "playerMagic": playerMagic,
            "playerSpeed": playerSpeed,
            "playerExperience": playerExperience,
            "playerLevel": playerLevel,
            "currentLevel": currentLevel,
            "rescuedAnimals": rescuedAnimals,
            "completedQuests": completedQuests,
            "unlockedAbilities": unlockedAbilities,
            "inventory": inventory,
            "equippedItems": equippedItems,
            "soundEnabled": soundEnabled,
            "musicEnabled": musicEnabled,
            "difficultyLevel": difficultyLevel.rawValue,
            "purchasedItems": purchasedItems,
            "isAdFree": isAdFree
        ]
        
        if let encodedData = try? JSONSerialization.data(withJSONObject: gameData) {
            UserDefaults.standard.set(encodedData, forKey: "MagicalCreaturesGameState")
            UserDefaults.standard.synchronize()
            print("Game state saved successfully")
        } else {
            print("Failed to save game state")
        }
    }
    
    /// Loads the game state from UserDefaults
    func loadGameState() {
        if let savedData = UserDefaults.standard.data(forKey: "MagicalCreaturesGameState"),
           let gameData = try? JSONSerialization.jsonObject(with: savedData) as? [String: Any] {
            
            playerHealth = gameData["playerHealth"] as? Int ?? 20
            playerStrength = gameData["playerStrength"] as? Int ?? 5
            playerMagic = gameData["playerMagic"] as? Int ?? 3
            playerSpeed = gameData["playerSpeed"] as? Int ?? 7
            playerExperience = gameData["playerExperience"] as? Int ?? 0
            playerLevel = gameData["playerLevel"] as? Int ?? 1
            
            currentLevel = gameData["currentLevel"] as? Int ?? 1
            rescuedAnimals = gameData["rescuedAnimals"] as? [String] ?? []
            completedQuests = gameData["completedQuests"] as? [String] ?? []
            unlockedAbilities = gameData["unlockedAbilities"] as? [String] ?? ["BowShot", "RearKick"]
            
            inventory = gameData["inventory"] as? [String: Int] ?? [:]
            equippedItems = gameData["equippedItems"] as? [String: String] ?? [:]
            
            soundEnabled = gameData["soundEnabled"] as? Bool ?? true
            musicEnabled = gameData["musicEnabled"] as? Bool ?? true
            
            if let difficultyString = gameData["difficultyLevel"] as? String,
               let difficulty = DifficultyLevel(rawValue: difficultyString) {
                difficultyLevel = difficulty
            } else {
                difficultyLevel = .normal
            }
            
            purchasedItems = gameData["purchasedItems"] as? [String] ?? []
            isAdFree = gameData["isAdFree"] as? Bool ?? false
            
            print("Game state loaded successfully")
        } else {
            print("No saved game state found, using defaults")
            
            // Initialize with some starting items
            inventory = ["HealthPotion": 3]
        }
    }
    
    /// Resets the game state to starting values
    func resetGameState() {
        playerHealth = 20
        playerStrength = 5
        playerMagic = 3
        playerSpeed = 7
        playerExperience = 0
        playerLevel = 1
        
        currentLevel = 1
        rescuedAnimals = []
        completedQuests = []
        unlockedAbilities = ["BowShot", "RearKick"]
        
        inventory = ["HealthPotion": 3]
        equippedItems = [:]
        
        saveGameState()
        print("Game state reset to defaults")
    }
    
    // MARK: - Game Logic
    
    /// Add experience points and handle level ups
    func addExperience(_ amount: Int) {
        playerExperience += amount
        
        // Check for level up (simple formula: 100 * current level)
        let experienceNeededForNextLevel = 100 * playerLevel
        
        if playerExperience >= experienceNeededForNextLevel {
            levelUp()
        }
    }
    
    /// Handle player level up
    private func levelUp() {
        playerLevel += 1
        playerExperience = 0
        
        // Increase stats
        playerHealth += 5
        playerStrength += 2
        playerMagic += 2
        playerSpeed += 1
        
        // Unlock new ability based on level
        if playerLevel == 3 {
            unlockedAbilities.append("HealingTouch")
        } else if playerLevel == 5 {
            unlockedAbilities.append("StampedeDash")
        } else if playerLevel == 7 {
            unlockedAbilities.append("NaturesBond")
        }
        
        print("Level up! Player is now level \(playerLevel)")
        
        // Save game state after level up
        saveGameState()
        
        // Notify that a level up occurred (for UI updates)
        NotificationCenter.default.post(name: NSNotification.Name("PlayerLeveledUp"), object: nil)
    }
    
    /// Add a rescued animal to the collection
    func rescueAnimal(_ animalName: String) {
        if !rescuedAnimals.contains(animalName) {
            rescuedAnimals.append(animalName)
            addExperience(20) // Award XP for rescuing an animal
            saveGameState()
            
            // Notify that an animal was rescued (for UI updates)
            NotificationCenter.default.post(name: NSNotification.Name("AnimalRescued"), object: animalName)
        }
    }
    
    /// Complete a quest
    func completeQuest(_ questName: String) {
        if !completedQuests.contains(questName) {
            completedQuests.append(questName)
            addExperience(50) // Award XP for completing a quest
            saveGameState()
            
            // Notify that a quest was completed (for UI updates)
            NotificationCenter.default.post(name: NSNotification.Name("QuestCompleted"), object: questName)
        }
    }
    
    /// Add an item to inventory
    func addItemToInventory(_ itemName: String, quantity: Int = 1) {
        if let currentQuantity = inventory[itemName] {
            inventory[itemName] = currentQuantity + quantity
        } else {
            inventory[itemName] = quantity
        }
        saveGameState()
    }
    
    /// Remove an item from inventory
    func removeItemFromInventory(_ itemName: String, quantity: Int = 1) -> Bool {
        guard let currentQuantity = inventory[itemName], currentQuantity >= quantity else {
            return false
        }
        
        if currentQuantity == quantity {
            inventory.removeValue(forKey: itemName)
        } else {
            inventory[itemName] = currentQuantity - quantity
        }
        
        saveGameState()
        return true
    }
    
    /// Check if player has unlocked a specific ability
    func hasAbility(_ abilityName: String) -> Bool {
        return unlockedAbilities.contains(abilityName)
    }
    
    // MARK: - Premium Content Management
    
    /// Record a purchase
    func recordPurchase(_ itemId: String) {
        if !purchasedItems.contains(itemId) {
            purchasedItems.append(itemId)
            
            if itemId == "AdFreeExperience" {
                isAdFree = true
            }
            
            saveGameState()
        }
    }
    
    /// Check if an item has been purchased
    func hasPurchased(_ itemId: String) -> Bool {
        return purchasedItems.contains(itemId)
    }
    
    /// Process the result of purchasing a cosmetic item
    func processCosmeticPurchase(_ itemId: String) {
        recordPurchase(itemId)
        // Additional logic specific to cosmetic items
    }
    
    /// Process the result of purchasing a helper animal
    func processHelperAnimalPurchase(_ itemId: String) {
        recordPurchase(itemId)
        // Additional logic for helper animals
    }
    
    /// Process the result of purchasing a power boost
    func processPowerBoostPurchase(_ itemId: String) {
        recordPurchase(itemId)
        
        // Apply the boost based on which one was purchased
        if itemId.contains("Health") {
            playerHealth = Int(Double(playerHealth) * 1.2) // 20% boost
        } else if itemId.contains("Strength") {
            playerStrength = Int(Double(playerStrength) * 1.2)
        } else if itemId.contains("Magic") {
            playerMagic = Int(Double(playerMagic) * 1.2)
        } else if itemId.contains("Speed") {
            playerSpeed = Int(Double(playerSpeed) * 1.2)
        }
        
        saveGameState()
    }
}
