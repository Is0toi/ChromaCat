extends Area2D

func _on_body_entered(body):
	if body.name == "mainchar" or body.is_in_group("player"):
		var level = get_tree().current_scene
		if level and level.scene_file_path:
			get_tree().change_scene_to_file.call_deferred(level.scene_file_path)
