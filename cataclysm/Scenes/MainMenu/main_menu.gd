extends Control
class_name MainMenu

@onready var start_button: Button = $Fieldpixelart/HBoxContainer/VBoxContainer/startButton
@onready var quit_button: Button = $Fieldpixelart/HBoxContainer/VBoxContainer/quitButton
@onready var setting_button: Button = $Fieldpixelart/HBoxContainer/VBoxContainer/settingButton

const LEVEL_1_PATH := "res://Scenes/Levels/level1.tscn"

func _ready():
	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_exit_pressed)
	if setting_button:
		setting_button.pressed.connect(_on_settings_pressed)

func _on_start_pressed():
	# Double-check the scene exists and is valid
	if not FileAccess.file_exists(LEVEL_1_PATH):
		push_error("Scene file doesn't exist at path: ", LEVEL_1_PATH)
		return
	
	# Try to load the scene
	var level_scene = load(LEVEL_1_PATH)
	if level_scene == null:
		push_error("Failed to load scene - it may be corrupted")
		return
	
	# Verify it's a valid PackedScene
	if not level_scene is PackedScene:
		push_error("Loaded resource is not a scene")
		return
	
	get_tree().change_scene_to_packed(level_scene)

func _on_exit_pressed():
	get_tree().quit()

func _on_settings_pressed():
	print("Settings button pressed")
