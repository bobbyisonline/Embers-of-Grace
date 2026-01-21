extends Node

## Global event bus for decoupled communication between systems
## Autoloaded as singleton

# Combat Events
signal combat_started()
signal combat_ended(victory: bool)
signal turn_started(phase: Constants.TurnPhase)
signal turn_ended(phase: Constants.TurnPhase)
signal unit_selected(unit: Node)
signal unit_deselected()

# Unit Events
signal unit_moved(unit: Node, from_cell: Vector2i, to_cell: Vector2i)
signal unit_attacked(attacker: Node, target: Node, damage: int)
signal unit_damaged(unit: Node, damage: int, remaining_hp: int)
signal unit_healed(unit: Node, amount: int)
signal unit_died(unit: Node)
signal unit_level_up(unit: Node, new_level: int)

# Grid Events
signal cell_hovered(cell_pos: Vector2i)
signal cell_clicked(cell_pos: Vector2i)
signal movement_range_displayed(cells: Array[Vector2i])
signal attack_range_displayed(cells: Array[Vector2i])
signal ranges_cleared()

# UI Events
signal dialogue_started(dialogue_id: String)
signal dialogue_ended()
signal menu_opened(menu_name: String)
signal menu_closed(menu_name: String)
signal inventory_changed()

# World Events
signal day_night_changed(is_day: bool)
signal encounter_triggered(encounter_data: Dictionary)
signal location_discovered(location_name: String)
signal quest_updated(quest_id: String, status: String)

# Grace Events (Elara-specific)
signal grace_used(ability_name: String, grace_cost: int)
signal grace_restored(amount: int)

# Save/Load Events
signal game_saved()
signal game_loaded()

# Helper function to emit with debug logging
func emit_debug(signal_name: String, args: Array = []) -> void:
	if Constants.DEBUG_MODE:
		print("[EventBus] Emitting: ", signal_name, " with args: ", args)

	match args.size():
		0: emit_signal(signal_name)
		1: emit_signal(signal_name, args[0])
		2: emit_signal(signal_name, args[0], args[1])
		3: emit_signal(signal_name, args[0], args[1], args[2])
		_: push_error("Too many arguments for signal emission")
