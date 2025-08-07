extends Node2D

@export var cannon_ball_scene: PackedScene
@export var shooting := true
@export var fire_rate := 1.0

@onready var fire_timer: Timer = $FireTimer
@onready var fire_point: Marker2D = $FirePoint

func _ready():
	if not cannon_ball_scene:
		printerr("ERROR: Assign cannon_ball_scene in inspector!")
		return

	fire_timer.wait_time = fire_rate
	fire_timer.one_shot = false  # ← MAKE SURE the timer loops
	fire_timer.timeout.connect(_on_FireTimer_timeout)

	if shooting:
		fire_timer.start()

func _on_FireTimer_timeout():
	fire()

func fire():
	print("Firing cannonball")
	
	var ball = cannon_ball_scene.instantiate()
	ball.global_position = fire_point.global_position
	
	if ball.has_variable("direction"):
		ball.direction = sign(scale.x) if scale.x != 0 else 1
	
	if ball.has_variable("speed"):
		ball.speed = 300
	
	get_tree().current_scene.add_child(ball)
	print("Ball fired from: ", fire_point.global_position)
