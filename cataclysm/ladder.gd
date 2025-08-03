extends Area2D

@export var climb_speed := 180.0

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node):
	if body.is_in_group("player"):
		body.is_on_ladder = true
		body.velocity.y = 0  
		print("Ladder Entered")

func _on_body_exited(body: Node):
	if body.is_in_group("player"):
		body.is_on_ladder = false
		print("Ladder exited")
