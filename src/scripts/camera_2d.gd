#ENi Note: help with Gemini to make something out of the Camera2D node.
extends Camera2D

@export var zoom_speed: float = 0.1
@export var min_zoom: float = 0.5
@export var max_zoom: float = 2.0
@export var drag_sensitivity: float = 1.0

@onready var land_sprite: Sprite2D = get_node("../Land/Sprite2D")

func _ready():
	_update_camera_limits()

func _update_camera_limits():
	if not land_sprite: return
	
	# Calculate the edges of the sprite
	var rect = land_sprite.get_rect()
	var scale = land_sprite.scale
	
	# Set limits (multiplied by scale in case you resized the land)
	limit_left = int(land_sprite.global_position.x + (rect.position.x * scale.x))
	limit_top = int(land_sprite.global_position.y + (rect.position.y * scale.y))
	limit_right = int(land_sprite.global_position.x + (rect.end.x * scale.x))
	limit_bottom = int(land_sprite.global_position.y + (rect.end.y * scale.y))

func _unhandled_input(event):
	# 1. MOUSE DRAG (Right Click or Middle Click to Pan)
	if event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_MASK_RIGHT:
			global_position -= event.relative * (1.0 / zoom.x) * drag_sensitivity

	# 2. ZOOM LOGIC
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_set_zoom_level(zoom.x + zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_set_zoom_level(zoom.x - zoom_speed)

func _set_zoom_level(level: float):
	var old_zoom = zoom.x
	var new_zoom = clamp(level, min_zoom, max_zoom)
	
	# 3. PREVENT SHOWING OUTSIDE BORDERS
	# We check if the camera's view size at this zoom fits inside the Land
	var screen_size = get_viewport_rect().size
	var view_width = screen_size.x / new_zoom
	var view_height = screen_size.y / new_zoom
	
	var land_width = (land_sprite.get_rect().size.x * land_sprite.scale.x)
	var land_height = (land_sprite.get_rect().size.y * land_sprite.scale.y)
	
	# If zooming out further would reveal the "void", stop zooming
	if view_width > land_width or view_height > land_height:
		return

	zoom = Vector2(new_zoom, new_zoom)
