extends MarginContainer

@onready var score_label = $HBoxContainer/Label

var total_passengers: int = 0

func _ready():
	# Initialize the text
	_update_display()
	
	# Listen for the global delivery signal
	GameSignals.passengers_delivered.connect(_on_passengers_delivered)

func _on_passengers_delivered(count: int):
	total_passengers += count
	_update_display()
	
	# Optional: Add a small "pop" animation when the score increases
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

func _update_display():
	score_label.text = str(total_passengers)
