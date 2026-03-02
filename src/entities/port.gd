extends Area2D
class_name Port

# We use Enums to define destinations (Mini-Metro style shapes)
enum PortType { LOADING, PASSENGER, LUXUS, CONTAINER, LIGHTHOUSE }
enum CrestType { DENMARK, HELSINKI, SWEDEN, RIGA }

@export var port_type: PortType = PortType.LOADING
@export var crest_type: CrestType = CrestType.DENMARK
@export var max_capacity: int = 10

var waiting_passengers: Array[PortType] = []

# Mapping types to their specific crest textures
const CREST_MAP = {
	CrestType.DENMARK: preload("res://assets/sprites/crests/denmark_crest.png"),
	CrestType.HELSINKI: preload("res://assets/sprites/crests/helsinki_crest.png"),
	CrestType.SWEDEN: preload("res://assets/sprites/crests/sweden_crest.png"),
	CrestType.RIGA: preload("res://assets/sprites/crests/riga_crest.png")
}

const PORT_MAP = {
	PortType.LOADING: preload("res://assets/sprites/ports/loading.png"),
	PortType.PASSENGER: preload("res://assets/sprites/ports/passenger.png"),
	PortType.LUXUS: preload("res://assets/sprites/ports/luxus.png"),
	PortType.CONTAINER: preload("res://assets/sprites/ports/container.png"),
	PortType.LIGHTHOUSE: preload("res://assets/sprites/ports/lighthouse.png")
}

# Signals to alert the Game Manager
signal overcrowded(port_node)

@onready var spawn_timer = $SpawnTimer
@onready var passenger_ui = $HBoxContainer

func _ready():
	$Sprite2D.texture = PORT_MAP[port_type]
	# Start spawning passengers randomly
	spawn_timer.wait_time = randf_range(5.0, 10.0)
	spawn_timer.start()
	print("SpawnTimer", spawn_timer)
	
	# Visual setup: Set sprite based on type (Logic omitted for brevity)
	update_ui()

func _on_spawn_timer_timeout():
	if waiting_passengers.size() < max_capacity:
		generate_passenger()
		spawn_timer.wait_time = randf_range(4.0, 8.0) # Randomize next spawn
	else:
		overcrowded.emit(self)

func generate_passenger():
	# Pick a random destination that ISN'T this port
	print("Generating passenger at ", port_type)
	var available_types = CrestType.values()
	available_types.erase(port_type)
	var destination = available_types.pick_random()
	
	waiting_passengers.append(destination)
	update_ui()

func update_ui():
	# 1. Clear existing icons
	for child in passenger_ui.get_children():
		child.queue_free()
	
	# 2. Add a tiny TextureRect for every passenger waiting
	for destination in waiting_passengers:
		var crest_icon = TextureRect.new()
		crest_icon.texture = CREST_MAP[destination]
		
		# Set size and scaling mode
		crest_icon.custom_minimum_size = Vector2(64, 64)
		crest_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		crest_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		print("adding crest: ", destination)
		passenger_ui.add_child(crest_icon)

# Handle Mouse Interaction for Line Drawing
func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			GameSignals.port_clicked.emit(self)
	elif event is InputEventMouseMotion:
		GameSignals.port_hovered.emit(self)
