# Magical Creatures - Game Design Document

## Story

### Setting
The game takes place in the enchanted kingdom of Animalia, a once-peaceful land where magical creatures and humans lived in harmony. The kingdom is divided into several regions: the Whispering Forest, the Sparkling Meadows, the Misty Mountains, and at its center, the grand Crystal Castle.

### Plot
Long ago, a group of greedy humans known as the "Shadow Keepers" took over the Crystal Castle, driving away the good humans and forcing the magical animals to hide in the wilderness. The animals are afraid to come out because the Shadow Keepers want to capture them for their magical powers.

Our hero, a brave centaur named Orion, lives peacefully in the Whispering Forest. One day, he meets a talking bird named Pip, who tells him about the plight of the animals and the evil humans in the castle. Orion, being half-human and half-horse, understands both worlds and decides to help free the animals and restore peace to the kingdom.

### Game Progression
1. **Forest Introduction**: Orion meets Pip and learns about the situation.
2. **Training Grounds**: Orion practices his abilities in a safe area of the forest.
3. **Rescue Missions**: Orion goes on missions to rescue captured animals from various locations.
4. **Castle Approach**: Orion must overcome obstacles to reach the castle.
5. **Castle Infiltration**: Sneaking into the castle and freeing more animals.
6. **Final Confrontation**: Facing the leader of the Shadow Keepers to save the kingdom.

## Characters

### Playable Character
- **Orion the Centaur**: A young, brave centaur with a kind heart. He has basic combat abilities with his bow and can perform special moves like dash and stomp.
  - Starting Stats: Health 20, Strength 5, Magic 3, Speed 7
  - Abilities: Bow Shot, Rear Kick, Healing Touch

### Main NPCs
- **Pip the Bird**: A small, clever blue bird who serves as Orion's guide and provides tips throughout the game.
- **Elder Oak**: An ancient talking tree who provides wisdom and upgrades to Orion's abilities.
- **Luna the Fox**: A magical fox who was once captured but escaped, now helps Orion with her illusion magic.
- **King Rowan**: The good king who was driven away from the castle, who Orion might eventually restore to the throne.

### Enemies
- **Shadow Scouts**: Basic enemy, patrols areas and alerts others if they spot Orion.
- **Cage Masters**: Enemies who guard captured animals, armed with nets and traps.
- **Dark Knights**: Stronger enemies with shields and swords, require strategy to defeat.
- **Shadow Mages**: Enemies with ranged magical attacks.
- **Lord Obsidian**: The leader of the Shadow Keepers and final boss.

## Game Mechanics

### Simplified D&D Mechanics

#### Core Stats
- **Health**: Represents hit points, decreases when taking damage.
- **Strength**: Affects physical attack damage.
- **Magic**: Affects magical ability power and resistance.
- **Speed**: Affects movement speed and evasion chance.

#### Action System
Instead of complex D&D turns, we use a simplified action system:
- Basic attacks are available anytime with a short cooldown (3 seconds)
- Special abilities have longer cooldowns (15-30 seconds)
- Items can be used at any time but are limited in quantity

#### Dice Rolling
To maintain some D&D flavor while keeping it simple for kids:
- Critical hits occur randomly (simulating a natural 20)
- Shown visually as dice appearing above characters
- Success/failure for certain actions shown as dice rolls
- All dice mechanics happen automatically, players don't need to understand the system

### Combat
- **Tap Attack**: Tap on enemies to perform basic attacks
- **Special Moves**: Swipe in specific patterns to trigger special abilities
- **Dodge**: Swipe to move quickly in a direction to avoid attacks
- **Health Potions**: Tap potion icon to restore health
- **Enemy Tells**: Enemies give clear visual cues before attacking

### Exploration
- **Movement**: Tap or drag to move Orion around the environment
- **Interactibles**: Objects that can be interacted with glow slightly
- **Hidden Areas**: Some paths are hidden and can be discovered by exploration
- **Animal Rescue**: Finding and freeing captured animals is a primary objective
- **Collectibles**: Magical items, potions, and special objects can be collected

### Progression System
- **Experience Points**: Earned by rescuing animals and completing objectives
- **Level Up**: Gain stat increases and new abilities
- **Ability Upgrades**: Existing abilities can be enhanced using magical gems
- **Equipment**: Find or earn new items like horseshoes, armor, and magical artifacts

### In-App Purchases Implementation
All purchases are optional and the game is balanced to be enjoyable without them:

- **Cosmetic Items**: Alternative appearances for Orion and visual effects for abilities
  - Implementation: Purely visual changes with no gameplay advantage
  
- **Helper Animals**: Additional animal companions that provide minor bonuses
  - Implementation: Give small advantages but not required for progression
  
- **Power Boosts**: Temporary stat increases
  - Implementation: Consumable items that provide a 20% increase to a stat for one level
  
- **Ad Removal**: Removes optional ad videos
  - Implementation: Ads only appear between levels and are never forced

## Level Design

### Tutorial Level: Whispering Woods
- Simple environment with clear paths
- Introduces basic movement and combat
- Few weak enemies to practice on
- Meeting with Pip and learning the story
- First animal rescue (a baby rabbit)

### Level Types
1. **Rescue Missions**: Find and free captured animals
2. **Stealth Sections**: Avoid being seen by patrols
3. **Combat Arenas**: Defeat waves of enemies
4. **Puzzle Areas**: Solve environmental puzzles to progress
5. **Boss Battles**: Face off against powerful enemies

### Environment Themes
1. **Whispering Forest**: Lush, green forest with magical elements
2. **Sparkling Meadows**: Open grasslands with flowers and streams
3. **Misty Mountains**: Foggy mountain paths with limited visibility
4. **Shadow Outposts**: Enemy camps with cages and dark elements
5. **Crystal Castle**: Grand, but corrupted by dark magic

## Interface

### HUD Elements
- Health bar (top left)
- Ability icons with cooldown indicators (bottom right)
- Mini-map (top right, can be expanded)
- Objective tracker (top center)
- Inventory quick access (bottom left)

### Menus
- **Main Menu**: Play, Settings, Store, Credits
- **Pause Menu**: Resume, Restart Level, Settings, Quit to Main Menu
- **Store**: Categories for different purchase types
- **Character Screen**: View stats, abilities, and equipment
- **Map Screen**: Overview of discovered areas

## Accessibility Features
- **Text Size Options**: Adjustable text size
- **Color Blind Mode**: Alternative color schemes
- **Simple Controls**: One-touch options for younger players
- **Reading Assistance**: Option for text to be read aloud
- **Difficulty Settings**: Adjust enemy difficulty and puzzle complexity
