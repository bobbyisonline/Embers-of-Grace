extends Node2D

## Controller for the combat test scene
## Spawns test units and initializes combat

@export var player_unit_scene: PackedScene
@export var enemy_unit_scene: PackedScene

@onready var grid_manager: GridManager = $GridManager
@onready var combat_state: CombatState = $CombatState
@onready var turn_label: Label = $UI/TurnLabel

var player_units: Array[Unit] = []
var enemy_units: Array[Unit] = []

func _ready() -> void:
	# Wait for grid to initialize
	await grid_manager.grid_initialized

	# Create test units
	_spawn_test_units()

	# Connect signals
	combat_state.phase_changed.connect(_on_phase_changed)

	# Start combat
	combat_state.start_player_turn()

## Spawn test units for prototyping
func _spawn_test_units() -> void:
	# Load unit scene
	if not player_unit_scene:
		player_unit_scene = load("res://scenes/units/Unit.tscn")

	# Create player units
	_create_player_unit("Aldric", Vector2i(2, 4), Constants.WeaponType.SWORD)
	_create_player_unit("Elara", Vector2i(3, 5), Constants.WeaponType.STAFF, true)

	# Create enemy units
	_create_enemy_unit("Brigand", Vector2i(10, 4), Constants.WeaponType.AXE)
	_create_enemy_unit("Raider", Vector2i(11, 5), Constants.WeaponType.LANCE)

## Create a player-controlled unit
func _create_player_unit(unit_name: String, pos: Vector2i, weapon: Constants.WeaponType, has_grace: bool = false) -> Unit:
	var unit = player_unit_scene.instantiate() as Unit

	# Create stats
	var stats = UnitStats.new()
	stats.unit_name = unit_name
	stats.max_hp = 25
	stats.current_hp = 25
	stats.strength = 8
	stats.defense = 5
	stats.speed = 7
	stats.movement_range = 5
	stats.weapon_type = weapon

	if has_grace:
		stats.has_grace = true
		stats.grace_points = 5
		stats.attack_range = 2  # Elara has range
		stats.weapon_type = Constants.WeaponType.STAFF

	unit.stats = stats
	unit.is_player_controlled = true

	# Create a simple sprite texture
	var sprite_texture = _create_unit_texture(Color(0.3, 0.5, 1.0) if not has_grace else Color(1.0, 0.9, 0.4))
	unit.sprite_texture = sprite_texture

	# Add to scene and grid
	grid_manager.add_child(unit)
	grid_manager.place_unit(unit, pos)
	player_units.append(unit)

	return unit

## Create an enemy unit
func _create_enemy_unit(unit_name: String, pos: Vector2i, weapon: Constants.WeaponType) -> Unit:
	var unit = player_unit_scene.instantiate() as Unit

	# Create stats
	var stats = UnitStats.new()
	stats.unit_name = unit_name
	stats.max_hp = 20
	stats.current_hp = 20
	stats.strength = 6
	stats.defense = 3
	stats.speed = 5
	stats.movement_range = 4
	stats.weapon_type = weapon

	unit.stats = stats
	unit.is_player_controlled = false

	# Create a simple sprite texture (red for enemies)
	var sprite_texture = _create_unit_texture(Color(1.0, 0.3, 0.3))
	unit.sprite_texture = sprite_texture

	# Add to scene and grid
	grid_manager.add_child(unit)
	grid_manager.place_unit(unit, pos)
	enemy_units.append(unit)

	return unit

## Create a simple colored texture for unit sprites
func _create_unit_texture(color: Color) -> ImageTexture:
	var size = 48
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)

	# Draw a simple character shape
	for x in range(size):
		for y in range(size):
			var center = Vector2(size / 2, size / 2)
			var pos = Vector2(x, y)
			var dist = pos.distance_to(center)

			if dist < size / 2 - 2:
				image.set_pixel(x, y, color)
			elif dist < size / 2:
				image.set_pixel(x, y, color.darkened(0.3))

	return ImageTexture.create_from_image(image)

## Handle phase changes
func _on_phase_changed(old_phase: Constants.TurnPhase, new_phase: Constants.TurnPhase) -> void:
	match new_phase:
		Constants.TurnPhase.PLAYER:
			turn_label.text = "Player Turn"
			turn_label.modulate = Color(0.4, 0.7, 1.0)
		Constants.TurnPhase.ENEMY:
			turn_label.text = "Enemy Turn"
			turn_label.modulate = Color(1.0, 0.4, 0.4)

func _input(event: InputEvent) -> void:
	# Press SPACE to end player turn
	if event.is_action_pressed("ui_accept"):
		if combat_state.current_phase == Constants.TurnPhase.PLAYER:
			combat_state.start_enemy_turn()

	# Press ESC to deselect
	if event.is_action_pressed("ui_cancel"):
		EventBus.unit_deselected.emit()

	# Camera controls
	if event.is_action_pressed("ui_up"):
		$Camera2D.position.y -= 32
	if event.is_action_pressed("ui_down"):
		$Camera2D.position.y += 32
	if event.is_action_pressed("ui_left"):
		$Camera2D.position.x -= 32
	if event.is_action_pressed("ui_right"):
		$Camera2D.position.x += 32
