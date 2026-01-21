extends Node2D
class_name GridManager

## Manages the tactical grid system for combat
## Handles cell creation, pathfinding, range calculation, and unit positioning

signal grid_initialized()

@export var grid_width: int = Constants.GRID_WIDTH
@export var grid_height: int = Constants.GRID_HEIGHT
@export var cell_scene: PackedScene

var grid: Dictionary = {}  # Vector2i -> GridCell
var units: Dictionary = {}  # Vector2i -> Unit

func _ready() -> void:
	_create_grid()
	_connect_signals()

## Create the grid cells
func _create_grid() -> void:
	for x in range(grid_width):
		for y in range(grid_height):
			var cell_pos = Vector2i(x, y)
			var cell = _create_cell(cell_pos)
			grid[cell_pos] = cell
			add_child(cell)

	grid_initialized.emit()
	if Constants.DEBUG_MODE:
		print("[GridManager] Grid initialized: %dx%d" % [grid_width, grid_height])

## Create a single grid cell
func _create_cell(cell_pos: Vector2i) -> GridCell:
	var cell: GridCell
	if cell_scene:
		cell = cell_scene.instantiate()
	else:
		cell = GridCell.new()
		_setup_default_cell_visuals(cell)

	cell.initialize(cell_pos)
	return cell

## Setup default visuals for cells when no scene is provided
func _setup_default_cell_visuals(cell: GridCell) -> void:
	# Create sprite
	var sprite = Sprite2D.new()
	sprite.name = "Sprite2D"
	# Create a simple colored square texture placeholder
	var image = Image.create(Constants.GRID_CELL_SIZE - 2, Constants.GRID_CELL_SIZE - 2, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.8, 0.8, 0.6))
	sprite.texture = ImageTexture.create_from_image(image)
	sprite.centered = false
	sprite.position = Vector2(1, 1)
	cell.add_child(sprite)

	# Create highlight rect
	var highlight = ColorRect.new()
	highlight.name = "Highlight"
	highlight.size = Vector2(Constants.GRID_CELL_SIZE, Constants.GRID_CELL_SIZE)
	highlight.color = Color.TRANSPARENT
	highlight.visible = false
	cell.add_child(highlight)

	# Add input detection
	var area = Area2D.new()
	area.name = "InputArea"
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(Constants.GRID_CELL_SIZE, Constants.GRID_CELL_SIZE)
	collision.shape = shape
	collision.position = Vector2(Constants.GRID_CELL_SIZE / 2, Constants.GRID_CELL_SIZE / 2)
	area.add_child(collision)
	cell.add_child(area)

	area.input_event.connect(cell._on_input_event)
	area.mouse_entered.connect(cell._on_mouse_entered)

## Connect to event bus signals
func _connect_signals() -> void:
	EventBus.cell_clicked.connect(_on_cell_clicked)
	EventBus.ranges_cleared.connect(clear_all_highlights)

## Get cell at grid position
func get_cell(pos: Vector2i) -> GridCell:
	return grid.get(pos)

## Check if position is valid on grid
func is_valid_position(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < grid_width and pos.y >= 0 and pos.y < grid_height

## Place unit on grid
func place_unit(unit: Unit, pos: Vector2i) -> bool:
	if not is_valid_position(pos) or units.has(pos):
		return false

	units[pos] = unit
	unit.set_grid_position(pos)

	var cell = get_cell(pos)
	if cell:
		cell.set_occupant(unit)

	return true

## Move unit from one position to another
func move_unit(unit: Unit, from_pos: Vector2i, to_pos: Vector2i) -> bool:
	if not is_valid_position(to_pos) or units.has(to_pos):
		return false

	# Clear old position
	units.erase(from_pos)
	var old_cell = get_cell(from_pos)
	if old_cell:
		old_cell.clear_occupant()

	# Set new position
	units[to_pos] = unit
	unit.set_grid_position(to_pos)

	var new_cell = get_cell(to_pos)
	if new_cell:
		new_cell.set_occupant(unit)

	return true

## Get unit at position
func get_unit_at(pos: Vector2i) -> Unit:
	return units.get(pos)

## Remove unit from grid
func remove_unit(unit: Unit) -> void:
	var pos = unit.grid_position
	units.erase(pos)

	var cell = get_cell(pos)
	if cell:
		cell.clear_occupant()

## Calculate movement range for unit using BFS
func calculate_movement_range(unit: Unit) -> Array[Vector2i]:
	var reachable_cells: Array[Vector2i] = []
	var start_pos = unit.grid_position
	var max_range = unit.stats.movement_range

	# BFS with movement cost tracking
	var queue: Array = [[start_pos, 0]]  # [position, cost_spent]
	var visited: Dictionary = {start_pos: 0}

	while not queue.is_empty():
		var current = queue.pop_front()
		var current_pos: Vector2i = current[0]
		var current_cost: int = current[1]

		if current_pos != start_pos:
			reachable_cells.append(current_pos)

		# Check all adjacent cells
		var neighbors = get_adjacent_positions(current_pos)
		for neighbor_pos in neighbors:
			var cell = get_cell(neighbor_pos)
			if not cell or not cell.is_passable():
				continue

			# Check terrain traversal permissions
			if not can_unit_traverse_terrain(unit, cell.terrain_type):
				continue

			var move_cost = current_cost + cell.movement_cost

			if move_cost <= max_range:
				if not visited.has(neighbor_pos) or visited[neighbor_pos] > move_cost:
					visited[neighbor_pos] = move_cost
					queue.append([neighbor_pos, move_cost])

	return reachable_cells

## Check if unit can traverse specific terrain
func can_unit_traverse_terrain(unit: Unit, terrain: int) -> bool:
	match terrain:
		Constants.TerrainType.FOREST:
			return unit.stats.can_traverse_forest
		Constants.TerrainType.MOUNTAIN:
			return unit.stats.can_traverse_mountain
		Constants.TerrainType.WATER:
			return unit.stats.can_traverse_water
		_:
			return true

## Get adjacent grid positions (4-directional)
func get_adjacent_positions(pos: Vector2i) -> Array[Vector2i]:
	var adjacent: Array[Vector2i] = []
	var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]

	for dir in directions:
		var neighbor_pos = pos + dir
		if is_valid_position(neighbor_pos):
			adjacent.append(neighbor_pos)

	return adjacent

