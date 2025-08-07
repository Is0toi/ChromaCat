extends Node2D

@onready var pause_menu: Control = $CanvasLayer/PauseMenu
var paused = false

func _ready():
	pause_menu.hide()

func _process(delta):
	if Input.is_action_just_pressed("pause"):
		toggle_pause_menu()

func toggle_pause_menu():
	if not pause_menu:
		printerr("ERROR: PauseMenu node not found!")
		return

	if paused:
		pause_menu.hide()
		Engine.time_scale = 1
	else:
		pause_menu.show()
		Engine.time_scale = 0

	paused = !paused
