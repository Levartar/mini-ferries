extends Node2D

@onready var line_renderer: Line2D = $Line2D
var curve: Curve2D = Curve2D.new()

func create_route(start_pos: Vector2, end_pos: Vector2):
	curve.clear_points()
	
	# 1. Define the start
	curve.add_point(start_pos)
	
	# 2. Calculate the "Midpoint Offset" for the curve
	var midpoint = (start_pos + end_pos) / 2
	var direction = (end_pos - start_pos).normalized()
	var perpendicular = Vector2(-direction.y, direction.x) 
	
	# Offset the control point by 50 units to create the arc
	# You can vary 'curvature_amount' to make some lines flatter
	var curvature_amount = 50 
	var control_point = midpoint + (perpendicular * curvature_amount)
	
	# 3. Add the end point with the control point handle (in_gradient)
	# Note: In Curve2D, handles are relative to the point
	var handle_in = control_point - end_pos
	curve.add_point(end_pos, handle_in)
	
	# 4. Update the visual Line2D
	# We "bake" the curve into points so the Line2D looks smooth
	line_renderer.points = curve.get_baked_points()
