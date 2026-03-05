extends Area2D
class_name Ship

enum ShipTypes {TWO, THREE}
enum ShipNames {QUEEN, PRINCESS, MEGASTAR}

@export var ship_name: ShipNames = ShipNames.QUEEN
var ship_type: ShipTypes = ShipTypes.TWO
var max_ports: int = 2

static var ShipTags = {
	ShipNames.QUEEN: "Baltic Queen",
	ShipNames.PRINCESS: "Baltic Princess",
	ShipNames.MEGASTAR: "Megastar"
}

static var ShipIcons = {
	ShipNames.QUEEN: preload("res://assets/Ships/baltic_queen.png"),
	ShipNames.PRINCESS: preload("res://assets/Ships/baltic_princess.png"),
	ShipNames.MEGASTAR: preload("res://assets/Ships/megastar.png")
}
const SHIP_ICON = preload("res://assets/sprites/icons/tracking_horizontal.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.texture = ShipIcons.get(ship_name, preload("res://assets/sprites/icons/tracking_horizontal.png"))
	$Label.text = ShipTags.get(ship_name, "What Is This?")
	if ship_name != ShipNames.PRINCESS:
		ship_type = ShipTypes.THREE
		max_ports = 3


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
	
