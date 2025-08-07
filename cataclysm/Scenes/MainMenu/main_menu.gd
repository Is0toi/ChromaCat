extends Control
class_name MainMenu

@onready var start_button: Button = $Fieldpixelart/HBoxContainer/MainButtons/startButton
@onready var quit_button: Button = $Fieldpixelart/HBoxContainer/MainButtons/quitButton
@onready var settings_button: Button = $Fieldpixelart/HBoxContainer/MainButtons/settingsButton
@export var start_level: PackedScene = preload("res://Scenes/Levels/level1.tscn")
@onready var main_buttons: VBoxContainer = $Fieldpixelart/HBoxContainer/MainButtons
@onready var options: Panel = $Options
@onready var title: Label = $Fieldpixelart/Title


func _ready():
	main_buttons.visible = true
	options.visible = false
	title.visible = true
	start_button.pressed.connect(on_start_down)
	quit_button.pressed.connect(on_exit_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	

func on_start_down() -> void:
	get_tree().change_scene_to_packed(start_level)

func on_exit_pressed() -> void:
	get_tree().quit()
	
func _on_settings_pressed():
	main_buttons.visible = false
	options.visible = true
	title.visible = false


func _on_back_pressed() -> void:
	_ready()
