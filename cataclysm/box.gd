extends RigidBody2D

func _ready():
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	angular_damp = 0
