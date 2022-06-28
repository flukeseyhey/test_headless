extends "res://src/ui/Screen.gd"

onready var _ui_layer = $UILayer

onready var username = $UILayer/Overlay/UserInfo/Username
onready var money = $UILayer/Overlay/UserInfo/Money
onready var multi_ui_button = $UILayer/Overlay/UIButton
onready var user_info = $UILayer/Overlay/UserInfo

onready var error_cover_message = $UILayer/Overlay/BgErrorMessage
onready var error_message = $UILayer/Overlay/BgErrorMessage/ErrorMessage
onready var cover = $UILayer/Overlay/Cover

onready var main_menu = $Screens/MainMenu
onready var online_mode = $Screens/OnlineMode
onready var adventure_mode = $Screens/AdventureMode
onready var adventure_select_mode = $Screens/AdventureMode/Mode
onready var adventure_select_level = $Screens/AdventureMode/DifficultyLevel
onready var adventure_bet_setup = $Screens/AdventureMode/BetSetup
onready var adventure_select_money = $Screens/AdventureMode/MoneyFrame
onready var adventure_selected_money = $Screens/AdventureMode/BetSetup/Money/Label

onready var money_bet = $Screens/AdventureMode/BetSetup/Money/Label

var on_setting = preload("res://assets/ui/tank-edit/tank-edit/tankui-edit-20.png")
var off_setting = preload("res://assets/ui/tank-edit/tank-edit/tankui-edit-20.png")
var on_back = preload("res://assets/ui/tank-edit/tank-edit/tankui-edit-21.png")
var off_back = preload("res://assets/ui/tank-edit/tank-edit/tankui-edit-21.png")
var on_home = preload("res://assets/ui/tank-edit/tank-edit/tankui-edit-24.png")
var off_home = preload("res://assets/ui/tank-edit/tank-edit/tankui-edit-24.png")

var current_scene
#var _is_info := false

enum Page {
	MAIN = 0,
	ADVENTURE_MODE = 1,
	ADVENTURE_DIFFICULTY_LEVEL = 2,
	ONLINE = 3,
	BET_SETUP = 4,
	SELECT_MONEY = 5,
}
var page: int = Page.MAIN setget _set_readonly_variable, get_page


func _ready() -> void:
	Music.play("Menu")
	_update_user()
#	multi_ui_button.is_visible_in_tree()

func _show_screen(info: Dictionary = {}) -> void:
#	online_button.focus.grab_without_sound()
#	ui_layer.hide_back_button()
	pass

func _update_user() -> void:
	username.text = str(DbSystem.username)
	money.text = str(DbSystem.money)

func _refresh_bet_money() -> void:
	adventure_selected_money.text = "1"

func show_error(text) -> void:
	error_message.text = text
	error_cover_message.visible = true
	cover.visible = true

func hide_error() -> void:
	error_cover_message.visible = false
	cover.visible = false

func show_page(bool_main_menu, bool_adventure, bool_adventure_select_mode, bool_adventure_select_level, bool_online, bool_adventure_bet_setup, bool_adventure_select_money) -> void:
	main_menu.visible = bool_main_menu
	adventure_mode.visible = bool_adventure
	adventure_select_mode.visible = bool_adventure_select_mode
	adventure_select_level.visible = bool_adventure_select_level
	online_mode.visible = bool_online
	adventure_bet_setup.visible = bool_adventure_bet_setup
	adventure_select_money.visible = bool_adventure_select_money
	

func _set_readonly_variable(_value) -> void:
	pass

func get_page() -> int:
	return page

# ====================================== MAIN MENU ======================================

func _on_AdventureButton_pressed() -> void:
	Sounds.play("Select")
	OnlineMatch._on_set_game_mode(OnlineMatch.GameMode.ADVENTURE)	
	# main_menu, adventure, adventure_select_mode, adventure_select_level, online, adventure_bet_setup, adventure_select_money
	show_page(false, true, true, false, false, false, false)
	multi_ui_button.set_texture(on_home)
	multi_ui_button.set_texture_pressed(off_home)
	page = Page.ADVENTURE_MODE

