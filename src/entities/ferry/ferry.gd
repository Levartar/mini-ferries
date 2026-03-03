extends Area2D
class_name Ferry

enum TravelState { SAILING, DOCKING, IDLE }

# Stats
@export var sail_speed: float = 0.05 # How much progress_ratio/sec
@export var passenger_capacity: int = 6
@export var docking_time: float = 2.0 # Seconds to wait at port

# References
var assigned_line: FerryLine = null
var current_path_follow: PathFollow2D = null

# Core Variables
var direction: int = 1 # 1 = Forward (0->1), -1 = Backward (1->0)
var current_state: TravelState = TravelState.IDLE
var onboard_passengers: Array[Port.CityNames] = []

# Drag and Drop
var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

# Arrival cooldown
var arrival_cooldown: float = 0.0
const ARRIVAL_COOLDOWN_TIME: float = 10.0

@onready var passenger_ui = $PassengerContainer

func _ready():
	# Enable input events for this Area2D
	input_pickable = true
	
	# Connect mouse signals
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	# Visual feedback when hovering (optional)
	modulate = Color(1.2, 1.2, 1.2)

func _on_mouse_exited():
	if not is_dragging:
		modulate = Color.WHITE

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and _is_mouse_over():
			# Start dragging
			start_drag(event.position)
		elif not event.pressed and is_dragging:
			# Stop dragging and check for path
			stop_drag()

func _is_mouse_over() -> bool:
	# Check if mouse is over this ferry
	var mouse_pos = get_global_mouse_position()
	var overlapping = get_overlapping_areas() + get_overlapping_bodies()
	
	# Simple bounds check using the collision shape
	var shape = $CollisionShape2D.shape
	if shape is RectangleShape2D:
		var rect = Rect2(global_position - shape.size / 2, shape.size)
		return rect.has_point(mouse_pos)
	return false

func start_drag(mouse_pos: Vector2):
	is_dragging = true
	drag_offset = global_position - mouse_pos
	current_state = TravelState.IDLE
	
	# Detach from current path if following one
	if current_path_follow:
		var old_pos = global_position
		current_path_follow.queue_free()
		current_path_follow = null
		global_position = old_pos
	
	modulate = Color(1.5, 1.5, 1.5)

func stop_drag():
	is_dragging = false
	modulate = Color.WHITE
	
	# Check if dropped over a path
	var ferry_line = find_path_at_position(global_position)
	if ferry_line:
		attach_to_path(ferry_line)
	else:
		# Not over a path, stay idle
		current_state = TravelState.IDLE

func find_path_at_position(pos: Vector2) -> FerryLine:
	# Get all FerryLine nodes in the scene
	var root = get_tree().root
	var ferry_lines = find_ferry_lines(root)
	
	# Check which path is closest to the drop position
	var closest_line: FerryLine = null
	var min_distance = 50.0 # Maximum snap distance
	
	for line in ferry_lines:
		if line.path_node and line.path_node.curve:
			var curve = line.path_node.curve
			var closest_offset = curve.get_closest_offset(pos)
			var closest_point = curve.sample_baked(closest_offset)
			var distance = pos.distance_to(closest_point)
			
			if distance < min_distance:
				min_distance = distance
				closest_line = line
	
	return closest_line

func find_ferry_lines(node: Node) -> Array[FerryLine]:
	var lines: Array[FerryLine] = []
	
	if node is FerryLine:
		lines.append(node)
	
	for child in node.get_children():
		lines.append_array(find_ferry_lines(child))
	
	return lines

func attach_to_path(ferry_line: FerryLine):
	assigned_line = ferry_line
	
	# Create a PathFollow2D node
	current_path_follow = PathFollow2D.new()
	ferry_line.path_node.add_child(current_path_follow)
	
	# Find the closest point on the path to place the ferry
	var closest_offset = ferry_line.path_node.curve.get_closest_offset(global_position)
	current_path_follow.progress = closest_offset
	
	# Reparent the ferry to the PathFollow2D
	var old_parent = get_parent()
	old_parent.remove_child(self)
	current_path_follow.add_child(self)
	
	# Reset position relative to PathFollow2D
	position = Vector2.ZERO
	
	# Start sailing
	current_state = TravelState.SAILING
	print("Ferry attached to path: ", ferry_line.name)

