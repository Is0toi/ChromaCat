extends Area2D

@onready var interaction_zone = $InteractionZone
@onready var label = $Label

var player_in_range = false

func _ready():
	label.visible = false
	interaction_zone.body_entered.connect(_on_body_entered)
	interaction_zone.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body is Character:
		player_in_range = true

func _on_body_exited(body):
	if body is Character:
		player_in_range = false
		label.visible = false

func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		label.visible = true
		label.text = "Hi there! I'm an NPC."
