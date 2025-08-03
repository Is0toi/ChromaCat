extends CharacterBody2D

@export var speed := 200.0
@export var move_distance := 100.0

var direction := 1
var start_position: Vector2
var is_frozen := false


func _ready():
	start_position = global_position
	$AnimatedSprite2D.play("walk")
	
func _physics_process(delta):
	position.x += direction * speed * delta
	if abs(position.x - start_position.x) >= move_distance:
		direction *= -1
		$AnimatedSprite2D.flip_h = direction < 0

func _on_area_2d_body_entered(body):
	if body.name == "mainchar" or body.is_in_group("player"):
		body.global_position = Vector2(-240, -11)
		body.velocity = Vector2.ZERO
