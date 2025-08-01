extends CharacterBody2D
class_name PlatformerController2D

@export var PlayerSprite: AnimatedSprite2D
@export var PlayerCollider: CollisionShape2D

@export_category("Movement")
@export_range(50, 500) var maxSpeed: float = 200.0
@export_range(0, 4) var timeToReachMaxSpeed: float = 0.2
@export_range(0, 4) var timeToReachZeroSpeed: float = 0.2
@export var directionalSnap: bool = false

@export_category("Jumping")
@export_range(0, 20) var jumpHeight: float = 2.0
@export_range(0, 4) var jumps: int = 1
@export_range(0, 100) var gravityScale: float = 20.0
@export_range(0, 1000) var terminalVelocity: float = 500.0
@export var shortHop: bool = true
@export_range(1, 10) var jumpVariable: float = 2
@export_range(0, 0.5) var coyoteTime: float = 0.2
@export_range(0, 0.5) var jumpBuffering: float = 0.2

var acceleration: float
var deceleration: float
var jumpMagnitude: float
var jumpCount: int
var appliedGravity: float

var coyoteActive: bool = false
var jumpWasPressed: bool = false
var jumpBufferTimerRunning: bool = false

var leftHold: bool
var rightHold: bool
var jumpTap: bool
var jumpRelease: bool
# For noclip
var is_phasing: bool = false
var phase_timer: Timer

# For teleporting
var teleport_origin: Vector2
var teleport_return_timer: Timer

var teleport_cooldown := false
var teleport_cooldown_timer: Timer

func _ready():
	_update_data()
	add_to_group("player")
	
	phase_timer = Timer.new()
	phase_timer.one_shot = true
	phase_timer.wait_time = 3.0
	phase_timer.timeout.connect(_on_phase_timeout)
	add_child(phase_timer)

	teleport_return_timer = Timer.new()
	teleport_return_timer.one_shot = true
	teleport_return_timer.wait_time = 1.5
	teleport_return_timer.timeout.connect(_on_teleport_return_timeout)
	add_child(teleport_return_timer)

	teleport_cooldown_timer = Timer.new()
	teleport_cooldown_timer.one_shot = true
	teleport_cooldown_timer.wait_time = 2.0
	teleport_cooldown_timer.timeout.connect(_on_teleport_cooldown_timeout)
	add_child(teleport_cooldown_timer)


func _update_data():
	acceleration = maxSpeed / max(timeToReachMaxSpeed, 0.01)
	deceleration = -maxSpeed / max(timeToReachZeroSpeed, 0.01)
	jumpMagnitude = (10.0 * jumpHeight) * gravityScale
	jumpCount = jumps

	if jumps > 1:
		jumpBuffering = 0
		coyoteTime = 0

func _physics_process(delta):
	# Input state
	leftHold = Input.is_action_pressed("left")
	rightHold = Input.is_action_pressed("right")
	jumpTap = Input.is_action_just_pressed("jump")
	jumpRelease = Input.is_action_just_released("jump")

	# Horizontal movement
	if rightHold and !leftHold:
		velocity.x += acceleration * delta
		velocity.x = min(velocity.x, maxSpeed)
	elif leftHold and !rightHold:
		velocity.x -= acceleration * delta
		velocity.x = max(velocity.x, -maxSpeed)
	else:
		velocity.x = move_toward(velocity.x, 0, -deceleration * delta)

	# Gravity
	appliedGravity = gravityScale if velocity.y <= 0 else gravityScale
	if velocity.y < terminalVelocity:
		velocity.y += appliedGravity
	else:
		velocity.y = terminalVelocity

	# Variable jump height
	if shortHop and jumpRelease and velocity.y < 0:
		velocity.y /= jumpVariable

	# Coyote time
	if !is_on_floor() and coyoteTime > 0 and !coyoteActive:
		coyoteActive = true
		_start_coyote_timer()
	elif is_on_floor():
		coyoteActive = false
		jumpCount = jumps

	# Jump buffering
	if jumpTap:
		if is_on_floor() or coyoteActive:
			_jump()
		elif jumpBuffering > 0:
			jumpWasPressed = true
			if !jumpBufferTimerRunning:
				_start_jump_buffer_timer()

	# Execute buffered jump
	if is_on_floor() and jumpWasPressed:
		_jump()

	move_and_slide()

	# Flip the sprite
	if velocity.x > 0:
		PlayerSprite.flip_h = false
	elif velocity.x < 0:
		PlayerSprite.flip_h = true

	# Play animations
	if is_on_floor():
		if velocity.x == 0:
			PlayerSprite.play("idle")
		else:
			PlayerSprite.play("walk")
	else:
		PlayerSprite.play("jump")
	
	if Input.is_action_just_pressed("phase") and not is_phasing:
		_start_phasing()
	
	if Input.is_action_just_pressed("teleport") and not teleport_cooldown:
		_teleport_to_cursor()

func _teleport_to_cursor():
	# logic for if theres a wall
	var target_posiiton = get_global_mouse_position()
	var collision = move_and_collide(target_posiiton - global_position, true)

	if collision:
		print("Teleport blocked: collision with wall")
		return
	
	# if possible
	teleport_origin = global_position # save curr pos
	global_position = get_global_mouse_position() # teleport
	teleport_return_timer.start() # teleport back timer

	# cooldown
	teleport_cooldown = true
	teleport_cooldown_timer.start()

func _on_teleport_return_timeout():
	global_position = teleport_origin  # return to saved pos

func _start_phasing():
	is_phasing = true
	collision_mask = 1 << 1  
	PlayerSprite.modulate.a = 0.5 
	phase_timer.start()
	print("Phasing started")

func _on_phase_timeout():
	is_phasing = false
	collision_mask = 0xFFFFFFFF
	PlayerSprite.modulate.a = 1.0  # Restore visibility
	print("Phasing ended")

func _jump():
	if jumpCount > 0:
		velocity.y = -jumpMagnitude
		jumpCount -= 1
		jumpWasPressed = false

func _start_coyote_timer():
	await get_tree().create_timer(coyoteTime).timeout
	coyoteActive = false

func _start_jump_buffer_timer():
	jumpBufferTimerRunning = true
	await get_tree().create_timer(jumpBuffering).timeout
	jumpWasPressed = false
	jumpBufferTimerRunning = false

#box collisions
func _on_area_2d_body_entered(body):
	if body.is_in_group("RigidBody"):
		body.collision_layer = 1 
		body.collision_mask = 1   

func _on_area_2d_body_exited(body):
	if body.is_in_group("RigidBody"):
		body.collision_layer = 3  
		body.collision_mask = 3 

func _on_teleport_cooldown_timeout():
	teleport_cooldown = false