func _on_OnlineButton_pressed() -> void:
	Sounds.play("Select")
	# main_menu, adventure, adventure_select_mode, adventure_select_level, online, adventure_bet_setup, adventure_select_money
	show_page(false, false, false, false, true, false, false)
	multi_ui_button.set_texture(on_home)
	multi_ui_button.set_texture_pressed(off_home)
	page = Page.ONLINE

#func _on_PracticeButton_pressed():
#	Sounds.play("Select")
#	OnlineMatch._on_set_game_mode(OnlineMatch.GameMode.PRACTICE)
#	DbSystem.to_scene = "res://src/main/Practice.tscn"
#	current_scene = get_tree().change_scene("res://src/main/title/LoadingScreen.tscn")

# ====================================== END MAIN MENU ======================================

# ====================================== ADVENTURE MODE ======================================

func _on_LevelButton_pressed() -> void:
	Sounds.play("Select")
	AdventureMatch._on_set_adventure_mode(AdventureMatch.AdventureMode.LEVEL)
	# main_menu, adventure, adventure_select_mode, adventure_select_level, online, adventure_bet_setup, adventure_select_money
	show_page(false, true, false, true, false, false, false)
	multi_ui_button.set_texture(on_back)
	multi_ui_button.set_texture_pressed(off_back)
	page = Page.ADVENTURE_DIFFICULTY_LEVEL

func _on_EndlessButton_pressed() -> void:
	Sounds.play("Select")
	AdventureMatch._on_set_adventure_mode(AdventureMatch.AdventureMode.ENDLESS)
	# main_menu, adventure, adventure_select_mode, adventure_select_level, online, adventure_bet_setup, adventure_select_money
	show_page(false, true, false, false, false, true, false)
	multi_ui_button.set_texture(on_back)
	multi_ui_button.set_texture_pressed(off_back)

func _on_Easy_pressed() -> void:
	Sounds.play("Select")
	AdventureMatch._on_set_difficulty_level(AdventureMatch.DifficultyLevel.EASY)
	# main_menu, adventure, adventure_select_mode, adventure_select_level, online, adventure_bet_setup, adventure_select_money
	show_page(false, true, false, false, false, true, false)

func _on_Normal_pressed() -> void:
	Sounds.play("Select")
	AdventureMatch._on_set_difficulty_level(AdventureMatch.DifficultyLevel.NORMAL)
	# main_menu, adventure, adventure_select_mode, adventure_select_level, online, adventure_bet_setup, adventure_select_money
	show_page(false, true, false, false, false, true, false)

func _on_Hard_pressed() -> void:
	Sounds.play("Select")
	AdventureMatch._on_set_difficulty_level(AdventureMatch.DifficultyLevel.HARD)
	# main_menu, adventure, adventure_select_mode, adventure_select_level, online, adventure_bet_setup, adventure_select_money
	show_page(false, true, false, false, false, true, false)

# ====================================== END ADVENTURE MODE ======================================

# ====================================== ONLINE MODE ======================================

func _on_online_bet(room_type: float):
	DbSystem.CurrentRoomType = room_type
	
	if DbSystem.money >= room_type:
		OnlineMatch._on_set_game_mode(OnlineMatch.GameMode.ONLINE)
		
#		DbSystem.to_scene = "res://src/main/SessionSetup.tscn"
#		current_scene = get_tree().change_scene("res://src/main/title/LoadingScreen.tscn")
		current_scene = get_tree().change_scene("res://src/main/SessionSetup.tscn")
#
#		multi_ui_button.visible = false
#		var online_scene = DbSystem.OnlineScene.instance()
#		add_child(online_scene)
		
		
	else:
		show_error("ยอดเงินคงเหลือไม่เพียงพอ")
		yield(get_tree().create_timer(1.0), "timeout")
		hide_error()

func _on_5BathButton_pressed():
	Sounds.play("Select")
	_on_online_bet(5.0)

func _on_10BathButton_pressed():
	Sounds.play("Select")
	_on_online_bet(10.0)

func _on_20BathButton_pressed():
	Sounds.play("Select")
	_on_online_bet(20.0)

func _on_50BathButton_pressed():
	Sounds.play("Select")
	_on_online_bet(50.0)

func _on_100BathButton_pressed():
	Sounds.play("Select")
	_on_online_bet(100.0)

# ====================================== END ONLINE MODE ======================================

