extends "res://src/ui/Screen.gd"

onready var field_container := $Panel/VBoxContainer/GridContainer
onready var music_slider := $Panel/VBoxContainer/GridContainer/BgMusicSlider/MusicSlider
onready var sound_slider := $Panel/VBoxContainer/GridContainer/BgSoundSlider/SoundSlider
onready var screenshake_field := $Panel/VBoxContainer/GridContainer/BgScreenshakeOptions/ScreenshakeOptions

var _is_ready := false
var current_scene

func _ready() -> void:
	music_slider.value = GameSettings.music_volume
	sound_slider.value = GameSettings.sound_volume
	
	screenshake_field.add_item("ปิด", false)
	screenshake_field.add_item("เปิด", true)
	screenshake_field.set_value(GameSettings.use_screenshake, false)
	
	_setup_field_neighbors()
	
	_is_ready = true

func _setup_field_neighbors() -> void:
	var previous_neighbor = null;
	for child in field_container.get_children():
		if previous_neighbor:
			previous_neighbor.focus_neighbour_bottom = child.get_path()
			previous_neighbor.focus_next = child.get_path()
			child.focus_neighbour_top = previous_neighbor.get_path()
			child.focus_previous = previous_neighbor.get_path()
		previous_neighbor = child

func _show_screen(info: Dictionary = {}) -> void:
	music_slider.focus.grab_without_sound()
	ui_layer.show_back_button()

func _hide_screen() -> void:
	GameSettings.save_settings()

func _on_MusicSlider_value_changed(value: float) -> void:
	if _is_ready:
		Sounds.play("Select")
	GameSettings.music_volume = value

func _on_SoundSlider_value_changed(value: float) -> void:
	if _is_ready:
		Sounds.play("Select")
	GameSettings.sound_volume = value

func _on_ScreenshakeOptions_item_selected(value, _index) -> void:
	GameSettings.use_screenshake = value

func _on_DoneButton_pressed() -> void:
	if DbSystem.game_is_playing:
		ui_layer.go_back()
	else:
		current_scene = get_tree().change_scene("res://src/main/title/MenuScreen.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed('ui_accept'):
		get_tree().set_input_as_handled()
		_on_DoneButton_pressed()

