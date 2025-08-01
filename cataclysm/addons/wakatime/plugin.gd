tool
extends EditorPlugin

var wakatime_tracker

func _enter_tree():
	print("WakaTime plugin activated ✅")
	wakatime_tracker = preload("res://addons/wakatime/wakatime.gd")
	add_child(wakatime_tracker)

func _exit_tree():
	if wakatime_tracker:
		wakatime_tracker.queue_free()
