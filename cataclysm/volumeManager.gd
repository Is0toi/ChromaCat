extends Node

var volume := 1.0 

func _ready():
	volume = ProjectSettings.get_setting("user_settings/volume", 1.0)
	apply_volume()

func apply_volume():
	var bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(volume))

func set_volume(new_volume: float):
	volume = new_volume
	apply_volume()
	ProjectSettings.set_setting("user_settings/volume", volume)
	ProjectSettings.save()
