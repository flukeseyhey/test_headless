extends Control

onready var ui_layer := $UILayer
var current_scene


func _ready():
	_set_game_sound_enable_on_load()

func _on_StartButton_pressed() -> void:
	Sounds.play("Select")
	Music.stop()
	
	if not RachaAPI.is_test_demo:
		if !OS.window_fullscreen:
			OS.window_fullscreen = !OS.window_fullscreen
	
	current_scene = get_tree().change_scene("res://src/main/title/LoadingScreen.tscn")

func _set_game_sound_enable_on_load() -> void:
	yield(get_tree().root, "ready")
	Music.play("Title")
	GameSettings.sound_volume = 0.5
	GameSettings.music_volume = 0.5
	
	ui_layer.show_info_button()
	ui_layer.show_sound_on_button()


func _on_UILayer_info_button():
	if not ui_layer._is_info:
		ui_layer.show_screen('GameInfo')
	else:
		ui_layer.hide_screen()
