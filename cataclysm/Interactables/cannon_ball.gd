extends Node2D

var direction := 1
var speed := 200.0
var lifetime := 2.0
var hit := false

func _ready() -> void:
	print("CANNONBALL: _ready() — global_pos:", global_position, "direction:", direction)
	# Auto-connect area_entered if the Area2D exists but isn't connected
	if has_node("Area2D"):
		var area = $Area2D
		if not area.is_connected("area_entered", Callable(self, "_on_area_2d_area_entered")):
			area.connect("area_entered", Callable(self, "_on_area_2d_area_entered"))
			print("CANNONBALL: connected Area2D.area_entered -> _on_area_2d_area_entered")
		else:
			print("CANNONBALL: Area2D.area_entered already connected")
		# Print collision layer/mask for debugging
		if area is CollisionObject2D:
			print("CANNONBALL: Area2D layers:", area.collision_layer, "mask:", area.collision_mask)
	else:
		print("CANNONBALL: WARNING — no Area2D node found")

	# Start lifetime timer
	await get_tree().create_timer(lifetime).timeout
	if not hit:
		_die()

func _physics_process(delta: float) -> void:
	position.x += speed * delta * direction

func _die() -> void:
	hit = true
	speed = 0
	if $AnimationPlayer:
		$AnimationPlayer.play("Hit")
		await get_tree().create_timer(0.2).timeout
	queue_free()

# This will be called when another Area2D enters this ball's Area2D
func _on_area_2d_area_entered(area: Area2D) -> void:
	print("CANNONBALL: area_entered by", area, "parent:", area.get_parent())
	var parent = area.get_parent()
	if parent != null:
		# First try parent.take_damage
		if parent.has_method("take_damage") and not hit:
			print("CANNONBALL: calling parent.take_damage(1)")
			parent.take_damage(1)
			_die()
			return

		# Otherwise search upward the ancestor chain for a node with take_damage
		var node = parent
		while node != null:
			if node.has_method("take_damage") and not hit:
				print("CANNONBALL: found ancestor with take_damage:", node)
				node.take_damage(1)
				_die()
				return
			node = node.get_parent()

	# If nothing, print helpful debug info
	print("CANNONBALL: No take_damage found on collided parent/ancestors. area parent chain:")
	var p = area.get_parent()
	while p:
		print("  -", p, "class:", p.get_class(), "methods:", p.get_method_list().size())
		p = p.get_parent()
