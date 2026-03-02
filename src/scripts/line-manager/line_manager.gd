extends Node2D

@export var ferry_line_scene: PackedScene = preload("res://src/scripts/ferry-line/FerryLine.tscn")

@onready var temp_line = $TempLine
@onready var routes_container = $Routes

var is_dragging: bool = false
var start_port: Port = null
var hovered_port: Port = null # Updated via signals from Ports

func _ready():
	temp_line.visible = false
	GameSignals.port_clicked.connect(_on_port_clicked)
	GameSignals.port_hovered.connect(_on_port_hovered)

func _on_port_clicked(port: Port):
	print("onPortclicked:", Port)
	is_dragging = true
	start_port = port
	temp_line.visible = true
	temp_line.points = [port.global_position, port.global_position]

func _on_port_hovered(port: Port):
	hovered_port = port

func _process(_delta):
	if is_dragging:
		# Update the "Elastic String" visual
		temp_line.set_point_position(0, start_port.global_position)
		temp_line.set_point_position(1, get_global_mouse_position())

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed and is_dragging:
			print("finalize connection")
			finalize_connection()

func finalize_connection():
	is_dragging = false
	temp_line.visible = false
	print("finalize, ",hovered_port,start_port)
	
	# Check if we released over a valid different port
	if hovered_port and hovered_port != start_port:
		print("create route")
		create_route(start_port, hovered_port)
	
	start_port = null

func create_route(p1: Port, p2: Port):
	var new_route = ferry_line_scene.instantiate()
	routes_container.add_child(new_route)
	# This calls the curved drawing logic
	new_route.add_port(p1)
	new_route.add_port(p2)
