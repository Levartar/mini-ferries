extends Node2D

@export var ferry_line_scene: PackedScene = preload("res://src/scripts/ferry-line/FerryLine.tscn")

@onready var temp_line = $TempLine
@onready var routes_container = $Routes

var is_dragging: bool = false
var active_line: FerryLine = null
var start_port: Port = null
var hovered_port: Port = null # Updated via signals from Ports

func _ready():
	temp_line.visible = false
	GameSignals.port_clicked.connect(_on_port_clicked)
	GameSignals.port_hovered.connect(_on_port_hovered)

func _on_port_clicked(port: Port):
	print("onPortclicked:", Port)
	is_dragging = true
	active_line = ferry_line_scene.instantiate()
	active_line.line_color = LinePalette.get_next_color()
	add_child(active_line)
	
	active_line.add_port(port)
	
	temp_line.visible = true
	temp_line.default_color = active_line.line_color

func _on_port_hovered(port: Port):
	if is_dragging and active_line:
		# Only add if it's not already the most recent port (prevents loops/flicker)
		if port != active_line.ports.back():
			active_line.add_port(port)

func _process(_delta):
	if is_dragging and active_line:
		# The "Elastic String" always starts from the LAST port in our chain
		var last_port_pos = active_line.ports.back().global_position
		temp_line.points = [last_port_pos, get_global_mouse_position()]

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed and is_dragging:
			finish_dragging()

func finish_dragging():
	is_dragging = false
	temp_line.visible = false
	
	# If the line only has 1 port, it's not a route. Delete it.
	if active_line.ports.size() < 2:
		active_line.queue_free()
	else:
		print("Route created with ", active_line.ports.size(), " ports!")
	
	active_line = null