## Highlight cells in movement range
func highlight_movement_range(cells: Array[Vector2i]) -> void:
	for cell_pos in cells:
		var cell = get_cell(cell_pos)
		if cell:
			cell.highlight(Constants.TILE_HIGHLIGHT_COLOR_MOVE)

## Highlight cells in attack range
func highlight_attack_range(cells: Array[Vector2i]) -> void:
	for cell_pos in cells:
		var cell = get_cell(cell_pos)
		if cell:
			cell.highlight(Constants.TILE_HIGHLIGHT_COLOR_ATTACK)

## Highlight specific cell as selected
func highlight_selected(pos: Vector2i) -> void:
	var cell = get_cell(pos)
	if cell:
		cell.highlight(Constants.TILE_HIGHLIGHT_COLOR_SELECTED)

## Clear all cell highlights
func clear_all_highlights() -> void:
	for cell in grid.values():
		cell.unhighlight()

## Find path between two points using A*
func find_path(from: Vector2i, to: Vector2i, unit: Unit) -> Array[Vector2i]:
	if not is_valid_position(from) or not is_valid_position(to):
		return []

	var open_set: Array[Vector2i] = [from]
	var came_from: Dictionary = {}
	var g_score: Dictionary = {from: 0}
	var f_score: Dictionary = {from: _heuristic(from, to)}

	while not open_set.is_empty():
		# Get node with lowest f_score
		var current = _get_lowest_f_score(open_set, f_score)

		if current == to:
			return _reconstruct_path(came_from, current)

		open_set.erase(current)

		for neighbor in get_adjacent_positions(current):
			var cell = get_cell(neighbor)
			if not cell:
				continue

			# Allow pathfinding to destination even if occupied
			if not cell.is_passable() and neighbor != to:
				continue

			if not can_unit_traverse_terrain(unit, cell.terrain_type):
				continue

			var tentative_g_score = g_score[current] + cell.movement_cost

			if not g_score.has(neighbor) or tentative_g_score < g_score[neighbor]:
				came_from[neighbor] = current
				g_score[neighbor] = tentative_g_score
				f_score[neighbor] = tentative_g_score + _heuristic(neighbor, to)

				if not open_set.has(neighbor):
					open_set.append(neighbor)

	return []  # No path found

## Manhattan distance heuristic
func _heuristic(from: Vector2i, to: Vector2i) -> int:
	return abs(from.x - to.x) + abs(from.y - to.y)

## Get position with lowest f_score from open set
func _get_lowest_f_score(open_set: Array[Vector2i], f_score: Dictionary) -> Vector2i:
	var lowest = open_set[0]
	var lowest_score = f_score.get(lowest, INF)

	for pos in open_set:
		var score = f_score.get(pos, INF)
		if score < lowest_score:
			lowest = pos
			lowest_score = score

	return lowest

## Reconstruct path from came_from dictionary
func _reconstruct_path(came_from: Dictionary, current: Vector2i) -> Array[Vector2i]:
	var path: Array[Vector2i] = [current]

	while came_from.has(current):
		current = came_from[current]
		path.push_front(current)

	return path

## Handle cell clicked event
func _on_cell_clicked(cell_pos: Vector2i) -> void:
	if Constants.DEBUG_MODE:
		print("[GridManager] Cell clicked: ", cell_pos)
