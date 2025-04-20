import Foundation
import SpriteKit

/**
 * CharacterData
 * 
 * Contains data structures and models for character stats, abilities, and appearances.
 * Provides a centralized location for character-related configuration and data.
 */

// MARK: - Character Types and Appearances

/// Enum defining available character types
enum CharacterType: String, Codable, CaseIterable {
    case centaur = "Centaur"
    case bird = "Bird"
    
    /// Default stats for each character type
    var baseStats: CharacterStats {
        switch self {
        case .centaur:
            return CharacterStats(
                health: 100,
                strength: 8,
                magic: 5,
                speed: 6
            )
        case .bird:
            return CharacterStats(
                health: 70,
                strength: 6,
                magic: 8,
                speed: 9
            )
        }
    }
    
    /// Available appearances for each character type
    var availableAppearances: [CharacterAppearance] {
        switch self {
        case .centaur:
            return [.default, .forest, .warrior, .royal]
        case .bird:
            return [.default, .tropical, .mystic, .arctic]
        }
    }
    
    /// Starting abilities for each character type
    var startingAbilities: [AbilityType] {
        switch self {
        case .centaur:
            return [.bowShot, .rearKick]
        case .bird:
            return [.diveBomb, .sonicCall]
        }
    }
    
    /// All abilities for each character type (including unlockable ones)
    var allAbilities: [AbilityType] {
        switch self {
        case .centaur:
            return [.bowShot, .rearKick, .healingTouch, .stampedeDash, .naturesBond]
        case .bird:
            return [.diveBomb, .sonicCall, .featherShield, .windGuard, .naturalHealing]
        }
    }
    
    /// Description of the character type
    var description: String {
        switch self {
        case .centaur:
            return "A powerful centaur with archery skills and nature magic."
        case .bird:
            return "A swift magical bird with aerial abilities and healing powers."
        }
    }
}

/// Enum defining character appearances
enum CharacterAppearance: String, Codable {
    case `default` = "default"
    case forest = "forest"
    case warrior = "warrior"
    case royal = "royal"
    case tropical = "tropical"
    case mystic = "mystic"
    case arctic = "arctic"
    
    /// Description of the appearance
    var description: String {
        switch self {
        case .default: return "Classic appearance"
        case .forest: return "Forest guardian"
        case .warrior: return "Battle-hardened warrior"
        case .royal: return "Noble royal guardian"
        case .tropical: return "Colorful tropical plumage"
        case .mystic: return "Mystical ethereal feathers"
        case .arctic: return "Snowy ice variant"
        }
    }
    
    /// Requirements to unlock this appearance
    var unlockRequirement: String {
        switch self {
        case .default:
            return "Available from the start"
        case .forest, .tropical:
            return "Complete 3 levels in the forest area"
        case .warrior, .mystic:
            return "Defeat 50 enemies"
        case .royal, .arctic:
            return "Collect all magical artifacts"
        }
    }
    
    /// Whether the appearance is premium content
    var isPremium: Bool {
        switch self {
        case .default, .forest, .tropical:
            return false
        case .warrior, .royal, .mystic, .arctic:
            return true
        }
    }
}

// MARK: - Character Stats

/// Structure to hold character statistics
struct CharacterStats: Codable {
    var health: Int
    var strength: Int
    var magic: Int
    var speed: Int
    
    /// Calculate combat power based on stats
    var combatPower: Int {
        return health / 10 + strength * 2 + magic * 2 + speed
    }
    
    /// Create default stats structure
    static func defaultStats() -> CharacterStats {
        return CharacterStats(
            health: 100,
            strength: 5,
            magic: 5,
            speed: 5
        )
    }
}

// MARK: - Character Abilities

/// Enum defining ability types
enum AbilityType: String, Codable, CaseIterable {
    // Centaur abilities
    case bowShot = "BowShot"
    case rearKick = "RearKick"
    case healingTouch = "HealingTouch"
    case stampedeDash = "StampedeDash"
    case naturesBond = "NaturesBond"
    
    // Bird abilities
    case diveBomb = "DiveBomb"
    case sonicCall = "SonicCall"
    case featherShield = "FeatherShield"
    case windGuard = "WindGuard"
    case naturalHealing = "NaturalHealing"
    
    /// Description of the ability
    var description: String {
        switch self {
        // Centaur abilities
        case .bowShot: return "Fire an arrow at a target"
        case .rearKick: return "Powerful kick that stuns enemies"
        case .healingTouch: return "Heal yourself or allies"
        case .stampedeDash: return "Dash forward, damaging enemies in path"
        case .naturesBond: return "Summon animal spirits for stat boost"
            
        // Bird abilities
        case .diveBomb: return "Dive attack from above"
        case .sonicCall: return "Stun enemies with a loud call"
        case .featherShield: return "Protective shield of feathers"
        case .windGuard: return "Create wind to deflect projectiles"
        case .naturalHealing: return "Heal over time with natural magic"
        }
    }
    
