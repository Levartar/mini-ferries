extends Control

func _ready() -> void:
	await get_tree().process_frame
	await get_tree().create_timer(1.0).timeout
	SceneLoader.goto_scene("res://ui/screens/MainMenu.tscn", false)
