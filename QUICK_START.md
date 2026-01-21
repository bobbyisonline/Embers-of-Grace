# Quick Start Guide - Embers of Grace

## Getting Started in 3 Minutes

### Step 1: Open in Godot
1. Download and install [Godot 4.3 or later](https://godotengine.org/download)
2. Launch Godot
3. Click "Import" and select this project's `project.godot` file
4. Click "Import & Edit"

### Step 2: Run the Combat Test
1. Press **F5** (or click the Play button in the top-right)
2. The combat test scene will launch with a grid and 4 units

### Step 3: Try the Combat System
1. **Click on Aldric or Elara** (blue units on the left)
   - Blue tiles show movement range
2. **Click a blue tile** to move your unit
   - After moving, red tiles show attack range
3. **Click a red tile with an enemy** to attack
4. **Press SPACE** to end your turn
   - Enemy units will take their turn (currently automatic)
5. **Press ESC** to deselect a unit

## What You're Seeing

### Units
- **Aldric (Blue, Sword)**: Tank/damage dealer, short range
- **Elara (Gold, Staff)**: Support with Grace abilities, medium range
- **Brigand (Red, Axe)**: Enemy melee unit
- **Raider (Red, Lance)**: Enemy melee unit

### Weapon Triangle
- Sword beats Axe (+2 damage)
- Axe beats Lance (+2 damage)
- Lance beats Sword (+2 damage)

### Combat Mechanics
- Damage = Attacker's Strength - Defender's Defense
- Critical hits possible (damage x3)
- Dodge chance based on unit stats
- Unit dies when HP reaches 0

## Project Overview

### What's Implemented
✅ Grid-based movement system
✅ Pathfinding (A* algorithm)
✅ Turn-based combat flow
✅ Attack calculations with weapon triangle
✅ Unit stats and health tracking
✅ Visual feedback (highlights, health bars)
✅ Event-driven architecture

### Key Files to Explore

**Core Systems:**
- `scripts/core/Constants.gd` - Game constants and enums
- `autoload/EventBus.gd` - Global event system
- `scripts/combat/GridManager.gd` - Grid and pathfinding
- `scripts/combat/CombatState.gd` - Combat state machine

**Unit System:**
- `scripts/units/Unit.gd` - Base unit class
- `scripts/units/UnitStats.gd` - Unit statistics resource

**Test Scene:**
- `scenes/combat/CombatTest.tscn` - Main test scene
- `scripts/combat/CombatTestController.gd` - Test initialization

## Customizing the Test Scene

### Add More Units
Edit `scripts/combat/CombatTestController.gd`, in the `_spawn_test_units()` function:

```gdscript
# Add a new player unit
_create_player_unit("NewHero", Vector2i(4, 4), Constants.WeaponType.LANCE)

# Add a new enemy
_create_enemy_unit("Boss", Vector2i(8, 5), Constants.WeaponType.SWORD)
```

### Change Grid Size
Edit `scripts/core/Constants.gd`:

```gdscript
const GRID_WIDTH: int = 20  # Default: 15
const GRID_HEIGHT: int = 15  # Default: 10
```

### Modify Unit Stats
Edit `scripts/combat/CombatTestController.gd`, in the unit creation functions:

```gdscript
stats.max_hp = 30  # More HP
stats.strength = 10  # More damage
stats.movement_range = 7  # Farther movement
```

## Camera Controls

- **WASD** or **Arrow Keys**: Pan camera
- **Mouse Wheel** (future): Zoom in/out

## Debug Mode

Debug mode is enabled by default. To toggle:
1. Open `scripts/core/Constants.gd`
2. Change `const DEBUG_MODE: bool = false`

With debug mode on, you'll see console output for:
- Combat calculations
- State transitions
- Event emissions
- Grid operations

## Troubleshooting

### "Scene not found" error
- Make sure you imported the project correctly
- Check that all scenes are in the `scenes/` folder

### Units don't respond to clicks
- Verify EventBus is configured in Project Settings > Autoload
- Check that GridCell has an InputArea node with collision shape

### Units move through each other
- The GridManager tracks occupancy
- Only one unit can occupy a cell at a time
- Check that `is_occupied` is being set correctly

### Attack does no damage
- Check weapon types (weapon triangle may give disadvantage)
- Verify unit stats in UnitStats resource
- Look for dodge/critical hit messages in console

## Next Steps

1. **Explore the code**: Start with `CombatTestController.gd` to see how units are created
2. **Modify unit stats**: Experiment with different builds
3. **Add terrain**: Modify `GridCell.gd` to add terrain types
4. **Implement AI**: Add enemy behavior in `CombatState.gd`
5. **Create new abilities**: Extend the `Unit.gd` class

## Architecture Highlights

### Event-Driven Design
Systems communicate via signals through the EventBus:
```gdscript
EventBus.unit_moved.emit(unit, from_pos, to_pos)
EventBus.unit_attacked.emit(attacker, target, damage)
```

### Resource-Based Data
Unit stats are Resources, editable in the inspector:
```gdscript
var stats = UnitStats.new()
stats.max_hp = 25
stats.strength = 8
```

### State Machine
Combat flow managed by states:
- IDLE → SELECTING → MOVING → ATTACKING → IDLE

### Component Composition
Units are composed of reusable parts:
- UnitStats (data)
- Unit (behavior)
- Sprite2D (visuals)
- HealthBar (UI)

## Learning Resources

- [Godot Documentation](https://docs.godotengine.org/en/stable/)
- [GDScript Reference](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/)
- [Godot Signals Tutorial](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html)

## Need Help?

Check these files:
- `README.md` - Full project overview
- `PROJECT_STRUCTURE.md` - Folder organization
- This file - Quick start guide

---

**Ready to build a tactical RPG? Let's get started!** 🎮
