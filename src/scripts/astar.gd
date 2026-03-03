var astar = AStarGrid2D.new()

func _ready():
	setup_astar_grid()
	# ... your existing signal connections ...

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
