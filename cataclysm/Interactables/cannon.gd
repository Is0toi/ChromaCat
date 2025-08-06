extends Node2D

var cannon_ball := preload("res://Interactables/cannon_ball.tscn")

@export var shooting: bool = true
var firerate := 2.0

@export var firepoint_path: NodePath
@onready var firepoint: Node = null

var max_health := 3
var health := 0

func _ready() -> void:
	if firepoint_path != null and str(firepoint_path) != "":
		firepoint = get_node_or_null(firepoint_path)
		print_debug("Tried firepoint_path:", firepoint_path, " -> ", firepoint)

	if firepoint == null:
		firepoint = get_node_or_null("Area2D/Firepoint")
		print_debug("Tried 'Area2D/Firepoint' -> ", firepoint)

	if firepoint == null:
		firepoint = find_child("Firepoint", true, false)
		print_debug("Tried find_child('Firepoint') -> ", firepoint)

	if firepoint == null:
		var area = get_node_or_null("Area2D")
		if area:
			for child in area.get_children():
				if child.name.to_lower() == "firepoint":
					firepoint = child
					break
			print_debug("Searched children of Area2D -> ", firepoint)

	if firepoint == null:
		push_error("CANNON: Firepoint node still not found. Check node names/paths.")
		return  # don't permanently disable shooting here; just don't start the loop

	print("CANNON: Firepoint found:", firepoint, "Class:", firepoint.get_class(), "Global pos:", firepoint.global_position)
	health = max_health

	# Ensure shooting is true if we want the cannon to actively shoot
	shooting = true

	call_deferred("shoot")


func shoot() -> void:
	print("CANNON: entering shoot loop. shooting =", shooting, "firerate =", firerate)
	while shooting:
		print("CANNON: about to fire()")
		fire()
		print("CANNON: fired; waiting for timer...")
		await get_tree().create_timer(firerate).timeout
		print("CANNON: timer done, loop continues")


func fire() -> void:
	if firepoint == null:
		push_error("Cannon tried to fire but firepoint is null (shouldn't happen).")
		return
	var spawned_ball = cannon_ball.instantiate()
	var spawn_pos = firepoint.global_position
	print("CANNON: spawning ball at", spawn_pos)
	spawned_ball.global_position = spawn_pos

	var dir := 1
	if firepoint.has_method("get_direction"):
		dir = int(firepoint.get_direction())
	elif firepoint.scale.x != 0:
		dir = sign(firepoint.scale.x)
	spawned_ball.direction = dir
	print("CANNON: ball direction set to", dir)

	get_parent().add_child(spawned_ball)
