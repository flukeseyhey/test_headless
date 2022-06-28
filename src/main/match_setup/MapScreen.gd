extends "res://src/ui/Screen.gd"

onready var map_field = $Panel/VBoxContainer/MapSwitcher
onready var next_button = $Panel/VBoxContainer/NextButton

const DEFAULT_MAP = "res://mods/core/maps/Small/abandoned.tres"
# ----------------------------------------------------------------------
const SMALL_MAP_1 = "res://mods/core/maps/Small/abandoned.tres"
const SMALL_MAP_2 = "res://mods/core/maps/Small/Camp.tres"
const SMALL_MAP_3 = "res://mods/core/maps/Small/eyip.tres"
const SMALL_MAP_4 = "res://mods/core/maps/Small/GreenMap.tres"
const SMALL_MAP_5 = "res://mods/core/maps/Small/Ice.tres"
const SMALL_MAP_6 = "res://mods/core/maps/Small/lava.tres"
const SMALL_MAP_7 = "res://mods/core/maps/Small/Magic.tres"
const SMALL_MAP_8 = "res://mods/core/maps/Small/Old Tonw.tres"
const SMALL_MAP_9 = "res://mods/core/maps/Small/Toxic.tres"
# ----------------------------------------------------------------------
const MEDIUM_MAP_1 = "res://mods/core/maps/Medium/Abandoned.tres"
const MEDIUM_MAP_2 = "res://mods/core/maps/Medium/Camp.tres"
const MEDIUM_MAP_3 = "res://mods/core/maps/Medium/eyip.tres"
const MEDIUM_MAP_4 = "res://mods/core/maps/Medium/GreenMap.tres"
const MEDIUM_MAP_5 = "res://mods/core/maps/Medium/Ice.tres"
const MEDIUM_MAP_6 = "res://mods/core/maps/Medium/lava.tres"
const MEDIUM_MAP_7 = "res://mods/core/maps/Medium/Magic.tres"
const MEDIUM_MAP_8 = "res://mods/core/maps/Medium/Old Tonw.tres"
const MEDIUM_MAP_9 = "res://mods/core/maps/Medium/Toxic.tres"
# ----------------------------------------------------------------------
const LARGE_MAP_1 = "res://mods/core/maps/Large/Abandoned.tres"
const LARGE_MAP_2 = "res://mods/core/maps/Large/Camp.tres"
const LARGE_MAP_3 = "res://mods/core/maps/Large/eyip.tres"
const LARGE_MAP_4 = "res://mods/core/maps/Large/GreenMap.tres"
const LARGE_MAP_5 = "res://mods/core/maps/Large/Ice.tres"
const LARGE_MAP_6 = "res://mods/core/maps/Large/Lava.tres"
const LARGE_MAP_7 = "res://mods/core/maps/Large/Magic.tres"
const LARGE_MAP_8 = "res://mods/core/maps/Large/Old Tonw.tres"
const LARGE_MAP_9 = "res://mods/core/maps/Large/Toxic.tres"
# ----------------------------------------------------------------------

var maps := {}

signal map_changed (map_scene_path)

func _ready() -> void:
	randomize()
# ----------------------------------------------------------------------
	_load_maps()
	for map_id in maps:
		map_field.add_item(maps[map_id].name, map_id)
	
	map_field.set_value(SMALL_MAP_1, false)

	match DbSystem.test_map:
		false:
			if OnlineMatch.players.size() >= 7 && OnlineMatch.players.size() <= 10:
				var large_maps := [LARGE_MAP_1, LARGE_MAP_2, LARGE_MAP_3, LARGE_MAP_4, LARGE_MAP_5, LARGE_MAP_6, LARGE_MAP_7, LARGE_MAP_8, LARGE_MAP_9 ]
				var random_map_large = large_maps[randi() % large_maps.size()]
				map_field.set_value(random_map_large, false)
				print(random_map_large)
			elif OnlineMatch.players.size() >= 4 && OnlineMatch.players.size() <= 6:
				var medium_maps := [MEDIUM_MAP_1, MEDIUM_MAP_2, MEDIUM_MAP_3, MEDIUM_MAP_4, MEDIUM_MAP_5, MEDIUM_MAP_6, MEDIUM_MAP_7, MEDIUM_MAP_8, MEDIUM_MAP_9]
				var random_map_medium = medium_maps[randi() % medium_maps.size()]
				map_field.set_value(random_map_medium, false)
				print(random_map_medium)
			else:
				var small_maps := [SMALL_MAP_1, SMALL_MAP_2, SMALL_MAP_3, SMALL_MAP_4, SMALL_MAP_5, SMALL_MAP_6, SMALL_MAP_7, SMALL_MAP_8, SMALL_MAP_9]
				var random_map_small = small_maps[randi() % small_maps.size()]
				map_field.set_value(random_map_small, false)
				print(random_map_small)
		true:
			map_field.set_value(SMALL_MAP_1, false)


# ----------------------------------------------------------------------
func _show_screen(info: Dictionary = {}) -> void:
	var mode_screen = ui_layer.get_screen("ModeScreen")
	if mode_screen:
		_update_map_field_for_mode(mode_screen.get_mode())
	
	change_map(maps[map_field.value])
	map_field.focus.grab_without_sound()

func _load_maps() -> void:
	for file_path in Modding.find_resources('maps/Large'):
		var resource = load(file_path)
		if resource is GameMap:
			maps[file_path] = resource
			
	for file_path in Modding.find_resources('maps/Medium'):
		var resource = load(file_path)
		if resource is GameMap:
			maps[file_path] = resource
			
	for file_path in Modding.find_resources('maps/Small'):
		var resource = load(file_path)
		if resource is GameMap:
			maps[file_path] = resource

func _update_map_field_for_mode(mode: MatchMode) -> void:
	var old_value = map_field.value
		
	map_field.clear_items()
	for map_id in maps:
		if mode.requires_goals:
			if maps[map_id].has_goals:
				map_field.add_item(maps[map_id].name, map_id)
		else:
			if not maps[map_id].has_goals:
				map_field.add_item(maps[map_id].name, map_id)
	
	if not map_field.set_value(old_value, false):
		if not map_field.set_value(DEFAULT_MAP, false):
			map_field.set_selected(0, false)

func change_map(map: GameMap) -> void:
	emit_signal("map_changed", map.map_scene)

func disable_screen() -> void:
	map_field.disabled = true

func _on_MapSwitcher_item_selected(value, index) -> void:
	change_map(maps[value])
	send_remote_update()

func _on_NextButton_pressed() -> void:
	ui_layer.show_screen("ReadyScreen")

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed('ui_accept'):
		get_tree().set_input_as_handled()
		_on_NextButton_pressed()

func _on_config_changed() -> void:
	send_remote_update()

func send_remote_update() -> void:
	if is_network_master():
		rpc("_remote_update", map_field.value)

puppet func _remote_update(map_id: String) -> void:
	map_field.value = map_id
	change_map(maps[map_id])

func get_map() -> GameMap:
	return maps[map_field.value]

func get_map_scene_path() -> String:
	return get_map().map_scene

func set_map_scene_path(map_scene: String) -> void:
	var map: GameMap
	for resource_path in maps:
		map = maps[resource_path]
		if map.map_scene == map_scene:
			map_field.value = resource_path
			break
