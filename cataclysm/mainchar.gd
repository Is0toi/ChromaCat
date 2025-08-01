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

func _ready():
	_update_data()

func _update_data():
	acceleration = maxSpeed / max(timeToReachMaxSpeed, 0.01)
	deceleration = -maxSpeed / max(timeToReachZeroSpeed, 0.01)
	jumpMagnitude = (10.0 * jumpHeight) * gravityScale
	jumpCount = jumps

	if jumps > 1:
		jumpBuffering = 0
		coyoteTime = 0

func _physics_process(delta):
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
