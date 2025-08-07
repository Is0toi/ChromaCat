extends RigidBody2D

@export var speed := 300
var direction := 1

@onready var animated_sprite_2d = $AnimatedSprite2D

func _ready():
	gravity_scale = 0
	freeze = false
	linear_velocity = Vector2(speed * direction, 0)

	if not animated_sprite_2d or not animated_sprite_2d.sprite_frames:
		create_fallback_sprite()

	get_tree().create_timer(3.0).timeout.connect(queue_free)

func create_fallback_sprite():
	var sprite = Sprite2D.new()
	sprite.texture = load("res://icon.svg")
	sprite.scale = Vector2(0.5, 0.5)
	sprite.modulate = Color.RED
	add_child(sprite)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.global_position = Vector2(-240, -11)
	queue_free()
