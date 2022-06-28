extends CanvasLayer
class_name UILayer

export var _info_button: NodePath
export var _setting_button: NodePath
export var _sound_on_button: NodePath
export var _sound_off_button: NodePath
export var _home_button: NodePath
export var _back_button: NodePath


onready var info_button := get_node(_info_button)
onready var setting_button := get_node(_setting_button)
onready var sound_on_button := get_node(_sound_on_button)
onready var sound_off_button := get_node(_sound_off_button)
onready var home_button := get_node(_home_button)
onready var back_button := get_node(_back_button)


onready var screens = $Screens
#onready var game_info = $Screens/GameInfo
onready var cover = $Overlay/Cover
onready var message_label = $Overlay/Message
#onready var back_button = $Overlay/BackButton
#onready var info_button = $Overlay/InfoButton
onready var alert = $Overlay/Alert
#onready var error_message_label = $Overlay/ErrorMessage


signal change_screen (name, screen, info)
signal back_button ()
signal alert_completed (result)
signal info_button ()

var current_screen: Control = null setget _set_readonly_variable
var current_screen_name: String = '' setget _set_readonly_variable, get_current_screen_name

var _is_ready := false
var _is_info := false
var _button_state = true

func _set_readonly_variable(_value) -> void:
	pass

func _ready() -> void:
	for screen in screens.get_children():
		_setup_screen(screen)
	
	_is_ready = true
func add_screen(screen) -> void:
	screens.add_child(screen)
	_setup_screen(screen)

func _setup_screen(screen) -> void:
	screen.visible = false
	if screen.has_method('_setup_screen'):
		screen._setup_screen(self)

func get_screens():
	return screens.get_children()

func get_screen(name: String):
	if screens.has_node(name):
		return screens.get_node(name)
	return null

func get_current_screen_name() -> String:
	if current_screen:
		return current_screen.name
	return ''

remote func show_screen(name: String, info: Dictionary = {}) -> void:
	var screen = screens.get_node(name)
	if not screen:
		return
	
	hide_screen()
	screen.visible = true
	if screen.has_method("_show_screen"):
		screen.callv("_show_screen", [info])
	current_screen = screen
	
	if _is_ready:
		emit_signal("change_screen", name, screen, info)

func hide_screen() -> void:
	if current_screen and current_screen.has_method('_hide_screen'):
		current_screen._hide_screen()
	
	for screen in screens.get_children():
		screen.visible = false
	current_screen = null

func show_message(text: String) -> void:
	message_label.text = text
	message_label.visible = true

func hide_message() -> void:
	message_label.visible = false

func show_cover() -> void:
	cover.visible = true

func hide_cover() -> void:
	cover.visible = false

func show_back_button() -> void:
	back_button.visible = true

func hide_back_button() -> void:
	back_button.visible = false

#func show_game_info() -> void:
#	game_info.visible = true
#
#func hide_game_info() -> void:
#	game_info.visible = false

func show_info_button() -> void:
	info_button.visible = true

func hide_info_button() -> void:
	info_button.visible = false

func show_setting_button() -> void:
	setting_button.visible = true

func hide_setting_button() -> void:
	setting_button.visible = false

func show_sound_on_button() -> void:
	sound_on_button.visible = true

func hide_sound_on_button() -> void:
	sound_on_button.visible = false

func show_sound_off_button() -> void:
	sound_off_button.visible = true

func hide_sound_off_button() -> void:
	sound_off_button.visible = false

func show_home_button() -> void:
	home_button.visible = true

func hide_home_button() -> void:
	home_button.visible = false



func show_alert(title: String, content: String, ok_text: String = 'ตกลง', cancel_text: String = 'ยกเลิก') -> void:
	alert.setup(title, content, ok_text, cancel_text)
	alert.visible = true
	show_cover()
	show_back_button()

func hide_alert(result: bool = false) -> void:
	alert.visible = false
	get_tree().paused = false
	hide_cover()
	emit_signal("alert_completed", result)

func _on_Alert_completed(result) -> void:
	hide_alert(result)

func hide_all() -> void:
	hide_screen()
	hide_cover()
	hide_message()
	hide_back_button()

func go_back() -> void:
	if alert.visible:
		hide_alert()
	
	else:
		emit_signal("back_button")

func _on_BackButton_pressed() -> void:
	go_back()
#	emit_signal("back_button")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action('ui_cancel') and back_button.visible and event.is_pressed():
		Sounds.play("Back")
		get_tree().set_input_as_handled()
		go_back()


func _on_SoundButton_pressed():
	Sounds.play("Select")
	
	if _button_state:
		GameSettings.sound_volume = 0
		GameSettings.music_volume = 0
		GameSettings.save_settings()
		_button_state = false
		hide_sound_on_button()
		show_sound_off_button()
		
	else:
		GameSettings.sound_volume = 1.0
		GameSettings.music_volume = 1.0
		GameSettings.save_settings()
		_button_state = true
		hide_sound_off_button()
		show_sound_on_button()


func _on_SettingButton_pressed():
	hide_info_button()
	hide_setting_button()
	hide_sound_on_button()
	hide_sound_off_button()
	show_screen('SettingsScreen')



func _on_InfoButton_pressed():
	emit_signal("info_button")
