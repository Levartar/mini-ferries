extends HBoxContainer

# Signal to tell the Main script which ant index was chosen
signal ship_selected(ship: Ship.ShipNames)

func _ready():
	var buttons = get_children()
	for i in range(buttons.size()):
		if buttons[i] is Button:
			# Pass the enum value directly using the index
			buttons[i].pressed.connect(_on_pressed.bind(i as Ship.ShipNames))

func _on_pressed(ship: Ship.ShipNames):
	ship_selected.emit(ship)
