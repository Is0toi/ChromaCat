extends RigidBody2D

func _physics_process(delta):
	rotation = 0  # Force reset rotation every frame
	angular_velocity = 0  # Kill rotational velocity
	
	# Optional: Small position nudge if velocity is stuck
	if linear_velocity.length() < 5.0 and get_contact_count() > 0:
		position += linear_velocity.normalized() * 0.5
