extends Node2D

@export var ferry_line_scene: PackedScene = preload("res://src/scripts/ferry-line/FerryLine.tscn")

@onready var temp_line = $TempLine
@onready var routes_container = $Routes

var is_dragging: bool = false
var active_line: FerryLine = null
var start_port: Port = null
var hovered_port: Port = null # Updated via signals from Ports
#ENI Note: Gemini's suggestion for Land/Sea check
var is_path_blocked: bool = false
var astar = AStarGrid2D.new()

func _ready():
	setup_astar_grid()
	temp_line.visible = false
	GameSignals.port_clicked.connect(_on_port_clicked)
	GameSignals.port_hovered.connect(_on_port_hovered)

func _on_port_clicked(port: Port):
	print("onPortclicked:", Port)
	is_dragging = true
	active_line = ferry_line_scene.instantiate()
	active_line.line_color = LinePalette.get_next_color()
	add_child(active_line)
	
	active_line.add_port(port)
	
	temp_line.visible = true
	temp_line.default_color = active_line.line_color

func _on_port_hovered(port: Port):
	# ENI Note: Gemini's suggestion to add "and not is_path_blocked" to the condition
	if is_dragging and active_line and not is_path_blocked:
		# Only add if it's not already the most recent port (prevents loops/flicker)
		if port != active_line.ports.back():
			active_line.add_port(port)

func _process(_delta):
	if is_dragging and active_line:
		var last_port_pos = active_line.ports.back().global_position
		var mouse_pos = get_global_mouse_position()
		
		# Convert global positions to grid coordinates
		var start_grid = astar.get_id_path(last_port_pos, mouse_pos)
		
		# Convert grid coordinates back to world positions for the line
		var path_points = []
		for point in start_grid:
			path_points.append(astar.get_point_position(point))
		
		# If path_points is empty, the mouse is probably inside land with no way out
		if path_points.size() > 0:
			temp_line.points = path_points
			temp_line.default_color = active_line.line_color
		else:
			# Fallback: draw straight red line if no water path exists
			temp_line.points = [last_port_pos, mouse_pos]
			temp_line.default_color = Color.RED

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed and is_dragging:
			finish_dragging()

func finish_dragging():
	is_dragging = false
	temp_line.visible = false
	
	# If the line only has 1 port, it's not a route. Delete it.
	if active_line.ports.size() < 2:
		active_line.queue_free()
	else:
		print("Route created with ", active_line.ports.size(), " ports!")
	
	active_line = null

#ENI Note: Gemini's function suggestion
func _is_hitting_land(from: Vector2, to: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	# Create a ray from the last port to the current mouse position
	var query = PhysicsRayQueryParameters2D.create(from, to)
	query.collide_with_areas = true
	
	var result = space_state.intersect_ray(query)
	if result:
		# Returns true if the object hit is named "land"
		return "land" in result.collider.name.to_lower()
	
	return false
func setup_astar_grid():
	astar.region = Rect2i(0, 0, 100, 100) # Adjust to your map size
	astar.cell_size = Vector2(16, 16)     # Adjust based on how "smooth" you want the line
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_AT_LEAST_ONE_WALKABLE
	astar.update()

	# Loop through the grid and mark land cells as solid
	for x in astar.region.size.x:
		for y in astar.region.size.y:
			var pos = Vector2(x, y) * astar.cell_size
			if _is_point_on_land(pos):
				astar.set_point_solid(Vector2i(x, y))

func _is_point_on_land(pos: Vector2) -> bool:
	# Uses your existing physics check logic
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = pos
	var result = space_state.intersect_point(query)
	for r in result:
		if r.collider.is_in_group("land"):
			return true
	return false
