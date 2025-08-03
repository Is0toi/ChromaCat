extends Area2D

func _on_body_entered(body):
	if body.name == "mainchar" or body.is_in_group("player"):
		print("+1 coin")
		Global.score += 1
		queue_free()
