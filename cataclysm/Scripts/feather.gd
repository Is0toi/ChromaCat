extends Area2D

func _on_body_entered(body):
	if body.name == "mainchar" or body.is_in_group("player"):
		print("+1 coin")
		queue_free()