func _process(delta):
	# Handle dragging
	if is_dragging:
		global_position = get_global_mouse_position() + drag_offset
		return
	
	# Update arrival cooldown
	if arrival_cooldown > 0:
		arrival_cooldown -= delta
	
	if current_state == TravelState.SAILING:
		# 1. Update movement
		current_path_follow.progress_ratio += (sail_speed * delta * direction)
		
		# 2. Check for port intersections (only if cooldown expired)
		if arrival_cooldown <= 0:
			check_port_arrivals()
		
		# 3. Check for End-of-Line behavior
		if current_path_follow.progress_ratio >= 0.98 and direction == 1:
			handle_end_of_line()
		elif current_path_follow.progress_ratio <= 0.02 and direction == -1:
			handle_start_of_line()

func handle_end_of_line():
	# Check if this is a loop (first port == last port)
	if assigned_line.ports.size() > 0 and assigned_line.ports.front() == assigned_line.ports.back():
		# It's a loop - wrap around to the beginning
		print("Reached end of loop, wrapping around")
		current_path_follow.progress_ratio = 0.0
	else:
		# It's not a loop - reverse direction
		print("Reached end of line, reversing direction")
		direction *= -1
		#$ShipSprite.scale.x = direction
		current_path_follow.progress_ratio = 1.0  # Clamp to prevent overshooting

func handle_start_of_line():
	# When going backwards and reaching the start, reverse direction
	direction *= -1
	#$ShipSprite.scale.x = direction
	current_path_follow.progress_ratio = 0.0  # Clamp to prevent undershooting

func check_port_arrivals():
	# Get all overlapping areas (ports are Area2D nodes)
	var overlapping_areas = get_overlapping_areas()
	
	for area in overlapping_areas:
		if area is Port:
			# Trigger arrival and set cooldown
			handle_arrival(area)
			arrival_cooldown = ARRIVAL_COOLDOWN_TIME
			return

func handle_arrival(port: Port):
	current_state = TravelState.DOCKING
	print("Ship arrived at ", port.name)
	
	# Start loading/unloading logic
	process_passengers(port)
	
	# Start the wait timer
	await get_tree().create_timer(docking_time).timeout
	current_state = TravelState.SAILING

func process_passengers(port: Port):
	# 1. UNLOAD: Remove passengers whose destination is THIS port
	var delivered_count = 0
	for i in range(onboard_passengers.size() - 1, -1, -1): # Iterate backwards to remove
		if onboard_passengers[i] == port.city_name:
			onboard_passengers.remove_at(i)
			delivered_count += 1
	
	if delivered_count > 0:
		print("Delivered ", delivered_count, " passengers!")
		GameSignals.passengers_delivered.emit(delivered_count) # Future Score!
		
	# 2. IDENTIFY VALID DESTINATIONS
	# The ferry should only pick up people whose destination exists on THIS specific line
	var valid_destinations: Array[Port.CityNames] = []
	for p in assigned_line.ports:
		valid_destinations.append(p.city_name)
	
	# 3. LOAD PASSENGERS
	var space_left = passenger_capacity - onboard_passengers.size()
	
	# We look at the port's waiting list
	# Again, iterate backwards to safely remove passengers from the Port's array
	for i in range(port.waiting_passengers.size() - 1, -1, -1):
		if space_left <= 0:
			break
			
		var passenger_dest = port.waiting_passengers[i]
		
		# Does this line actually go where they want to go?
		if valid_destinations.has(passenger_dest):
			# Move from Port to Ferry
			onboard_passengers.append(passenger_dest)
			port.waiting_passengers.remove_at(i)
			space_left -= 1
	
	# 4. REFRESH VISUALS
	port.update_ui() # Update the modulated hands at the dock
	update_ui()      # Update the modulated hands on the ship

func update_ui():
	# (Logic to update the ship's PassengerContainer with City Crests, similar to port.gd)
	pass