    /// Base cooldown time for the ability in seconds
    var cooldown: TimeInterval {
        switch self {
        case .bowShot, .diveBomb:
            return 1.0
        case .rearKick, .sonicCall:
            return 2.0
        case .healingTouch, .featherShield, .naturalHealing:
            return 10.0
        case .stampedeDash, .windGuard:
            return 6.0
        case .naturesBond:
            return 30.0
        }
    }
    
    /// Mana cost for using the ability
    var manaCost: Int {
        switch self {
        case .bowShot, .rearKick, .diveBomb, .sonicCall:
            return 0
        case .healingTouch, .featherShield, .naturalHealing:
            return 3
        case .stampedeDash, .windGuard:
            return 2
        case .naturesBond:
            return 5
        }
    }
    
    /// Level required to unlock the ability
    var unlockLevel: Int {
        switch self {
        case .bowShot, .rearKick, .diveBomb, .sonicCall:
            return 1 // Available from the start
        case .healingTouch, .featherShield:
            return 3
        case .stampedeDash, .windGuard:
            return 5
        case .naturesBond, .naturalHealing:
            return 8
        }
    }
    
    /// Icon name for the ability
    var iconName: String {
        return "ability_\(self.rawValue.lowercased())"
    }
}

/// Structure to define an ability's configuration and effects
struct AbilityConfig {
    let type: AbilityType
    let cooldown: TimeInterval
    let manaCost: Int
    let damage: Int?
    let healAmount: Int?
    let effectDuration: TimeInterval?
    let range: CGFloat
    
    /// Create an ability configuration with default values based on the ability type
    static func defaultConfig(for abilityType: AbilityType) -> AbilityConfig {
        switch abilityType {
        case .bowShot:
            return AbilityConfig(
                type: abilityType,
                cooldown: 1.0,
                manaCost: 0,
                damage: 8,
                healAmount: nil,
                effectDuration: nil,
                range: 500.0
            )
        case .rearKick:
            return AbilityConfig(
                type: abilityType,
                cooldown: 2.0,
                manaCost: 0,
                damage: 12,
                healAmount: nil,
                effectDuration: 1.5, // Stun duration
                range: 100.0
            )
        case .healingTouch:
            return AbilityConfig(
                type: abilityType,
                cooldown: 10.0,
                manaCost: 3,
                damage: nil,
                healAmount: 25,
                effectDuration: nil,
                range: 150.0
            )
        case .stampedeDash:
            return AbilityConfig(
                type: abilityType,
                cooldown: 6.0,
                manaCost: 2,
                damage: 15,
                healAmount: nil,
                effectDuration: 0.4, // Dash duration
                range: 300.0
            )
        case .naturesBond:
            return AbilityConfig(
                type: abilityType,
                cooldown: 30.0,
                manaCost: 5,
                damage: nil,
                healAmount: nil,
                effectDuration: 10.0, // Buff duration
                range: 0.0
            )
        case .diveBomb:
            return AbilityConfig(
                type: abilityType,
                cooldown: 1.0,
                manaCost: 0,
                damage: 10,
                healAmount: nil,
                effectDuration: nil,
                range: 300.0
            )
        case .sonicCall:
            return AbilityConfig(
                type: abilityType,
                cooldown: 2.0,
                manaCost: 0,
                damage: 5,
                healAmount: nil,
                effectDuration: 2.0, // Stun duration
                range: 200.0
            )
        case .featherShield:
            return AbilityConfig(
                type: abilityType,
                cooldown: 10.0,
                manaCost: 3,
                damage: nil,
                healAmount: nil,
                effectDuration: 5.0, // Shield duration
                range: 0.0
            )
        case .windGuard:
            return AbilityConfig(
                type: abilityType,
                cooldown: 6.0,
                manaCost: 2,
                damage: nil,
                healAmount: nil,
                effectDuration: 3.0, // Deflection duration
                range: 150.0
            )
        case .naturalHealing:
            return AbilityConfig(
                type: abilityType,
                cooldown: 10.0,
                manaCost: 3,
                damage: nil,
                healAmount: 5, // Healing per second
                effectDuration: 5.0, // Healing duration
                range: 0.0
            )
        }
    }
}

// MARK: - Character Model

/// Main model class for storing complete character configuration
class CharacterModel {
    var type: CharacterType
    var appearance: CharacterAppearance
    var stats: CharacterStats
    var level: Int
    var experience: Int
    var unlockedAbilities: [AbilityType]
    
    /// Initialize a character with default values
    init(type: CharacterType, appearance: CharacterAppearance = .default) {
        self.type = type
        self.appearance = appearance
        self.stats = type.baseStats
        self.level = 1
        self.experience = 0
        self.unlockedAbilities = type.startingAbilities
    }
    
    /// Calculate experience needed for the next level
    func experienceForNextLevel() -> Int {
        return 100 * level * level
    }
    
