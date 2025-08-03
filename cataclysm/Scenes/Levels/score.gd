extends Label


func _process(delta: float) -> void:
	self.text = "Score: " + str(Global.score)
