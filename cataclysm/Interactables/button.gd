extends Area2D

@onready var sprite = $AnimatedSprite2D
@export var platform: StaticBody2D

func _ready():
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	sprite.play("idle")
	
var pressing_bodies = 0

func _on_body_entered(body):
	pressing_bodies += 1
	sprite.play("pressed")
	if platform and platform.has_node("CollisionShape2D"):
		platform.visible = true
		platform.get_node("CollisionShape2D").set_deferred("disabled", false)
	
func _on_body_exited(body):
	pressing_bodies -= 1
	if pressing_bodies <= 0:
		pressing_bodies =0
		sprite.play("release")
		if platform and platform.has_node("CollisionShape2D"):
			platform.visible = false
			platform.get_node("CollisionShape2D").set_deferred("disabled", true)
