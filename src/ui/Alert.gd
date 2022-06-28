extends PanelContainer

onready var title_label := $MarginContainer/VBoxContainer/TitleLabel
onready var content_label := $MarginContainer/VBoxContainer/ContentLabel
onready var ok_button := $MarginContainer/VBoxContainer/HBoxContainer/Sprite/OkButton
onready var cancel_button := $MarginContainer/VBoxContainer/HBoxContainer/Sprite2/CancelButton

var current_scene

signal completed (result)

func setup(title: String, content: String, ok_text: String = 'ตกลง', cancel_text: String = 'ยกเลิก') -> void:
	title_label.text = title
	content_label.text = content
	ok_button.text = ok_text
	ok_button.focus.grab_without_sound()
	if cancel_text != '':
		cancel_button.text = cancel_text
		cancel_button.visible = true
	else:
		cancel_button.visible = false

func _on_OkButton_pressed():
	emit_signal("completed", true)
#	current_scene = get_tree().change_scene("res://src/main/title/LoadingScreen.tscn")

func _on_CancelButton_pressed():
	emit_signal("completed", false)
