extends Control
class_name MainMenu


@onready var start_button: Button = $Fieldpixelart/HBoxContainer/VBoxContainer/startButton
@onready var quit_button: Button = $Fieldpixelart/HBoxContainer/VBoxContainer/quitButton
@onready var setting_button: Button = $Fieldpixelart/HBoxContainer/VBoxContainer/settingButton
@export var start_level: PackedScene = preload("res://Scenes/Levels/level1.tscn")

func _ready():
	print("ready")
	start_button.pressed.connect(on_start_down)
	quit_button.pressed.connect(on_exit_pressed)

func on_start_down() -> void:
	get_tree().change_scene_to_packed(start_level)

func on_exit_pressed() -> void:
	get_tree().quit()
