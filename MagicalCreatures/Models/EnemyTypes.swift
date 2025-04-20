import Foundation

/// Extension to Enemy class containing enemy type definitions
extension Enemy {
    /// Enum defining the different types of enemies in the game
    enum EnemyType: String {
        case shadowScout = "shadowScout"     // Basic enemy
        case cageMaster = "cageMaster"       // Guards animals
        case darkKnight = "darkKnight"       // Stronger enemy with shield
        case shadowMage = "shadowMage"       // Ranged attacker
        case lordObsidian = "lordObsidian"   // Final boss
        
        var baseHealth: Int {
            switch self {
            case .shadowScout: return 15
            case .cageMaster: return 25
            case .darkKnight: return 40
            case .shadowMage: return 20
            case .lordObsidian: return 100
            }
        }
        
        var baseStrength: Int {
            switch self {
            case .shadowScout: return 3
            case .cageMaster: return 5
            case .darkKnight: return 7
            case .shadowMage: return 4
            case .lordObsidian: return 12
            }
        }
        
        var baseMagic: Int {
            switch self {
            case .shadowScout: return 0
            case .cageMaster: return 0
            case .darkKnight: return 2
            case .shadowMage: return 8
            case .lordObsidian: return 10
            }
        }
        
        var baseSpeed: Int {
            switch self {
            case .shadowScout: return 6
            case .cageMaster: return 4
            case .darkKnight: return 3
            case .shadowMage: return 5
            case .lordObsidian: return 4
            }
        }
        
        var textureName: String {
            return "enemy_\(self.rawValue)"
        }
        
        var isRanged: Bool {
            switch self {
            case .shadowMage, .lordObsidian:
                return true
            default:
                return false
            }
        }
        
        var experienceValue: Int {
            switch self {
            case .shadowScout: return 10
            case .cageMaster: return 15
            case .darkKnight: return 25
            case .shadowMage: return 20
            case .lordObsidian: return 100
            }
        }
        
        var dropChance: Int {
            switch self {
            case .shadowScout: return 20 // 20% chance to drop
            case .cageMaster: return 40 // 40% chance to drop
            case .darkKnight: return 60 // 60% chance to drop
            case .shadowMage: return 75 // 75% chance to drop
            case .lordObsidian: return 100 // 100% chance to drop (boss always drops)
            }
        }
        
        var possibleDrops: [String] {
            switch self {
            case .shadowScout:
                return ["HealthPotion", "Arrow"]
            case .cageMaster:
                return ["HealthPotion", "Arrow", "Key"]
            case .darkKnight:
                return ["HealthPotion", "MagicPotion", "StrongArrow"]
            case .shadowMage:
                return ["MagicPotion", "ScrollOfProtection", "HealthPotion"]
            case .lordObsidian:
                return ["LegendaryItem", "MagicGem", "ScrollOfPower", "MasterKey"]
            }
        }
        
        var description: String {
            switch self {
            case .shadowScout:
                return "Fast scouts who patrol the forest edges looking for intruders. They are weak but alert."
            case .cageMaster:
                return "Specialized in capturing and containing magical creatures. They carry nets and keys to animal cages."
            case .darkKnight:
                return "Heavily armored warriors with shields. They are slow but can withstand significant damage."
            case .shadowMage:
                return "Manipulators of dark magic who attack from a distance. They are physically weak but their spells are dangerous."
            case .lordObsidian:
                return "The leader of the Shadow Keepers. Powerful in both physical strength and magical abilities."
            }
        }
        
        var weakness: String {
            switch self {
            case .shadowScout:
                return "Their light armor makes them vulnerable to strong attacks."
            case .cageMaster:
                return "Slow movement makes them easy to hit with ranged attacks."
            case .darkKnight:
                return "Their heavy armor slows them down and makes them vulnerable to magic."
            case .shadowMage:
                return "Physically weak and vulnerable in close combat."
            case .lordObsidian:
                return "Pride makes him predictable. Dodge his powerful attacks and strike when he's recovering."
            }
        }
    }
}
