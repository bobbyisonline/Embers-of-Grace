extends Resource
class_name UnitStats

## Resource defining a unit's combat statistics
## Can be saved/loaded and edited in the inspector

@export_group("Identity")
@export var unit_name: String = "Unnamed"
@export var unit_class: int = 0  # Constants.UnitClass.KNIGHT
@export var level: int = 1
@export var experience: int = 0
@export var experience_to_next_level: int = 100

@export_group("Core Stats")
@export var max_hp: int = 20
@export var current_hp: int = 20
@export var strength: int = 5
@export var defense: int = 3
@export var speed: int = 5
@export var faith: int = 0
@export var luck: int = 5

@export_group("Movement")
@export var movement_range: int = 5
@export var can_traverse_forest: bool = true
@export var can_traverse_mountain: bool = false
@export var can_traverse_water: bool = false

@export_group("Combat")
@export var attack_range: int = 1  # Melee = 1, Ranged = 2+
@export var weapon_type: int = 0  # Constants.WeaponType.SWORD
@export var crit_chance: int = 5  # Base critical hit chance percentage
@export var dodge_chance: int = 5  # Base dodge chance percentage

@export_group("Growth Rates (Percent)")
@export var hp_growth: int = 50
@export var strength_growth: int = 40
@export var defense_growth: int = 30
@export var speed_growth: int = 40
@export var faith_growth: int = 20
@export var luck_growth: int = 30

@export_group("Grace System (Elara only)")
@export var has_grace: bool = false
@export var grace_points: int = 0
@export var max_grace_points: int = Constants.MAX_GRACE_POINTS

## Create a deep copy of these stats
func duplicate_stats() -> UnitStats:
	var new_stats = UnitStats.new()

	# Identity
	new_stats.unit_name = unit_name
	new_stats.unit_class = unit_class
	new_stats.level = level
	new_stats.experience = experience
	new_stats.experience_to_next_level = experience_to_next_level

	# Core stats
	new_stats.max_hp = max_hp
	new_stats.current_hp = current_hp
	new_stats.strength = strength
	new_stats.defense = defense
	new_stats.speed = speed
	new_stats.faith = faith
	new_stats.luck = luck

	# Movement
	new_stats.movement_range = movement_range
	new_stats.can_traverse_forest = can_traverse_forest
	new_stats.can_traverse_mountain = can_traverse_mountain
	new_stats.can_traverse_water = can_traverse_water

	# Combat
	new_stats.attack_range = attack_range
	new_stats.weapon_type = weapon_type
	new_stats.crit_chance = crit_chance
	new_stats.dodge_chance = dodge_chance

	# Growth rates
	new_stats.hp_growth = hp_growth
	new_stats.strength_growth = strength_growth
	new_stats.defense_growth = defense_growth
	new_stats.speed_growth = speed_growth
	new_stats.faith_growth = faith_growth
	new_stats.luck_growth = luck_growth

	# Grace
	new_stats.has_grace = has_grace
	new_stats.grace_points = grace_points
	new_stats.max_grace_points = max_grace_points

	return new_stats

## Take damage and return if unit died
func take_damage(amount: int) -> bool:
	current_hp = max(0, current_hp - amount)
	return current_hp <= 0

## Heal and return actual amount healed
func heal(amount: int) -> int:
	var old_hp = current_hp
	current_hp = min(max_hp, current_hp + amount)
	return current_hp - old_hp

## Check if unit is alive
func is_alive() -> bool:
	return current_hp > 0

## Restore to full health
func full_heal() -> void:
	current_hp = max_hp

## Gain experience and check for level up
func gain_experience(amount: int) -> bool:
	experience += amount
	if experience >= experience_to_next_level:
		return true
	return false

## Level up with growth rates
func level_up() -> Dictionary:
	level += 1
	experience = 0
	experience_to_next_level = int(experience_to_next_level * 1.1)

	var stat_gains = {
		"hp": 0,
		"strength": 0,
		"defense": 0,
		"speed": 0,
		"faith": 0,
		"luck": 0
	}

	# Roll for each stat increase
	if randf() * 100 < hp_growth:
		var gain = randi_range(2, 4)
		max_hp += gain
		current_hp += gain
		stat_gains.hp = gain

	if randf() * 100 < strength_growth:
		strength += 1
		stat_gains.strength = 1

	if randf() * 100 < defense_growth:
		defense += 1
		stat_gains.defense = 1

	if randf() * 100 < speed_growth:
		speed += 1
		stat_gains.speed = 1

	if randf() * 100 < faith_growth:
		faith += 1
		stat_gains.faith = 1

	if randf() * 100 < luck_growth:
		luck += 1
		stat_gains.luck = 1

	return stat_gains

## Use grace points (for Elara)
func use_grace(amount: int) -> bool:
	if not has_grace or grace_points < amount:
		return false
	grace_points -= amount
	return true

## Restore grace points
func restore_grace(amount: int) -> void:
	if has_grace:
		grace_points = min(max_grace_points, grace_points + amount)
