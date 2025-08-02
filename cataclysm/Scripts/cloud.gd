extends CharacterBody2D

@export var speed := 300.0
@export var move_distance := 200.0

var direction := 1
var start_position: Vector2
var is_frozen := false


func _ready():
	start_position = global_position
	$AnimatedSprite2D.play("float")
	
func _physics_process(delta):
	position.x += direction * speed * delta
	if abs(position.x - start_position.x) >= move_distance:
		direction *= -1
		$AnimatedSprite2D.flip_h = direction < 0
