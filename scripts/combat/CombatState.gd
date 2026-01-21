extends Node
class_name CombatState

## State machine for managing combat flow
## Handles turn phases and action states

signal state_changed(old_state: Constants.ActionState, new_state: Constants.ActionState)
signal phase_changed(old_phase: Constants.TurnPhase, new_phase: Constants.TurnPhase)

var current_state: Constants.ActionState = Constants.ActionState.IDLE
var current_phase: Constants.TurnPhase = Constants.TurnPhase.PLAYER
var selected_unit: Unit = null
var hovered_cell: Vector2i = Vector2i(-1, -1)

@onready var grid_manager: GridManager = get_node("../GridManager")

func _ready() -> void:
	_connect_signals()

## Connect to event bus signals
func _connect_signals() -> void:
	EventBus.unit_selected.connect(_on_unit_selected)
	EventBus.unit_deselected.connect(_on_unit_deselected)
	EventBus.cell_clicked.connect(_on_cell_clicked)
	EventBus.cell_hovered.connect(_on_cell_hovered)
	EventBus.turn_started.connect(_on_turn_started)

## Change current action state
func change_state(new_state: Constants.ActionState) -> void:
	if current_state == new_state:
		return

	var old_state = current_state
	current_state = new_state
	state_changed.emit(old_state, new_state)

	if Constants.DEBUG_MODE:
		print("[CombatState] State changed: %s -> %s" % [
			Constants.ActionState.keys()[old_state],
			Constants.ActionState.keys()[new_state]
		])

	_handle_state_enter(new_state)

## Change current turn phase
func change_phase(new_phase: Constants.TurnPhase) -> void:
	if current_phase == new_phase:
		return

	var old_phase = current_phase
	current_phase = new_phase
	phase_changed.emit(old_phase, new_phase)
	EventBus.turn_started.emit(new_phase)

	if Constants.DEBUG_MODE:
		print("[CombatState] Phase changed: %s -> %s" % [
			Constants.TurnPhase.keys()[old_phase],
			Constants.TurnPhase.keys()[new_phase]
		])

## Handle entering a new state
func _handle_state_enter(state: Constants.ActionState) -> void:
	match state:
		Constants.ActionState.IDLE:
			_enter_idle_state()
		Constants.ActionState.SELECTING:
			_enter_selecting_state()
		Constants.ActionState.MOVING:
			_enter_moving_state()
		Constants.ActionState.ATTACKING:
			_enter_attacking_state()

## Enter IDLE state
func _enter_idle_state() -> void:
	if selected_unit:
		selected_unit.deselect()
		selected_unit = null
	EventBus.ranges_cleared.emit()

## Enter SELECTING state
func _enter_selecting_state() -> void:
	if selected_unit:
		selected_unit.select()

		# Show movement range
		var movement_range = grid_manager.calculate_movement_range(selected_unit)
		grid_manager.highlight_movement_range(movement_range)
		EventBus.movement_range_displayed.emit(movement_range)

## Enter MOVING state
func _enter_moving_state() -> void:
	# Wait for destination selection
	pass

## Enter ATTACKING state
func _enter_attacking_state() -> void:
	if selected_unit:
		# Show attack range
		var attack_range = selected_unit.get_attack_range()
		grid_manager.highlight_attack_range(attack_range)
		EventBus.attack_range_displayed.emit(attack_range)

## Handle unit selection
func _on_unit_selected(unit: Node) -> void:
	if unit is Unit:
		selected_unit = unit
		change_state(Constants.ActionState.SELECTING)

## Handle unit deselection
func _on_unit_deselected() -> void:
	selected_unit = null
	change_state(Constants.ActionState.IDLE)

## Handle cell click based on current state
func _on_cell_clicked(cell_pos: Vector2i) -> void:
	match current_state:
		Constants.ActionState.IDLE:
			_handle_idle_click(cell_pos)
		Constants.ActionState.SELECTING:
			_handle_selecting_click(cell_pos)
		Constants.ActionState.MOVING:
			_handle_moving_click(cell_pos)
		Constants.ActionState.ATTACKING:
			_handle_attacking_click(cell_pos)

