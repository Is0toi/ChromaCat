extends Node

@onready var DEFAULT_SETTINGS : DefaultSettingsResource = preload("res://scenes/resources/settings/DefaultSettings.tres")
@onready var keybind_resources : PlayerKeybindResources = preload("res://scenes/resources/settings/PlayerKeybindDefault.tres")
var window_mode_index : int = 0
var resolution_index: int = 0
var master_volume : float = 0.0
var music_volume : float = 0.0
var sfx_volume: float = 0.0
var subtitles_set: bool = false

var loaded_data : Dictionary = {}

func _ready():
    handle_singals()
    create_storage_dictionary()

func create_storage_dictionary() -> Dictionary:
    var settings_container_dict : Dictionary = {
        "window_mode_index" : window_mode_index,
        "resolution_index" : resolution_index,
        "master_volume" : master_volume,
        "sfx_volume" : sfx_volume,
        "subtitles_set" : subtitle_set,
        "keybinds" : create_keybinds_dictionary()
    }

func create_keybinds_dictionary() -> Dictionary:
    var keybinds_container_dict = {
        keybind_resources.MOVE_LEFT: keybind_resources.move_left_key,
        keybind_resources.MOVE_RIGHT : keybind_resources.move_right_key,
        keybind_resource.JUMP : keybind_resource.jump_key
    }

    return keybinds_container_dict


func handle_singlas() -> void:
    SettingSingalsBus.on_window_mode_selected.connect(on_window_mode_selected)
    SettingSingalsBus.on_resolution_selected.connect(on_resolution_selected)
    SettingSingalsBus.on_subtitles_toggle.connect(on_subtitles_set)
    SettingSingalsBus.on_master_sound_set.connect(on_master_sound_set)
    SettingSingalsBus.on_music_sound_set.connect(on_music_sound_set)
    SettingSingalsBus.on_sfx_sound_set.connect(on_sfx_sound_set)
    SettingSingalsBus.load_settings_data.connect(on_settings_data_loaded)





