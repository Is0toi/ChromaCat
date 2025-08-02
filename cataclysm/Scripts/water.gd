extends Area2D

func _on_body_entered(body):
	if body.name == "mainchar" or body.is_in_group("player"):
		body.global_position = Vector2(-240, -11)
		body.velocity = Vector2.ZERO
