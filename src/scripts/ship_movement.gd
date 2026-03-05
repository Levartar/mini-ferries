#ENI Note: trying to understand Godot with help of Gemini.
# Speedrunning this shit.
extends Node2D

var selected_ship: Ship = null
@export var ship_parent: Node2D
# Called when the node enters the scene tree for the first time.
func _ready():
	$CanvasLayer/HBoxContainer.ship_selected.connect(_on_selection)

func _on_selection(ship: Ship.ShipNames):
	var all_ships = ship_parent.get_children()
	
	for s in all_ships:
		if s is Ship and s.ship_name == ship:
			selected_ship = s
			# Convert enum index to string name for the printout
			var type_name = Ship.ShipNames.keys()[ship]
			print("Now controlling the ", type_name, "!")
			break
		
func _on_ship_selected(ship: Ship):
	selected_ship = ship
	print("Ship",ship.ship_name, "selected.")
	
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if selected_ship:
			var mouse_pos = get_global_mouse_position()
			_handle_ports(mouse_pos)
			
func _handle_ports(pos: Vector2):
	if selected_ship.assigned_ports.size() >= selected_ship.max_ports:
		selected_ship.assigned_ports.clear()
		selected_ship.target_index = 0
	
	selected_ship.assigned_ports.append(pos)
	
	_draw_ship_path(selected_ship)
		
	if selected_ship.assigned_ports.size() == selected_ship.max_ports:
		# Teleport ant to the first food source so it doesn't walk from (0,0)
		selected_ship.global_position = selected_ship.assigned_ports[0]
		
		# Show the ant and start its movement
		selected_ship.show()
		selected_ship.set_process(true)
		selected_ship = null
	
func _draw_ship_path(ship: Ship):
	if ship.has_node("PathLine"):
		ship.get_node("PathLine").queue_free()
	
	var line = Line2D.new()
	line.name = "PathLine"
	line.width = 3.0
	line.default_color = Color(0.2, 0.8, 0.2, 0.6)
	
	for p in ship.assigned_ports:
		line.add_point(p - ship.global_position) # Use local coordinates
	
	ship.add_child(line)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
