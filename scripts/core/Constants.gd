extends Node
class_name Constants

## Game-wide constants for Embers of Grace

# Grid Settings
const GRID_CELL_SIZE: int = 64  # Size of each grid cell in pixels
const GRID_WIDTH: int = 15
const GRID_HEIGHT: int = 10

# Unit Stats
const MAX_LEVEL: int = 20
const BASE_HP: int = 20
const BASE_STRENGTH: int = 5
const BASE_DEFENSE: int = 3
const BASE_SPEED: int = 5
const BASE_FAITH: int = 0
const BASE_LUCK: int = 5

# Movement
const DEFAULT_MOVE_RANGE: int = 5
const CAVALRY_MOVE_RANGE: int = 8
const ARMORED_MOVE_RANGE: int = 3

# Combat
enum DamageType { PHYSICAL, FAITH, PLAGUE }
enum WeaponType { SWORD, AXE, LANCE, BOW, STAFF, RELIC }
enum TerrainType { PLAINS, FOREST, MOUNTAIN, WATER, ROAD, BUILDING, PLAGUE_ZONE }
enum UnitClass { KNIGHT, BRIGAND, CLERIC, PLAGUE_DOCTOR, ARCHER, CAVALIER }

# Weapon Triangle Advantages
const WEAPON_ADVANTAGE_BONUS: int = 2
const WEAPON_DISADVANTAGE_PENALTY: int = -2

# Equipment Slots
enum EquipSlot { WEAPON, ARMOR, ACCESSORY, RELIC }

# Turn States
enum TurnPhase { PLAYER, ENEMY, EVENT }
enum ActionState { IDLE, SELECTING, MOVING, ATTACKING, USING_ITEM, ANIMATING }

# UI
const TILE_HIGHLIGHT_COLOR_MOVE: Color = Color(0.3, 0.5, 1.0, 0.4)  # Blue for movement
const TILE_HIGHLIGHT_COLOR_ATTACK: Color = Color(1.0, 0.3, 0.3, 0.4)  # Red for attack range
const TILE_HIGHLIGHT_COLOR_SELECTED: Color = Color(1.0, 1.0, 0.5, 0.6)  # Yellow for selected

# Pathfinding
const MOVEMENT_COST_DEFAULT: int = 1
const MOVEMENT_COST_FOREST: int = 2
const MOVEMENT_COST_MOUNTAIN: int = 3
const MOVEMENT_COST_IMPASSABLE: int = 999

# Grace System (Elara's unique abilities)
const GRACE_COST_HEAL: int = 1
const GRACE_COST_PROTECT: int = 2
const GRACE_COST_REVEAL: int = 1
const MAX_GRACE_POINTS: int = 10

# Save System
const SAVE_FILE_PATH: String = "user://embers_save.dat"
const AUTOSAVE_ENABLED: bool = true

# Debug
const DEBUG_MODE: bool = true
const SHOW_GRID_COORDINATES: bool = true