## Handle click in IDLE state - select a unit
func _handle_idle_click(cell_pos: Vector2i) -> void:
	var unit = grid_manager.get_unit_at(cell_pos)
	if unit and unit.is_player_controlled and current_phase == Constants.TurnPhase.PLAYER:
		if unit.can_act():
			EventBus.unit_selected.emit(unit)

## Handle click in SELECTING state - choose action or cancel
func _handle_selecting_click(cell_pos: Vector2i) -> void:
	if not selected_unit:
		return

	# If clicking on another unit, switch selection
	var clicked_unit = grid_manager.get_unit_at(cell_pos)
	if clicked_unit and clicked_unit != selected_unit:
		if clicked_unit.is_player_controlled and clicked_unit.can_act():
			EventBus.unit_deselected.emit()
			EventBus.unit_selected.emit(clicked_unit)
		return

	# If clicking on self, deselect
	if cell_pos == selected_unit.grid_position:
		EventBus.unit_deselected.emit()
		return

	# Check if cell is in movement range
	var movement_range = grid_manager.calculate_movement_range(selected_unit)
	if cell_pos in movement_range:
		# Initiate movement
		_initiate_movement(cell_pos)
	else:
		# Check if in attack range
		var attack_range = selected_unit.get_attack_range()
		if cell_pos in attack_range:
			_initiate_attack(cell_pos)

## Initiate unit movement
func _initiate_movement(destination: Vector2i) -> void:
	if not selected_unit:
		return

	change_state(Constants.ActionState.MOVING)

	var path = grid_manager.find_path(selected_unit.grid_position, destination, selected_unit)
	if path.is_empty():
		change_state(Constants.ActionState.SELECTING)
		return

	# Move unit
	grid_manager.move_unit(selected_unit, selected_unit.grid_position, destination)
	await selected_unit.move_to(destination)

	# After moving, show attack options
	if selected_unit.can_act():
		change_state(Constants.ActionState.ATTACKING)
	else:
		EventBus.unit_deselected.emit()

## Initiate attack on target
func _initiate_attack(target_pos: Vector2i) -> void:
	if not selected_unit:
		return

	var target = grid_manager.get_unit_at(target_pos)
	if not target or target.is_player_controlled:
		return

	change_state(Constants.ActionState.ATTACKING)
	await selected_unit.attack(target)

	EventBus.unit_deselected.emit()

## Handle click in MOVING state
func _handle_moving_click(cell_pos: Vector2i) -> void:
	# Movement is handled automatically in _initiate_movement
	pass

## Handle click in ATTACKING state
func _handle_attacking_click(cell_pos: Vector2i) -> void:
	if not selected_unit:
		return

	var target = grid_manager.get_unit_at(cell_pos)
	if target and not target.is_player_controlled:
		_initiate_attack(cell_pos)
	else:
		# Cancel attack, return to selecting
		change_state(Constants.ActionState.SELECTING)

## Handle cell hover
func _on_cell_hovered(cell_pos: Vector2i) -> void:
	hovered_cell = cell_pos
	# Future: Show preview info for hovered cell

## Handle turn start
func _on_turn_started(phase: Constants.TurnPhase) -> void:
	current_phase = phase
	change_state(Constants.ActionState.IDLE)

## Start player turn
func start_player_turn() -> void:
	change_phase(Constants.TurnPhase.PLAYER)

	# Reset all player units
	for unit in grid_manager.units.values():
		if unit.is_player_controlled:
			unit.start_turn()

## Start enemy turn
func start_enemy_turn() -> void:
	change_phase(Constants.TurnPhase.ENEMY)

	# Reset all enemy units
	for unit in grid_manager.units.values():
		if not unit.is_player_controlled:
			unit.start_turn()

	# TODO: Execute AI turns
	# For now, immediately end enemy turn
	await get_tree().create_timer(1.0).timeout
	start_player_turn()
