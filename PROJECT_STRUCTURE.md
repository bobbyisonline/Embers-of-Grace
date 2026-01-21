# Embers of Grace - Project Structure

## Overview
This document describes the organization of the Godot 4 project for Embers of Grace.

## Directory Structure

### `/scenes/`
Contains all .tscn scene files organized by system.

- **main/** - Core scenes (MainMenu, GameOver, Credits)
- **combat/** - Tactical combat scenes (CombatArena, TurnManager)
- **exploration/** - Overworld exploration scenes (WorldMap, Locations)
- **ui/** - UI scenes (HUD, InventoryMenu, DialogueBox, CharacterSheet)
- **units/** - Unit/character scene templates (PlayerUnit, EnemyUnit)

### `/scripts/`
Contains all GDScript (.gd) files organized by system.

- **core/** - Core game systems (GameManager, SaveSystem, Constants)
- **combat/** - Combat logic (GridManager, TurnSystem, CombatState, PathfindingBattleCalculator)
- **units/** - Unit behavior and stats (Unit base class, UnitStats, UnitMovement)
- **items/** - Item system (Item base class, Weapon, Armor, Consumable)
- **world/** - World/exploration systems (WorldState, EncounterManager, DayNightCycle)
- **narrative/** - Dialogue and story (DialogueManager, QuestManager, RelationshipSystem)
- **ui/** - UI controllers (MenuController, InventoryUI, CombatUI)
- **ai/** - Enemy AI behavior (AIController, BehaviorTrees, TacticalAI)

### `/resources/`
Custom Resource definitions (.tres files and resource scripts).

- **units/** - Unit stat blocks and templates
- **items/** - Item definitions (weapons, armor, consumables, relics)
- **abilities/** - Ability/skill definitions (including Grace abilities)
- **classes/** - Character class definitions (Knight, Brigand, Cleric, etc.)
- **enemies/** - Enemy templates and AI behavior resources

### `/assets/`
All art, audio, and font assets.

- **sprites/**
  - units/ - Character and enemy sprites
  - environment/ - Tiles, buildings, terrain
  - ui/ - UI elements, icons, borders
  - effects/ - Visual effects (particles, animations)
- **audio/**
  - music/ - Background music tracks
  - sfx/ - Sound effects
- **fonts/** - Medieval-style fonts for UI

### `/data/`
JSON or external data files for content that may be edited outside Godot.

- **dialogues/** - Dialogue trees and conversation data
- **quests/** - Quest definitions and objectives
- **loot_tables/** - Drop tables for enemies and containers

### `/autoload/`
Singleton scripts that are auto-loaded at game start.

- GameManager.gd - Global game state coordination
- EventBus.gd - Global event signaling system
- SaveManager.gd - Save/load functionality
- AudioManager.gd - Audio playback coordination

### `/addons/`
Third-party Godot plugins or custom editor tools.

## Key Architectural Patterns

### State Machine
Combat flow uses a finite state machine pattern:
- PlayerTurnState
- EnemyTurnState
- AnimationState
- SelectionState
- MoveState
- AttackState

### Signal-Based Communication
Heavy use of Godot signals to decouple systems:
- EventBus autoload for global events
- Units emit signals for movement, damage, death
- UI listens to game state signals

### Resource-Based Data
Game data (units, items, abilities) defined as custom Resources:
- Allows editing in Godot inspector
- Easily serializable for save system
- Can be loaded/unloaded dynamically

### Component Composition
Units composed of reusable components:
- UnitStats (HP, Strength, Defense, etc.)
- UnitMovement (grid movement logic)
- UnitCombat (attack/defend behavior)
- UnitInventory (equipment and items)

## Naming Conventions

- **Scenes**: PascalCase (PlayerUnit.tscn, CombatArena.tscn)
- **Scripts**: PascalCase, matching scene name if scene-specific (PlayerUnit.gd)
- **Resources**: snake_case (aldric_stats.tres, iron_sword.tres)
- **Variables/Functions**: snake_case (current_hp, calculate_damage())
- **Constants**: UPPER_SNAKE_CASE (MAX_PARTY_SIZE, WEAPON_TYPE_SWORD)
- **Signals**: snake_case with descriptive names (unit_moved, turn_ended, dialogue_started)

## Next Steps

1. Implement base classes in `/scripts/core/` and `/scripts/units/`
2. Create grid system in `/scripts/combat/`
3. Build prototype unit and test scene
4. Expand from working foundation
