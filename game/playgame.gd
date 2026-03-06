extends Control

@onready var game_title = $CenterContainer/VBoxContainer/GameTitle
@onready var instruction_label = $CenterContainer/VBoxContainer/InstructionLabel

func _ready():
	# Add to translatable group for instant language updates
	add_to_group("translatable")
	
	# Apply translations
	Settings.setting_changed.connect(_on_setting_changed)
	_apply_translations()

func _on_setting_changed(setting_name: String, value):
	if setting_name == "language":
		_apply_translations()

func _apply_translations():
	if game_title: game_title.text = tr("GAME_TITLE")
	if instruction_label: instruction_label.text = tr("PAUSE_INSTRUCTION")

func _unhandled_input(event):
	# CR5: Pause menu implementation in game scene
	if event.is_action_pressed("pause"):
		var paused: bool = not get_tree().paused
		get_tree().paused = paused
		if paused and ResourceLoader.exists("res://ui/screens/PauseMenu.tscn"):
			var pause_menu: Node = load("res://ui/screens/PauseMenu.tscn").instantiate()
			get_tree().root.add_child(pause_menu)