    /// Add experience and handle level up if applicable
    func addExperience(_ amount: Int) -> Bool {
        let oldLevel = level
        experience += amount
        
        // Check for level up
        let requiredExperience = experienceForNextLevel()
        if experience >= requiredExperience {
            level += 1
            experience -= requiredExperience
            
            // Increase stats with level up
            stats.health += 10
            stats.strength += 1
            stats.magic += 1
            stats.speed += 1
            
            // Unlock abilities based on level
            for ability in type.allAbilities {
                if ability.unlockLevel <= level && !unlockedAbilities.contains(ability) {
                    unlockedAbilities.append(ability)
                }
            }
            
            return true // Level up occurred
        }
        
        return false // No level up
    }
    
    /// Check if an ability is unlocked
    func hasAbility(_ ability: AbilityType) -> Bool {
        return unlockedAbilities.contains(ability)
    }
    
    /// Save character data
    func save() {
        // In a full implementation, this would save to GameDataManager
        // For now, we'll just print confirmation
        print("Character data saved: \(type.rawValue), Level \(level)")
    }
}

// MARK: - Animation and Visual Data

/// Structure for storing character animation data
struct CharacterAnimationData {
    let characterType: CharacterType
    let appearance: CharacterAppearance
    
    /// Get all animation names for this character type
    var animationNames: [String] {
        switch characterType {
        case .centaur:
            return ["idle", "walk", "bowAttack", "kickAttack", "hit", "dash", "heal"]
        case .bird:
            return ["idle", "fly", "diveBomb", "sonicCall", "hit", "shield", "heal"]
        }
    }
    
    /// Get number of frames for a specific animation
    func frameCount(for animation: String) -> Int {
        switch animation {
        case "idle":
            return 4
        case "walk", "fly":
            return 6
        case "bowAttack", "dash", "heal":
            return 5
        case "kickAttack", "diveBomb", "sonicCall", "shield":
            return 4
        case "hit":
            return 2
        default:
            return 1
        }
    }
    
    /// Get base texture name for a specific animation frame
    func textureName(for animation: String, frameIndex: Int) -> String {
        let baseName = "\(characterType.rawValue.lowercased())_\(appearance.rawValue)"
        return "\(baseName)_\(animation)_\(frameIndex + 1)"
    }
    
    /// Load all textures for a specific animation
    func loadTextures(for animation: String) -> [SKTexture] {
        var textures: [SKTexture] = []
        
        for i in 0..<frameCount(for: animation) {
            let texture = SKTexture(imageNamed: textureName(for: animation, frameIndex: i))
            textures.append(texture)
        }
        
        return textures
    }
    
    /// Create an animation action for a specific animation
    func createAnimation(for animation: String, repeatForever: Bool = false, timePerFrame: TimeInterval = 0.1) -> SKAction {
        let textures = loadTextures(for: animation)
        let animateAction = SKAction.animate(with: textures, timePerFrame: timePerFrame)
        
        if repeatForever {
            return SKAction.repeatForever(animateAction)
        } else {
            return animateAction
        }
    }
    
    /// Run an animation on a sprite
    func runAnimation(on sprite: SKSpriteNode, animationName: String, repeatForever: Bool = false, completion: (() -> Void)? = nil) {
        // Stop any current animation
        sprite.removeAllActions()
        
        // Create the animation action
        let animateAction = createAnimation(for: animationName, repeatForever: repeatForever)
        
        // Run the animation
        if let completion = completion, !repeatForever {
            sprite.run(SKAction.sequence([animateAction, SKAction.run(completion)]))
        } else {
            sprite.run(animateAction)
        }
    }
}

// MARK: - Character Selection Data

/// Structure to organize character selection data for the UI
struct CharacterSelectionData {
    let types: [CharacterType] = CharacterType.allCases
    
    /// Get all unlocked character types
    func unlockedCharacterTypes() -> [CharacterType] {
        // In a real implementation, this would check GameDataManager
        // For now, we'll assume Centaur is always unlocked
        return [.centaur]
    }
    
    /// Get all unlocked appearances for a character type
    func unlockedAppearances(for characterType: CharacterType) -> [CharacterAppearance] {
        // In a real implementation, this would check GameDataManager
        // For now, we'll assume only default is unlocked
        return [.default]
    }
    
    /// Check if a character appearance is unlocked
    func isAppearanceUnlocked(_ appearance: CharacterAppearance, for characterType: CharacterType) -> Bool {
        // In a real implementation, this would check GameDataManager
        return appearance == .default
    }
    
    /// Get all unlocked abilities for a character type
    func unlockedAbilities(for characterType: CharacterType) -> [AbilityType] {
        // In a real implementation, this would check GameDataManager
        return characterType.startingAbilities
    }
    
    /// Check if an ability is unlocked
    func isAbilityUnlocked(_ ability: AbilityType, for characterType: CharacterType) -> Bool {
        // In a real implementation, this would check GameDataManager
        return characterType.startingAbilities.contains(ability)
    }
}
