# Embers of Grace

A tactical turn-based RPG set during the Black Plague in 14th century England, built with Godot 4.

## Story

Follow the journey of Sir Aldric, a dishonored knight turned brigand, and Elara, a mysterious girl believed to carry divine grace, as they navigate a dying land plagued by cosmic horrors and human cruelty.

## Current Status

**Prototype Phase** - Basic combat system implemented

### Completed Features

- Grid-based tactical combat system (15x10)
- Unit movement with pathfinding (A* algorithm)
- Turn-based combat flow (player/enemy phases)
- Basic unit stats system (HP, Strength, Defense, Speed, Faith, Luck)
- Weapon triangle advantage system (Sword > Axe > Lance > Sword)
- Movement range calculation with terrain costs
- Attack range display and targeting
- State machine for combat actions
- Event bus for decoupled system communication
- Health bars and visual feedback

### Test Scene Features

The current build includes a combat test scene with:
- 2 player units (Aldric with sword, Elara with staff)
- 2 enemy units (Brigand with axe, Raider with lance)
- Interactive grid with click-to-move/attack
- Turn management (SPACE to end turn)
- Camera controls (WASD/Arrow keys)

## How to Run

1. **Install Godot 4.3+**
   - Download from [godotengine.org](https://godotengine.org/)

2. **Open Project**
   - Launch Godot
   - Click "Import"
   - Navigate to this folder and select `project.godot`
   - Click "Import & Edit"

3. **Run the Combat Test**
   - Press F5 or click the Play button
   - The combat test scene will launch automatically

## Controls

- **Left Click**: Select unit, choose move/attack destination
- **WASD / Arrow Keys**: Move camera
- **SPACE**: End player turn
- **ESC**: Deselect unit

## Project Structure

See [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) for detailed organization.

```
/scenes/          # Scene files (.tscn)
  /combat/        # Combat-related scenes
  /units/         # Unit templates
  /ui/            # UI scenes

/scripts/         # GDScript files
  /core/          # Core systems (Constants, etc.)
  /combat/        # Combat logic (GridManager, CombatState)
  /units/         # Unit classes (Unit, UnitStats)

/autoload/        # Singleton scripts
  EventBus.gd     # Global event system

/resources/       # Custom resources
/assets/          # Art, audio, fonts
/data/            # External data files
```

## Core Systems

### Grid System
- 15x10 grid with 64px cells
- Supports multiple terrain types (plains, forest, mountain, water, buildings, plague zones)
- Dynamic movement cost based on terrain
- Pathfinding using A* algorithm

### Unit System
- Stats-based combat (Strength vs Defense)
- Movement range calculation via BFS
- Weapon types and advantage system
- Critical hits and dodge mechanics
- Level-up system with growth rates
- Grace system for Elara (unique abilities)

### Combat Flow
- Player phase → Enemy phase → repeat
- Select unit → Show movement range → Move → Show attack range → Attack
- Turn-based with initiative order (planned)

### Event System
- Global EventBus for decoupled communication
- Signals for combat events, unit actions, UI updates
- Easy to extend and debug

## Next Development Steps

### Phase 1: Core Combat Polish
- [ ] Enemy AI (basic tactical behavior)
- [ ] Combat animations (attack, damage, death)
- [ ] UI improvements (unit info panel, action menu)
- [ ] Victory/defeat conditions
- [ ] Multiple battle scenarios

### Phase 2: Character Systems
- [ ] Inventory system (weapons, armor, consumables)
- [ ] Equipment and stat bonuses
- [ ] Character classes (Knight, Brigand, Cleric, Plague Doctor)
- [ ] Elara's Grace abilities (Heal, Protect, Reveal)
- [ ] Permadeath option

### Phase 3: World Exploration
- [ ] Overworld map system
- [ ] Location discovery and travel
- [ ] Random encounter system
- [ ] Day/night cycle
- [ ] Plague zones and environmental hazards

### Phase 4: Narrative
- [ ] Dialogue system
- [ ] Quest system
- [ ] Character relationship/bond system
- [ ] Branching story choices
- [ ] Save/load system

### Phase 5: Content
- [ ] Character roster (10+ recruitable units)
- [ ] Enemy variety (brigands, plague victims, cosmic horrors)
- [ ] Locations (villages, monasteries, ruins)
- [ ] Pixel art sprites and animations
- [ ] Medieval-inspired UI art
- [ ] Music and sound effects

## Design Philosophy

- **No over-engineering**: Keep systems simple and focused
- **Fire Emblem inspiration**: Classic tactical RPG mechanics
- **Dark atmosphere**: Somber tone with moments of hope
- **Meaningful choices**: Permadeath, branching dialogue, consequences
- **Scavenging survival**: Resource management appropriate to setting

## Technical Notes

- Built for Godot 4.3+
- GDScript for game logic
- Resource-based data for easy editing
- Signal-based architecture for maintainability
- Component-style unit composition
- State machine for complex flow control

## Theme & Setting

**14th Century England during the Black Plague**
- Historical backdrop with dark fantasy elements
- Cosmic horror influences (things beyond comprehension)
- Moral ambiguity (survival vs. honor)
- Religious themes (faith, doubt, divine grace)
- Social collapse and human cruelty

## Contributing

This is a personal/learning project. Feedback and suggestions welcome.

## License

TBD

---

**Current Version**: 0.1.0 - Prototype
**Engine**: Godot 4.3
**Target Platform**: PC (Windows/Linux/Mac)
