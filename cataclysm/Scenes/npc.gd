extends CharacterBody2D

@export var dialogue_resource: DialogueResource
var player_in_range := false

func _ready():
	$InteractionZone.body_entered.connect(_on_body_entered)
	$InteractionZone.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		
func _process(delta):
<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
	if player_in_range and Input.is_action_just_pressed("hello"):
		DialogueManager.show_dialogue(dialogue_resource, "start")
=======
	if player_in_range and Input.is_action_just_pressed("interact"):
		if dialogue_resource:
			DialogueManager.show_dialogue(dialogue_resource, "start")
>>>>>>> Stashed changes
=======
	if player_in_range and Input.is_action_just_pressed("interact"):
		if dialogue_resource:
			DialogueManager.show_dialogue(dialogue_resource, "start")
>>>>>>> Stashed changes
=======
	if player_in_range and Input.is_action_just_pressed("interact"):
		if dialogue_resource:
			DialogueManager.show_dialogue(dialogue_resource, "start")
>>>>>>> Stashed changes
=======
	if player_in_range and Input.is_action_just_pressed("interact"):
		if dialogue_resource:
			DialogueManager.show_dialogue(dialogue_resource, "start")
>>>>>>> Stashed changes
