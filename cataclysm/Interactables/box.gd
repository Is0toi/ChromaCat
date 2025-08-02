extends RigidBody2D

func _ready():
	lock_rotation = true
	center_of_mass_mode = RigidBody2D.CENTER_OF_MASS_MODE_CUSTOM
	center_of_mass = Vector2(0, 0)