func _on_UIButton_released() -> void:
	Sounds.play("Back")
	
	
	if page == Page.MAIN:
		current_scene = get_tree().change_scene("res://src/ui/SettingsScreen.tscn")

	elif page == Page.ADVENTURE_MODE:
		# main_menu, adventure, adventure_select_mode, adventure_select_level, online, adventure_bet_setup, adventure_select_money
		show_page(true, false, false, false, false, false, false)
		multi_ui_button.set_texture(on_setting)
		multi_ui_button.set_texture_pressed(off_setting)
		page = Page.MAIN

	elif page == Page.ADVENTURE_DIFFICULTY_LEVEL:
		# main_menu, adventure, adventure_select_mode, adventure_select_level, online, adventure_bet_setup, adventure_select_money
		show_page(false, true, true, false, false, false, false)
		multi_ui_button.set_texture(on_back)
		multi_ui_button.set_texture_pressed(off_back)
		page = Page.ADVENTURE_MODE

	elif page == Page.BET_SETUP:
		# main_menu, adventure, adventure_select_mode, adventure_select_level, online, adventure_bet_setup, adventure_select_money
		show_page(true, false, true, false, false, false, false)
		multi_ui_button.set_texture(on_home)
		multi_ui_button.set_texture_pressed(off_home)
		page = Page.ADVENTURE_MODE
		_refresh_bet_money()

	elif page == Page.SELECT_MONEY:
		# main_menu, adventure, adventure_select_mode, adventure_select_level, online, adventure_bet_setup, adventure_select_money
		show_page(false, true, false, false, false, true, false)
		multi_ui_button.set_texture(on_back)
		multi_ui_button.set_texture_pressed(off_back)
		page = Page.BET_SETUP

	elif page == Page.ONLINE:
		# main_menu, adventure, adventure_select_mode, adventure_select_level, online, adventure_bet_setup, adventure_select_money
		show_page(true, false, false, false, false, false, false)
		multi_ui_button.set_texture(on_setting)
		multi_ui_button.set_texture_pressed(off_setting)
		page = Page.MAIN
		
	else:
#		current_scene = get_tree().change_scene("res://src/main/title/MenuScreen.tscn")
		
		var menu_scene = DbSystem.MenuScene.instancec()
		add_child(menu_scene)
		
		multi_ui_button.set_texture(on_setting)
		multi_ui_button.set_texture_pressed(off_setting)
		RachaAPI.check_agent_valid_loopback()
		page = Page.MAIN


func _on_StartButton_pressed():
	Music.stop()
	DbSystem.money_bet = int(money_bet.text)
	DbSystem.total_pay = DbSystem.money_bet
	DbSystem.total_online_bet(DbSystem.money_bet)
	DbSystem.game_is_playing = true
	
#	DbSystem.to_scene = "res://src/main/adventure/Main.tscn"
#	current_scene = get_tree().change_scene("res://src/main/title/LoadingScreen.tscn")

#	user_info.visible = false
#	$UILayer/Overlay/InfoButton.visible = false
#	multi_ui_button.visible = false
	
#	var adventure_scene = DbSystem.AdventureScene.instance()
#	add_child(adventure_scene)

	DbSystem.to_scene = "res://src/main/adventure/Main.tscn"
	current_scene = get_tree().change_scene("res://src/main/title/LoadingScreen.tscn")


func _on_SelectMoney_pressed():
	# main_menu, adventure, adventure_select_mode, adventure_select_level, online, adventure_bet_setup, adventure_select_money
	show_page(false, true, false, false, false, false, true)
	page = Page.SELECT_MONEY


func _on_MoneyFrame_select_money():
	# main_menu, adventure, adventure_select_mode, adventure_select_level, online, adventure_bet_setup, adventure_select_money
	show_page(false, true, false, false, false, true, false)
	page = Page.BET_SETUP


func _on_UILayer_info_button():
	if not DbSystem.game_is_playing:
		if not _ui_layer._is_info:
			user_info.visible = false
			$UILayer/Overlay/TextureRect.visible = false
			_ui_layer.show_screen('GameInfo')
		else:
			user_info.visible = true
			$UILayer/Overlay/TextureRect.visible = true
			_ui_layer.hide_screen()
