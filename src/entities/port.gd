extends Area2D
class_name Port

@export var city_name: GameConstants.CityNames = GameConstants.CityNames.TALLINN
@export var max_capacity: int = 10
@export var appear_after_seconds: float = 0.0

var waiting_passengers: Array[GameConstants.CityNames] = []

# Signals to alert the Game Manager
signal overcrowded(port_node)

@onready var passenger_ui = $HBoxContainer
@onready var passenger_container = $HBoxContainer
const HAND_ICON = preload("res://assets/sprites/icons/hand_small_open.png")
const PORT_ICON = preload("res://assets/sprites/icons/tracking_horizontal.png")

func _ready():
	$Sprite2D.texture = PORT_ICON
	$Label.text = GameConstants.CityNames.keys()[city_name]
	
	# Start invisible if there's a delay
	if appear_after_seconds > 0:
		visible = false
		input_pickable = false
		await get_tree().create_timer(appear_after_seconds).timeout
		activate_port()
	else:
		activate_port()

func activate_port():
	visible = true
	input_pickable = true
	
	# Set port color based on city (softer version)
	var city_color = LinePalette.CITY_COLORS.get(city_name, Color.WHITE)
	$Sprite2D.modulate = city_color.lightened(0.0)  # Make it softer/lighter
	
	GameManager.register_port(self)
	update_ui()

func add_passenger(destination_city: GameConstants.CityNames):
	if waiting_passengers.size() < max_capacity:
			print("New passenger at ", GameConstants.CityNames.keys()[city_name], " wants to go to ", GameConstants.CityNames.keys()[destination_city])
			waiting_passengers.append(destination_city)
	else:
		overcrowded.emit(self)
	update_ui()

func update_ui():
	# 1. Clear existing icons
	$WarningSprite.visible = false
	for child in passenger_ui.get_children():
		child.queue_free()   
	
	# 2. Add a tiny TextureRect for every passenger waiting
	if waiting_passengers.size() >= max_capacity-1:
		$WarningSprite.visible = true
		
	for destination in waiting_passengers:
		var icon = TextureRect.new()
		icon.texture = HAND_ICON
		icon.custom_minimum_size = Vector2(16, 16)
	
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
