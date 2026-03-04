extends Area2D
class_name Port

enum CityNames {
	TALLINN,
	HELSINKI,
	STOCKHOLM,
	RIGA,
	MARIENHAMN,
	ROSTOCK
}
@export var city_name: CityNames = CityNames.TALLINN
@export var max_capacity: int = 10

var waiting_passengers: Array[String] = []

# Signals to alert the Game Manager
signal overcrowded(port_node)

@onready var passenger_ui = $HBoxContainer
@onready var passenger_container = $HBoxContainer
const HAND_ICON = preload("res://assets/sprites/icons/tile_0138.png")
const PORT_ICON = preload("res://assets/sprites/icons/tile_0204.png")

func _ready():
	$Sprite2D.texture = PORT_ICON
	$Label.text = CityNames.keys()[city_name]
	GameManager.ports_in_play[city_name] = self
	update_ui()

func add_passenger(destination_city: String):
	if waiting_passengers.size() < max_capacity:
			print("New passenger at ", CityNames.keys()[city_name], " wants to go to ", destination_city)
			waiting_passengers.append(destination_city)
	else:
		overcrowded.emit(self)
	update_ui()

func update_ui():
	# 1. Clear existing icons
	for child in passenger_ui.get_children():
		child.queue_free()   
	
	# 2. Add a tiny TextureRect for every passenger waiting
	for destination in waiting_passengers:
		var icon = TextureRect.new()
		icon.texture = HAND_ICON
		icon.custom_minimum_size = Vector2(16, 16)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		
		# MODULATE: This is the magic part
		icon.modulate = LinePalette.CITY_COLORS[destination]
		
		passenger_container.add_child(icon)

# Handle Mouse Interaction for Line Drawing
func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			GameSignals.port_clicked.emit(self)
	elif event is InputEventMouseMotion:
		GameSignals.port_hovered.emit(self)
