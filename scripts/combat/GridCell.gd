extends Node2D
class_name GridCell

## Represents a single cell in the tactical combat grid
## Handles visual feedback, terrain properties, and occupancy

@export var terrain_type: Constants.TerrainType = Constants.TerrainType.PLAINS
@export var movement_cost: int = Constants.MOVEMENT_COST_DEFAULT
@export var defense_bonus: int = 0
@export var avoid_bonus: int = 0

var grid_position: Vector2i = Vector2i.ZERO
var is_occupied: bool = false
var occupying_unit: Node = null
var is_highlighted: bool = false
var highlight_color: Color = Color.WHITE

@onready var sprite: Sprite2D = $Sprite2D
@onready var highlight: ColorRect = $Highlight

func _ready() -> void:
	highlight.visible = false
	highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_setup_terrain_properties()

## Initialize cell with grid position
func initialize(grid_pos: Vector2i) -> void:
	grid_position = grid_pos
	position = Vector2(grid_pos.x * Constants.GRID_CELL_SIZE, grid_pos.y * Constants.GRID_CELL_SIZE)
	name = "Cell_%d_%d" % [grid_pos.x, grid_pos.y]

## Set terrain type and update properties accordingly
func set_terrain(new_terrain: Constants.TerrainType) -> void:
	terrain_type = new_terrain
	_setup_terrain_properties()
	_update_visual()

## Setup terrain-specific properties
func _setup_terrain_properties() -> void:
	match terrain_type:
		Constants.TerrainType.PLAINS:
			movement_cost = Constants.MOVEMENT_COST_DEFAULT
			defense_bonus = 0
			avoid_bonus = 0
		Constants.TerrainType.FOREST:
			movement_cost = Constants.MOVEMENT_COST_FOREST
			defense_bonus = 1
			avoid_bonus = 10
		Constants.TerrainType.MOUNTAIN:
			movement_cost = Constants.MOVEMENT_COST_MOUNTAIN
			defense_bonus = 2
			avoid_bonus = 20
		Constants.TerrainType.WATER:
			movement_cost = Constants.MOVEMENT_COST_IMPASSABLE
			defense_bonus = 0
			avoid_bonus = 0
		Constants.TerrainType.ROAD:
			movement_cost = 1
			defense_bonus = 0
			avoid_bonus = 0
		Constants.TerrainType.BUILDING:
			movement_cost = Constants.MOVEMENT_COST_DEFAULT
			defense_bonus = 2
			avoid_bonus = 10
		Constants.TerrainType.PLAGUE_ZONE:
			movement_cost = Constants.MOVEMENT_COST_DEFAULT
			defense_bonus = -1
			avoid_bonus = -10

## Update visual representation based on terrain
func _update_visual() -> void:
	if not sprite:
		return
	# Placeholder: Set modulation based on terrain
	match terrain_type:
		Constants.TerrainType.PLAINS:
			sprite.modulate = Color(0.8, 0.8, 0.6)
		Constants.TerrainType.FOREST:
			sprite.modulate = Color(0.3, 0.6, 0.3)
		Constants.TerrainType.MOUNTAIN:
			sprite.modulate = Color(0.6, 0.6, 0.6)
		Constants.TerrainType.WATER:
			sprite.modulate = Color(0.3, 0.4, 0.8)
		Constants.TerrainType.ROAD:
			sprite.modulate = Color(0.7, 0.6, 0.5)
		Constants.TerrainType.BUILDING:
			sprite.modulate = Color(0.5, 0.5, 0.5)
		Constants.TerrainType.PLAGUE_ZONE:
			sprite.modulate = Color(0.5, 0.6, 0.3)

## Set unit occupying this cell
func set_occupant(unit: Node) -> void:
	occupying_unit = unit
	is_occupied = unit != null

## Clear occupant from this cell
func clear_occupant() -> void:
	occupying_unit = null
	is_occupied = false

## Check if cell is passable for movement
func is_passable() -> bool:
	return movement_cost < Constants.MOVEMENT_COST_IMPASSABLE and not is_occupied

## Highlight this cell with specified color
func highlight(color: Color) -> void:
	is_highlighted = true
	highlight_color = color
	if highlight:
		highlight.color = color
		highlight.visible = true

## Remove highlight from this cell
func unhighlight() -> void:
	is_highlighted = false
	if highlight:
		highlight.visible = false

## Handle mouse hover
func _on_mouse_entered() -> void:
	EventBus.cell_hovered.emit(grid_position)

## Handle mouse click
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		EventBus.cell_clicked.emit(grid_position)
