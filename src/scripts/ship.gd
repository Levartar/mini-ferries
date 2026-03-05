@tool
extends Area2D
class_name Ship

enum ShipNames {
	QUEEN, PRINCESS, MEGASTAR, MYSTAR, VICTORIAI, SERENADE, SYMPHONY, SUPERFAST
	}

@export var ship_name: ShipNames:
	set(value):
		ship_name = value
		_update_info()
		notify_property_list_changed()
		
@export var max_ports: int = 0
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_info()

func _update_info():
	match ship_name:
		ShipNames.QUEEN:
			$Sprite2D.texture = preload("res://assets/Ships/baltic_queen.png")
			$Label.text = "Baltic Queen"
			max_ports = 3
		ShipNames.PRINCESS:
			$Sprite2D.texture = preload("res://assets/Ships/baltic_princess.png")
			$Label.text = "Baltic Princess"
			max_ports = 3
		ShipNames.MEGASTAR:
			$Sprite2D.texture = preload("res://assets/Ships/megastar.png")
			$Label.text = "Megastar"
			max_ports = 2
		ShipNames.MYSTAR:
			$Sprite2D.texture = preload("res://assets/Ships/mystar.png")
			$Label.text = "My Star"
			max_ports = 2
		ShipNames.VICTORIAI:
			$Sprite2D.texture = preload("res://assets/Ships/victoriaI.png")
			$Label.text = "Victoria I"
			max_ports = 2
		ShipNames.SERENADE:
			$Sprite2D.texture = preload("res://assets/Ships/serenade.png")
			$Label.text = "Serenade"
			max_ports = 3
		ShipNames.SYMPHONY:
			$Sprite2D.texture = preload("res://assets/Ships/symphony.png")
			$Label.text = "Symphony"
			max_ports = 3
		ShipNames.SUPERFAST:
			$Sprite2D.texture = preload("res://assets/Ships/superfast.png")
			$Label.text = "Superfast IX"
			max_ports = 2 

# ENi note: Gemini says that this makes the variable grayed out/read-only in the UI
# This is the "Magic" function for Godot 4 stable
func _validate_property(property: Dictionary):
	if property.name == "max_ports":
		# This adds the 'Read Only' flag to the existing export
		property.usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_READ_ONLY

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
	
