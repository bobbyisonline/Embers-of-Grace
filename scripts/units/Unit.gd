extends Node2D
class_name Unit

## Base class for all units (player party members and enemies)
## Handles position on grid, stats, and combat actions

signal moved(from_pos: Vector2i, to_pos: Vector2i)
signal attacked(target: Unit)
signal damaged(amount: int)
signal died()
signal action_completed()

@export var stats: UnitStats
@export var is_player_controlled: bool = true
@export var sprite_texture: Texture2D

var grid_position: Vector2i = Vector2i.ZERO
var has_acted_this_turn: bool = false
var has_moved_this_turn: bool = false
var is_selected: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var health_bar: ProgressBar = $HealthBar
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	_initialize_visuals()
	_connect_signals()
	update_health_bar()

## Initialize visual components
func _initialize_visuals() -> void:
	if sprite and sprite_texture:
		sprite.texture = sprite_texture
	if health_bar:
		health_bar.max_value = stats.max_hp
		health_bar.value = stats.current_hp

## Connect to event bus signals
func _connect_signals() -> void:
	died.connect(_on_died)

## Set unit's position on the grid
func set_grid_position(new_pos: Vector2i) -> void:
	var old_pos = grid_position
	grid_position = new_pos
	position = Vector2(new_pos.x * Constants.GRID_CELL_SIZE, new_pos.y * Constants.GRID_CELL_SIZE)

	if old_pos != new_pos:
		moved.emit(old_pos, new_pos)
		EventBus.unit_moved.emit(self, old_pos, new_pos)

## Get cells within movement range using BFS
func get_movement_range() -> Array[Vector2i]:
	# This will be calculated by GridManager using pathfinding
	var cells: Array[Vector2i] = []
	return cells

## Get cells within attack range from current position
func get_attack_range() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	var range_val = stats.attack_range

	# Get all cells within Manhattan distance
	for x in range(-range_val, range_val + 1):
		for y in range(-range_val, range_val + 1):
			if abs(x) + abs(y) <= range_val and (x != 0 or y != 0):
				cells.append(grid_position + Vector2i(x, y))

	return cells

## Move unit to target position with animation
func move_to(target_pos: Vector2i) -> void:
	has_moved_this_turn = true

	# Calculate target world position
	var target_world_pos = Vector2(
		target_pos.x * Constants.GRID_CELL_SIZE,
		target_pos.y * Constants.GRID_CELL_SIZE
	)

	# Smooth movement using Tween
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "position", target_world_pos, 0.3)
	await tween.finished

	# Update grid position after animation
	grid_position = target_pos

	action_completed.emit()

## Attack target unit
func attack(target: Unit) -> void:
	if not target or not target.stats.is_alive():
		return

	# Store original position
	var original_pos = position

	# Calculate direction to target (move halfway)
	var direction = (target.position - position).normalized()
	var attack_pos = position + direction * (Constants.GRID_CELL_SIZE * 0.4)

	# Attack animation: slide toward target
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "position", attack_pos, 0.15)
	await tween.finished

	# Deal damage
	var damage = calculate_damage(target)
	target.take_damage(damage)

	attacked.emit(target)
	EventBus.unit_attacked.emit(self, target, damage)

	# Return to original position
	var return_tween = create_tween()
	return_tween.set_ease(Tween.EASE_IN)
	return_tween.set_trans(Tween.TRANS_QUAD)
	return_tween.tween_property(self, "position", original_pos, 0.15)
	await return_tween.finished

	has_acted_this_turn = true
	action_completed.emit()

## Calculate damage dealt to target
func calculate_damage(target: Unit) -> int:
	var base_damage = stats.strength
	var defense = target.stats.defense

	# Weapon triangle advantage/disadvantage
	var advantage = get_weapon_advantage(target)
	base_damage += advantage

	# Apply defense
	var final_damage = max(0, base_damage - defense)

	# Critical hit check
	var crit_roll = randf() * 100
	if crit_roll < stats.crit_chance:
		final_damage *= 3
		if Constants.DEBUG_MODE:
			print("[Combat] Critical hit! Damage tripled.")

	return final_damage

## Get weapon triangle advantage against target
func get_weapon_advantage(target: Unit) -> int:
	var my_weapon = stats.weapon_type
	var their_weapon = target.stats.weapon_type

	# Sword > Axe > Lance > Sword
	if my_weapon == Constants.WeaponType.SWORD and their_weapon == Constants.WeaponType.AXE:
		return Constants.WEAPON_ADVANTAGE_BONUS
	elif my_weapon == Constants.WeaponType.AXE and their_weapon == Constants.WeaponType.LANCE:
		return Constants.WEAPON_ADVANTAGE_BONUS
	elif my_weapon == Constants.WeaponType.LANCE and their_weapon == Constants.WeaponType.SWORD:
		return Constants.WEAPON_ADVANTAGE_BONUS

	# Check disadvantage
	if my_weapon == Constants.WeaponType.AXE and their_weapon == Constants.WeaponType.SWORD:
		return Constants.WEAPON_DISADVANTAGE_PENALTY
	elif my_weapon == Constants.WeaponType.LANCE and their_weapon == Constants.WeaponType.AXE:
		return Constants.WEAPON_DISADVANTAGE_PENALTY
	elif my_weapon == Constants.WeaponType.SWORD and their_weapon == Constants.WeaponType.LANCE:
		return Constants.WEAPON_DISADVANTAGE_PENALTY

	return 0

