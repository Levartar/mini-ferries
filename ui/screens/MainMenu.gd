extends Control

@onready var play_button = $CenterContainer/VBoxContainer/MenuButtons/PlayButton
@onready var settings_button = $CenterContainer/VBoxContainer/MenuButtons/SettingsButton
@onready var credits_button = $CenterContainer/VBoxContainer/MenuButtons/CreditsButton
@onready var exit_button = $CenterContainer/VBoxContainer/MenuButtons/ExitButton
@onready var game_title = $CenterContainer/VBoxContainer/GameTitle

func _ready():
	# Add to translatable group for instant language updates
	add_to_group("translatable")
	
	if play_button: play_button.pressed.connect(_on_play_pressed)
	if settings_button: settings_button.pressed.connect(_on_settings_pressed)
	if credits_button: credits_button.pressed.connect(_on_credits_pressed)
	if exit_button: exit_button.pressed.connect(_on_exit_pressed)
	
	# BR1 Fix: Connect to language changes
	Settings.setting_changed.connect(_on_setting_changed)
	
	_setup_navigation()
	_apply_translations()
	if play_button: play_button.grab_focus()

func _on_setting_changed(setting_name: String, value):
	if setting_name == "language":
		_apply_translations()

func _apply_translations():
	# Fallback texts in case translations aren't loaded
	var fallbacks = {
		"MAIN_MENU_TITLE": "Main Menu",
		"PLAY": "Play", 
		"SETTINGS": "Settings",
		"CREDITS": "Credits",
		"EXIT": "Exit"
	}
	
	var title_text = tr("Mini-Ferries")
	if title_text == "MAIN_MENU_TITLE":  # Translation not found, use fallback
		title_text = fallbacks.get("MAIN_MENU_TITLE", "Main Menu")
	
	if game_title: game_title.text = title_text
	if play_button: play_button.text = tr("PLAY") if tr("PLAY") != "PLAY" else fallbacks.get("PLAY", "Play")
	if settings_button: settings_button.text = tr("SETTINGS") if tr("SETTINGS") != "SETTINGS" else fallbacks.get("SETTINGS", "Settings")
	if credits_button: credits_button.text = tr("CREDITS") if tr("CREDITS") != "CREDITS" else fallbacks.get("CREDITS", "Credits")
	if exit_button: exit_button.text = tr("EXIT") if tr("EXIT") != "EXIT" else fallbacks.get("EXIT", "Exit")

func _setup_navigation():
	if play_button and settings_button:
		play_button.focus_neighbor_bottom = settings_button.get_path()
	if settings_button and credits_button:
		settings_button.focus_neighbor_top = play_button.get_path()
		settings_button.focus_neighbor_bottom = credits_button.get_path()
	if credits_button and exit_button:
		credits_button.focus_neighbor_top = settings_button.get_path()
		credits_button.focus_neighbor_bottom = exit_button.get_path()
	if exit_button:
		exit_button.focus_neighbor_top = credits_button.get_path()
		exit_button.focus_neighbor_bottom = play_button.get_path()
	if play_button:
		play_button.focus_neighbor_top = exit_button.get_path()

func _on_play_pressed():
	SceneLoader.goto_scene("res://ui/screens/PlayGame.tscn", false)

func _on_settings_pressed():
	SceneLoader.goto_scene("res://ui/screens/OptionsMenu.tscn", false)

func _on_credits_pressed():
	SceneLoader.goto_scene("res://ui/screens/CreditsMenu.tscn", false)

func _on_exit_pressed():
	get_tree().quit()
