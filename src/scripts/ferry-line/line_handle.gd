extends Area2D

signal handle_moved(new_offset: Vector2)
signal handle_broken()

var is_dragging = false
var start_midpoint: Vector2 # The straight-line midpoint between two ports
var current_offset: Vector2 = Vector2.ZERO
var break_threshold: float = 250.0 # How far until the line snaps

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		is_dragging = event.pressed

func _process(_delta):
	if is_dragging:
		var mouse_pos = get_global_mouse_position()
		current_offset = mouse_pos - start_midpoint
		
		# Check for "Snap/Break" distance
		if current_offset.length() > break_threshold:
			handle_broken.emit()
			queue_free()
		else:
			global_position = mouse_pos
			handle_moved.emit(current_offset)
