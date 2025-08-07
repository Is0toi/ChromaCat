extends HSlider

func _ready():
	value = VolumeManager.volume 

func _on_value_changed(value: float) -> void:
	VolumeManager.set_volume(value)
