extends Node2D
class_name FerryLine

var line_color: Color
var ports: Array[Port] = []
@onready var path_node: Path2D = $Path2D
@onready var line_renderer: Line2D = $Line2D

func _ready():
	line_renderer.default_color = line_color

func add_port(new_port: Port):
	ports.append(new_port)
	_update_navigation_path()

func _update_navigation_path():
	var curve = Curve2D.new()
	
	for i in range(ports.size()):
		var p_pos = ports[i].global_position
		
		if i == 0:
			curve.add_point(p_pos)
		else:
			# Calculate curve handles between ports for that "Nautical Arc"
			var prev_pos = ports[i-1].global_position
			var mid = (prev_pos + p_pos) / 2
			var dir = (p_pos - prev_pos).normalized()
			var normal = Vector2(-dir.y, dir.x) * 60 # The "Curve" intensity
			
			# Add point with a control handle to create the bend
			curve.add_point(p_pos, mid + normal - p_pos) 
	
	path_node.curve = curve
	line_renderer.points = curve.get_baked_points()
