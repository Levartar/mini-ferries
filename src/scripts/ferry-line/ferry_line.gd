extends Node2D
class_name FerryLine

var handle_scene: PackedScene = preload("res://src/scripts/ferry-line/LineHandle.tscn")
var line_color: Color
var ports: Array[Port] = []
var segment_offsets: Array[Vector2] = [] # Stores the "bend" for each segment
@onready var path_node = $Path2D
@onready var line_renderer = $Line2D

func add_port(new_port: Port):
	ports.append(new_port)
	segment_offsets.append(Vector2.ZERO) # New segments start straight
	refresh_line()

func refresh_line():
	# 1. Clear old handles
	for child in get_children():
		if child is Area2D: child.queue_free()
	
	var new_curve = Curve2D.new()
	new_curve.bake_interval = 4.0 # Adjust for smoother curves
	
	for i in range(ports.size() - 1):
		var p1 = ports[i].global_position
		var p2 = ports[i+1].global_position
		var mid = (p1 + p2) / 2
		var offset = segment_offsets[i]
		
		# Draw the curved segment
		# We use the offset as the Bezier control point
		var control_point = mid + offset
		
		# Build the curve
		if i == 0: new_curve.add_point(p1)
		
		# Handle relative to the end point
		var handle_in = control_point - p2 
		new_curve.add_point(p2, handle_in)
		
		# 2. Spawn the physical Handle for the player to grab
		var h = handle_scene.instantiate()
		add_child(h)
		h.start_midpoint = mid
		h.global_position = mid + offset
		
		# Modulate handle to match line color
		h.get_node("Sprite2D").modulate = line_color
		
		# Connect handle signals
		h.handle_moved.connect(func(new_val): 
			segment_offsets[i] = new_val
			_update_visual_only() # Re-draw Line2D without re-spawning handles
		)
		h.handle_broken.connect(func(): _remove_segment(i))

	path_node.curve = new_curve
	line_renderer.points = new_curve.get_baked_points()
	line_renderer.default_color = line_color

func _update_visual_only():
	var new_curve = Curve2D.new()
	
	for i in range(ports.size() - 1):
		var p1_pos = ports[i].global_position
		var p2_pos = ports[i+1].global_position
		
		# Calculate the control point based on the stored offset
		var mid = (p1_pos + p2_pos) / 2.0
		var control_point = mid + segment_offsets[i]
		
		# We define the segment using 'In' and 'Out' handles.
		# Handle 'Out' of Port A points toward our Control Point.
		# Handle 'In' of Port B points toward our Control Point.
		
		if i == 0:
			# First port: only needs an 'out' handle
			new_curve.add_point(p1_pos, Vector2.ZERO, control_point - p1_pos)
		else:
			# Intermediate ports: set the 'out' handle for the point we added 
			# in the previous iteration of the loop
			new_curve.set_point_out(i, control_point - p1_pos)
		
		# Add the next port with an 'in' handle
		new_curve.add_point(p2_pos, control_point - p2_pos, Vector2.ZERO)
	
	# Update the Path2D for the ships to follow
	path_node.curve = new_curve
	
	# Update the Line2D for the player to see
	# .get_baked_points() turns the smooth curve into a list of straight segments
	line_renderer.points = new_curve.get_baked_points()

func _remove_segment(index: int):
	# If a segment breaks, we usually truncate the line from that point onward
	# Similar to Mini-Metro logic
	ports = ports.slice(0, index + 1)
	segment_offsets = segment_offsets.slice(0, index + 1)
	refresh_line()

func get_port_types_on_route() -> Array:
	var types = []
	for port in ports:
		if not types.has(port.port_type):
			types.append(port.port_type)
	return types
