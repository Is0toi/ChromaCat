extends CharacterBody2D
class_name PlatformerController2D

@export var PlayerSprite: AnimatedSprite2D
@export var PlayerCollider: CollisionShape2D

@onready var ladder_ray_cast: RayCast2D= $LadderRayCast

#SFX
@onready var jump: AudioStreamPlayer = $jump
@onready var glitch: AudioStreamPlayer = $glitch

@export_category("Movement")
@export_range(50, 500) var maxSpeed: float = 200.0
@export_range(0, 4) var timeToReachMaxSpeed: float = 0.1
@export_range(0, 4) var timeToReachZeroSpeed: float = 0.1
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

const SPEED = 100.0
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
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

var is_phasing: bool = false
var phase_timer: Timer
var teleport_origin: Vector2
var teleport_return_timer: Timer
var teleport_cooldown := false
var teleport_cooldown_timer: Timer
var freeze_cooldown := false
var freeze_cooldown_timer: Timer
var push_force = 120.0
var glitch_mode := false

var on_ladder: bool = false
var dead = false

var max_health = 1
var health

func _ready():
	health = max_health
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

	freeze_cooldown_timer = Timer.new()
	freeze_cooldown_timer.one_shot = true
	freeze_cooldown_timer.wait_time = 9.0
	freeze_cooldown_timer.timeout.connect(_on_freeze_cooldown_timeout)
	add_child(freeze_cooldown_timer)

func _update_data():
	acceleration = maxSpeed / max(timeToReachMaxSpeed, 0.01)
	deceleration = -maxSpeed / max(timeToReachZeroSpeed, 0.01)
	jumpMagnitude = (10.0 * jumpHeight) * gravityScale
	jumpCount = jumps
	if jumps > 1:
		jumpBuffering = 0
		coyoteTime = 0
		
func _physics_process(delta):
	var ladder_collider = ladder_ray_cast.get_collider()
	
	if ladder_collider:
		PlayerSprite.play("climb")
		_ladder_climb(delta)
	else: _movement(delta)
	
	move_and_slide()
	
func _ladder_climb(delta):
	var direction := Vector2.ZERO
	direction.x = Input.get_axis("left", "right")
	direction.y = Input.get_axis("climb_up", "climb_down")
	
	if direction: velocity = direction * maxSpeed / 2
	else: velocity = Vector2.ZERO
	
func _movement(delta):
	leftHold = Input.is_action_pressed("left")
	rightHold = Input.is_action_pressed("right")
	jumpTap = Input.is_action_just_pressed("jump")
	jumpRelease = Input.is_action_just_released("jump")

	if rightHold and !leftHold:
		velocity.x += acceleration * delta
		velocity.x = min(velocity.x, maxSpeed)
	elif leftHold and !rightHold:
		velocity.x -= acceleration * delta
		velocity.x = max(velocity.x, -maxSpeed)
	else:
		velocity.x = move_toward(velocity.x, 0, -deceleration * delta)

	if not is_on_floor():
		velocity.y += gravity * delta
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jumpMagnitude

	if shortHop and jumpRelease and velocity.y < 0:
		velocity.y /= jumpVariable

	if !is_on_floor() and coyoteTime > 0 and !coyoteActive:
		coyoteActive = true
		_start_coyote_timer()
	elif is_on_floor():
		coyoteActive = false
		jumpCount = jumps

	if jumpTap:
		if is_on_floor() or coyoteActive:
			_jump()
			jump.play()
		elif jumpBuffering > 0:
			jumpWasPressed = true
			if !jumpBufferTimerRunning:
				_start_jump_buffer_timer()

	if is_on_floor() and jumpWasPressed:
		_jump()
		jump.play()
	
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force)

	if velocity.x > 0:
		PlayerSprite.flip_h = false
	elif velocity.x < 0:
		PlayerSprite.flip_h = true

	if is_on_floor():
		if velocity.x == 0:
			PlayerSprite.play("glitch_idle" if glitch_mode else "idle")
		else:
			PlayerSprite.play("glitch_walk" if glitch_mode else "walk")
	else:
		PlayerSprite.play("glitch_jump" if glitch_mode else "jump")
	
	if Input.is_action_just_pressed("phase") and not is_phasing and not teleport_cooldown:
		_start_phasing()
		glitch.play()
	
	if Input.is_action_just_pressed("teleport") and not teleport_cooldown:
		_teleport_to_cursor()
		glitch.play()
		
	if Input.is_action_just_pressed("freeze_enemies") and not freeze_cooldown:
		_freeze_enemies()
		glitch.play()
	
	if Input.is_action_just_pressed("reset"):
		Global.score = Global._initial_score
		get_tree().reload_current_scene()


func _teleport_to_cursor():
	if teleport_cooldown:
		print("Teleport on cooldown!")
		return

	var target_position = get_global_mouse_position()
	var original_position = global_position

	global_position = target_position
	if test_move(global_transform, Vector2.ZERO):
		global_position = original_position
		print("Teleport blocked: destination inside wall")
		return

	teleport_origin = original_position 
	teleport_return_timer.start()       

	teleport_cooldown = true
	teleport_cooldown_timer.start()

	glitch_mode = true
	await teleport_return_timer.timeout
	glitch_mode = false

func _on_teleport_cooldown_timeout():
	teleport_cooldown = false

func _on_teleport_return_timeout():
	global_position = teleport_origin

func _start_phasing():
	is_phasing = true
	glitch_mode = true
	collision_mask = 1 << 1  
	PlayerSprite.modulate.a = 0.5 
	phase_timer.start()
	print("Phasing started")

func _on_phase_timeout():
	is_phasing = false
	glitch_mode = false
	collision_mask = 0xFFFFFFFF
	PlayerSprite.modulate.a = 1.0 
	print("Phasing ended")

func _freeze_enemies():
	glitch_mode = true
	for dog in get_tree().get_nodes_in_group("enemy"):
		dog.set_physics_process(false)
		
	freeze_cooldown = true
	freeze_cooldown_timer.start()
			
	await get_tree().create_timer(3.0).timeout

	for dog in get_tree().get_nodes_in_group("enemy"):
		dog.set_physics_process(true)
	
	glitch_mode = false

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

func _on_freeze_cooldown_timeout():
	freeze_cooldown = false	

func _on_area_2d_body_entered(body):
	if body.is_in_group("RigidBody"):
		print("cat on box")
		body.collision_layer = 1 
		body.collision_mask = 1   

func _on_area_2d_body_exited(body):
	if body.is_in_group("RigidBody"):
		body.collision_layer = 3  
		body.collision_mask = 3 

func is_ability_active() -> bool:
		return teleport_return_timer.time_left > 0
		
func take_damage(damage_amount):
	health -= damage_amount
	
	if health <= 0:
		global_position = Vector2(-240, -11)
		velocity = Vector2.ZERO
		health = max_health
		PlayerSprite.play("idle")
		
