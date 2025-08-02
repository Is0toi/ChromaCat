extends Area2D

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.is_ability_active():
			print("can't pass when ability active")
			return

		var current_path = get_tree().current_scene.scene_file_path
		var next_path = current_path.replace(
			str(_get_level_number(current_path)),
			str(_get_level_number(current_path) + 1)
		)
		
		if ResourceLoader.exists(next_path):
			get_tree().change_scene_to_file(next_path)

func _get_level_number(path: String) -> int:
	var file_name = path.get_file()
	return file_name.trim_prefix("level").trim_suffix(".tscn").to_int()
