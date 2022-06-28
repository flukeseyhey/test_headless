extends "res://src/ui/Screen.gd"

#onready var return_button = $PanelContainer/MarginContainer/VBoxContainer/ReturnButton

signal exit_pressed ()

#func _show_screen(info: Dictionary = {}) -> void:
#	return_button.grab_focus()


func _on_ReturnButton_pressed():
	Sounds.play("Select")
	ui_layer.hide_screen()
	ui_layer.show_back_button()


func _on_SettingsButton_pressed():
	Sounds.play("Select")
	ui_layer.show_screen("SettingsScreen")


func _on_Exit_pressed():
	Sounds.play("Select")
	emit_signal("exit_pressed")
	ui_layer.hide_screen()
