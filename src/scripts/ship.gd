@tool
extends Area2D
class_name Ship

enum ShipNames {
	QUEEN, PRINCESS, MEGASTAR, MYSTAR, VICTORIAI, SERENADE, SYMPHONY, SUPERFAST
	}
	
enum TravelState { SAILING, DOCKING, IDLE }
#ENi Note: stats
@export var ship_name: ShipNames:
	set(value):
		ship_name = value
		_update_info()
		notify_property_list_changed()
		
@export var max_ports: int = 0
@export var speed: float = 0.05 # How much progress_ratio/sec
@export var capacity: int = 6
@export var docking_time: float = 2.0 # Seconds to wait at port

#ENi Note: references in ferry script
var assigned_line: FerryLine = null
var current_path_follow: PathFollow2D = null

#ENi Note: Core Variables in ferry script
var direction: int = 1 # 1 = Forward (0->1), -1 = Backward (1->0)
var current_state: TravelState = TravelState.IDLE
var onboard_passengers: Array[GameConstants.CityNames] = []

#ENi Note: ferry script's drag and drop logic doesn't seem fitting
var assigned_ports: Array[Vector2] = []
var target_index: int = 0
signal ship_selected(ship_node)

#ENi Note: Arrival cooldown in ferry script
var arrival_cooldown: float = 0.0
const ARRIVAL_COOLDOWN_TIME: float = 5.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_info()

func _update_info():
	match ship_name:
		ShipNames.QUEEN:
			$Sprite2D.texture = preload("res://assets/Ships/baltic_queen.png")
			$Label.text = "Baltic Queen"
			max_ports = 3
			speed = 0.024
			capacity = 6
			docking_time = 2.0
		ShipNames.PRINCESS:
			$Sprite2D.texture = preload("res://assets/Ships/baltic_princess.png")
			$Label.text = "Baltic Princess"
			max_ports = 3
			speed = 0.024
			capacity = 6
			docking_time = 2.0
		ShipNames.MEGASTAR:
			$Sprite2D.texture = preload("res://assets/Ships/megastar.png")
			$Label.text = "Megastar"
			max_ports = 2
			speed = 0.028
			capacity = 6
			docking_time = 2.0
		ShipNames.MYSTAR:
			$Sprite2D.texture = preload("res://assets/Ships/mystar.png")
			$Label.text = "My Star"
			max_ports = 2
			speed = 0.027
			capacity = 6
			docking_time = 2.0
		ShipNames.VICTORIAI:
			$Sprite2D.texture = preload("res://assets/Ships/victoriaI.png")
			$Label.text = "Victoria I"
			max_ports = 2
			speed = 0.022
			capacity = 5
			docking_time = 2.0
		ShipNames.SERENADE:
			$Sprite2D.texture = preload("res://assets/Ships/serenade.png")
			$Label.text = "Serenade"
			max_ports = 3
			speed = 0.021
			capacity = 6
			docking_time = 2.0
		ShipNames.SYMPHONY:
			$Sprite2D.texture = preload("res://assets/Ships/symphony.png")
			$Label.text = "Symphony"
			max_ports = 3
			speed = 0.021
			capacity = 7
			docking_time = 2.0
		ShipNames.SUPERFAST:
			$Sprite2D.texture = preload("res://assets/Ships/superfast.png")
			$Label.text = "Superfast IX"
			max_ports = 2
			speed = 0.025
			capacity = 2
			docking_time = 1.0

# ENi note: Gemini says that this makes the variable grayed out/read-only in the UI
# This is the "Magic" function for Godot 4 stable
func _validate_property(property: Dictionary):
	if property.name == "max_ports":
		# This adds the 'Read Only' flag to the existing export
		property.usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_READ_ONLY
	if property.name == "speed":
		property.usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_READ_ONLY
	if property.name == "capacity":
		property.usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_READ_ONLY
	if property.name == "docking_time":
		property.usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_READ_ONLY

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		ship_selected.emit(self)
		
func _physics_process(_delta):	
	var current_target = assigned_ports[target_index]
	
	# Movement logic
	var ship_direction = global_position.direction_to(current_target)
	global_position += ship_direction * speed * _delta
	if global_position.distance_to(current_target) < 5:
		if assigned_ports.size() > 1:
			target_index = (target_index + 1) % assigned_ports.size()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
	
