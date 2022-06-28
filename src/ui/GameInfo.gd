extends "res://src/ui/Screen.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _show_screen(info: Dictionary = {}) -> void:
	ui_layer._is_info = true

func _hide_screen() -> void:
	ui_layer._is_info = false
