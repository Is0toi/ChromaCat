extends Area2D

@export var climb_speed: float = 100.0

func _ready():
	pass

func _on_body_entered(body: Node2D) -> void:
	if body.name == "mainchar" or body.is_in_group("player"):
		body.on_ladder = true


func _on_body_exited(body: Node2D) -> void:
	if body.name == "mainchar" or body.is_in_group("player"):
		body.on_ladder = false