## Take damage from attack
func take_damage(amount: int) -> void:
	# Dodge check
	var dodge_roll = randf() * 100
	if dodge_roll < stats.dodge_chance:
		if Constants.DEBUG_MODE:
			print("[Combat] %s dodged the attack!" % stats.unit_name)
		# Show "MISS" text
		_show_damage_text("MISS", Color.GRAY)
		return

	var died_from_damage = stats.take_damage(amount)
	damaged.emit(amount)
	EventBus.unit_damaged.emit(self, amount, stats.current_hp)
	update_health_bar()

	# Hit flash and shake
	_play_hit_effect()

	# Show damage number
	_show_damage_text(str(amount), Color.RED)

	if died_from_damage:
		die()

## Heal this unit
func heal(amount: int) -> void:
	var actual_healed = stats.heal(amount)
	EventBus.unit_healed.emit(self, actual_healed)
	update_health_bar()

## Kill this unit
func die() -> void:
	died.emit()
	EventBus.unit_died.emit(self)

	# Death animation: fade out and shrink
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_property(self, "scale", Vector2(0.5, 0.5), 0.5)
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_BACK)

	await tween.finished
	queue_free()

## Reset turn state
func start_turn() -> void:
	has_acted_this_turn = false
	has_moved_this_turn = false

	# Restore some grace points at turn start for Elara
	if stats.has_grace:
		stats.restore_grace(1)

## Check if unit can still act
func can_act() -> bool:
	return not has_acted_this_turn and stats.is_alive()

## Check if unit can still move
func can_move() -> bool:
	return not has_moved_this_turn and stats.is_alive()

## Update health bar visual
func update_health_bar() -> void:
	if health_bar:
		health_bar.value = stats.current_hp

		# Color code based on HP percentage
		var hp_percent = float(stats.current_hp) / float(stats.max_hp)
		if hp_percent > 0.5:
			health_bar.modulate = Color.GREEN
		elif hp_percent > 0.25:
			health_bar.modulate = Color.YELLOW
		else:
			health_bar.modulate = Color.RED

## Visual feedback for selection
func select() -> void:
	is_selected = true

	# Create selection ring
	var selection_ring = ColorRect.new()
	selection_ring.name = "SelectionRing"
	selection_ring.size = Vector2(Constants.GRID_CELL_SIZE + 8, Constants.GRID_CELL_SIZE + 8)
	selection_ring.position = Vector2(-4, -4)
	selection_ring.color = Color(1.0, 1.0, 0.5, 0.6)
	selection_ring.z_index = -1
	add_child(selection_ring)

	# Pulsing animation
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(selection_ring, "modulate:a", 0.3, 0.5)
	tween.tween_property(selection_ring, "modulate:a", 0.8, 0.5)

	# Brighten sprite
	if sprite:
		sprite.modulate = Color(1.3, 1.3, 1.3)

## Remove selection visual
func deselect() -> void:
	is_selected = false

	# Remove selection ring
	var ring = get_node_or_null("SelectionRing")
	if ring:
		ring.queue_free()

	# Reset sprite color
	if sprite:
		sprite.modulate = Color.WHITE

## Handle unit death
func _on_died() -> void:
	if Constants.DEBUG_MODE:
		print("[Unit] %s has died." % stats.unit_name)

## Play hit flash and shake effect
func _play_hit_effect() -> void:
	if not sprite:
		return

	# Store original position and color
	var original_pos = sprite.position
	var original_color = sprite.modulate

	# Flash red
	sprite.modulate = Color(2.0, 0.5, 0.5)

	# Shake effect
	var tween = create_tween()
	tween.set_parallel(true)

	# Shake animation (quick left-right)
	tween.tween_property(sprite, "position", original_pos + Vector2(3, 0), 0.05)
	tween.chain().tween_property(sprite, "position", original_pos + Vector2(-3, 0), 0.05)
	tween.chain().tween_property(sprite, "position", original_pos, 0.05)

	# Fade back to normal color
	tween.tween_property(sprite, "modulate", original_color, 0.2)

## Show floating damage text
func _show_damage_text(text: String, color: Color) -> void:
	# Create label for damage number
	var damage_label = Label.new()
	damage_label.text = text
	damage_label.modulate = color
	damage_label.position = Vector2(Constants.GRID_CELL_SIZE / 2, Constants.GRID_CELL_SIZE / 4)

	# Make text larger and bold
	damage_label.add_theme_font_size_override("font_size", 20)

	add_child(damage_label)

	# Float upward and fade out
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(damage_label, "position", damage_label.position + Vector2(0, -40), 1.0)
	tween.tween_property(damage_label, "modulate:a", 0.0, 1.0)

	await tween.finished
	damage_label.queue_free()
