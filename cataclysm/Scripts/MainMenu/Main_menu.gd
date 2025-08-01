class_name MainMenu
extends Control

@onready var start_button: Button = $Fieldpixelart/HBoxContainer/VBoxContainer/startButton as Button
@onready var quit_button: Button = $Fieldpixelart/HBoxContainer/VBoxContainer/quitButton as Button
@export var start_level = preload("res://Scenes/Levels/level1.tscn") as PackedScene


func _ready():
	start_button.button_down.connect(on_start_down)
	quit_button.button_down.connect(on_exit_pressed)

func on_start_down() -> void:
	get_tree().change_scene_to_packed(start_level)

func on_exit_pressed() -> void:
	get_tree().quit()
