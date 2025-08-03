extends Area2D

@onready var splash: AudioStreamPlayer = $Splash

func _on_body_entered(body):
	if body.name == "mainchar" or body.is_in_group("player"):
		splash.play()
		body.global_position = Vector2(-240, -11)
		body.velocity = Vector2.ZERO
