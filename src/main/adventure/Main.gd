extends Node2D

const Player = preload("res://src/main/adventure/actors/Player.tscn")
#var TankScene = preload("res://src/objects/Tank.tscn")


onready var enemy_ai = $EnemyMapAI
onready var bullet_manager = $BulletManager
onready var camera = $Camera2D
onready var gui = $GUI
onready var ground = $Ground
onready var pathfinding = $Pathfinding

onready var ui_layer := $UILayer
#onready var info_button = $UILayer/Overlay/InfoButton
#onready var back_button = $UILayer/Overlay/BackButton

onready var start_match_label = $UILayer/Overlay/Message
onready var start_match_timer = $StartMatchTime
onready var end_match_label = $GUI/EndMatch
onready var end_match_timer = $EndMatchTimer

onready var animation = $GUI/AnimationPlayer

var player

var match_start_time = 0
var match_end_time = 0
var kill_count = 0

var scene
var _map_rect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	randomize()
	GlobalSignals.connect("bullet_fired", bullet_manager, "handle_bullet_spawned")
	GlobalSignals.connect("unit_death", self, "handle_player_win")

#	var enemy_respawns = $EnemyRespawnPoints
	set_description_match()

#	pathfinding.create_navigation_map(ground)
	set_spawn_point_enemy()
	
#	enemy_ai.initialize(enemy_respawns.get_children(), pathfinding)
	spawn_player()
	
#	$UILayer/Overlay/BackButton.visible = true
	$UILayer.show_back_button()
	
	DbSystem.game_is_end = false 
	DbSystem.stop_sent_credit = false
	
	var songs := ['Track1', 'Track2', 'Track3', 'Track4']
	Music.play(songs[randi() % songs.size()])
	
	DbSystem.map_rect = get_map_rect()

func spawn_player():
	player = Player.instance()
	add_child(player)
	player.position.x = rand_range(900, 1100)
	player.position.y = rand_range(900, 1100)
	player.set_camera_transform(camera.get_path())
	player.connect("died", self, "handle_player_lost")
	gui.set_player(player)

func set_spawn_point_enemy():
	var enemy_respawns
	
	if AdventureMatch.adventure_mode == AdventureMatch.AdventureMode.LEVEL:
		match AdventureMatch.difficulty_level:
			AdventureMatch.DifficultyLevel.EASY:
				enemy_respawns = $EasyRespawnPoints
			AdventureMatch.DifficultyLevel.NORMAL:
				enemy_respawns = $NormalRespawnPoints
			AdventureMatch.DifficultyLevel.HARD:
				enemy_respawns = $HardRespawnPoints
	else:
		enemy_respawns = $EndlessRespawnPoints
	
	pathfinding.create_navigation_map(ground)
	enemy_ai.initialize(enemy_respawns.get_children(), pathfinding)

func get_map_rect() -> Rect2:
	if _map_rect != null:
		return _map_rect
	
	if not has_node("Ground"):
		_map_rect = Rect2()
		return _map_rect
	
	var tilemap = $Ground
	
	_map_rect = tilemap.get_used_rect()
	if _map_rect.size.x > 0 and _map_rect.size.y > 0:
		# Leave a margin of 1 tile all the waay around the map to account for camera
		# shake, so remove those from the rect.
		_map_rect.position += Vector2(1.0, 1.0)
		_map_rect.size -= Vector2(2.0, 2.0)
	
	# Convert tile space to pixel space
	_map_rect.position = (_map_rect.position * tilemap.cell_size) + tilemap.global_position
	_map_rect.size *= tilemap.cell_size
	
	return _map_rect


func play_animation(animation_name):
	animation.play(animation_name)
#	animation.emit_signal("animation_finished")
#	animation.stop()


func set_description_match() -> void:
#	var match_mode
	var kill_count
	var match_timer
	
	start_match_label.visible = true
	
	if AdventureMatch.adventure_mode == AdventureMatch.AdventureMode.LEVEL:
		match AdventureMatch.difficulty_level:
			AdventureMatch.DifficultyLevel.EASY:
#				match_mode = "โหมดง่าย"
				kill_count = DbSystem.easy_mode_kill_count
				match_timer = DbSystem.easy_match_timer
			AdventureMatch.DifficultyLevel.NORMAL:
#				match_mode = "โหมดปกติ"
				kill_count = DbSystem.normal_mode_kill_count
				match_timer = DbSystem.normal_match_timer
			AdventureMatch.DifficultyLevel.HARD:
#				match_mode = "โหมดยาก"
				kill_count = DbSystem.hard_mode_kill_count
				match_timer = DbSystem.hard_match_timer

		start_match_label.text = "กำจัดรถถัง " + str(kill_count) + " คัน ภายในเวลา " + str(match_timer) + " วินาที"
		yield(get_tree().create_timer(2.0), "timeout")
		start_match_label.visible = false
		start_match_countdown(match_timer)
		
	else:
		start_match_label.text = "กำจัดรถถังฝ่ายศัตรูไปเรื่อย ๆ"
		yield(get_tree().create_timer(2.0), "timeout")
		start_match_label.visible = false


func game_end() -> void:
	start_match_timer.stop()
	start_match_label.visible = false
#	info_button.visible = false
#	back_button.visible = false
	player.hide_user_info()
	player.hide_ui_no_joy()
#	GlobalSignals.emit_signal("adventure_end")
	end_match_countdown(5)
	DbSystem.game_is_end = true


func handle_player_win():
	kill_count += 1
	
	if AdventureMatch.adventure_mode == AdventureMatch.AdventureMode.LEVEL:
		match AdventureMatch.difficulty_level:
			AdventureMatch.DifficultyLevel.EASY:
				if kill_count == DbSystem.easy_mode_kill_count:
					AdventureMatch._on_set_win_loss(AdventureMatch.WinLoss.WIN)
					game_end()
			AdventureMatch.DifficultyLevel.NORMAL:
				if kill_count == DbSystem.normal_mode_kill_count:
					AdventureMatch._on_set_win_loss(AdventureMatch.WinLoss.WIN)
					game_end()
			AdventureMatch.DifficultyLevel.HARD:
				if kill_count == DbSystem.hard_mode_kill_count:
					AdventureMatch._on_set_win_loss(AdventureMatch.WinLoss.WIN)
					game_end()


func handle_player_lost():
	if AdventureMatch.adventure_mode == AdventureMatch.AdventureMode.LEVEL:
		AdventureMatch._on_set_win_loss(AdventureMatch.WinLoss.LOSS)
	else:
		AdventureMatch._on_set_win_loss(AdventureMatch.WinLoss.WIN)
	game_end()


func player_win():
	Music.stop()
#	player.hide_user_info()
	var game_over = DbSystem.GameOverScreen.instance()
	add_child(game_over)
	game_over.set_title(true)
	
	if AdventureMatch.adventure_mode == AdventureMatch.AdventureMode.LEVEL:
		game_over.set_message(DbSystem.money_bet, DbSystem.money_gain)
		
		DbSystem.total_money_gain = DbSystem.money_gain
#		DbSystem.total_money_gain = (DbSystem.money_bet) + DbSystem.money_gain
		DbSystem.game_is_end = true
		DbSystem.stop_sent_credit = false
		DbSystem.total_offline_bet("END", (DbSystem.money_bet + DbSystem.total_money_gain))
		DbSystem.stop_sent_credit = true
		
		if RachaAPI.is_show_debug:
			print(DbSystem.username, " ได้เงินรวม : ", "%.2f" % DbSystem.total_money_gain, " บาท")
	else:
		game_over.set_endless_message(DbSystem.money_gain)
		
		DbSystem.total_money_gain = (DbSystem.money_gain)
		DbSystem.game_is_end = true
		DbSystem.stop_sent_credit = false
		DbSystem.total_offline_bet("END", DbSystem.total_money_gain)
		DbSystem.stop_sent_credit = true
		
		if RachaAPI.is_show_debug:
			print(DbSystem.username, " ได้เงินรวม : ", "%.2f" % DbSystem.total_money_gain, " บาท")
	
	DbSystem.reset_game_to_default()


func player_lost():
	Music.stop()
	var game_over = DbSystem.GameOverScreen.instance()
	add_child(game_over)
	game_over.set_title(false)
	game_over.set_lose_message("พยายามได้ดี โอกาสหน้าลองใหม่อีกครั้ง")


#---------------------------------------------------------------------------

func start_match_countdown(seconds: int):
	if seconds <= 0:
		return
	match_start_time = seconds + OS.get_system_time_secs()
	start_match_timer.start()
	update_start_match_label()
	start_match_label.visible = true


func update_start_match_label():
	var seconds_remaining: int = match_start_time - OS.get_system_time_secs()
	_update_remote_start_match_label(seconds_remaining)


func _update_remote_start_match_label(seconds_remaining: int) -> void:
	if seconds_remaining < 0:
		start_match_label.visible = false
		animation.emit_signal("animation_finished")
		animation.stop()
		stop_start_match_countdown()
	elif seconds_remaining > 0 and seconds_remaining < 6:
		animation.play("tween")
		
	else:
		start_match_label.visible = true

	var minutes = seconds_remaining / 60
	var seconds = seconds_remaining % 60

	start_match_label.text = str(minutes) + ":" + str(seconds).pad_zeros(2)
	


func stop_start_match_countdown():
	AdventureMatch._on_set_win_loss(AdventureMatch.WinLoss.LOSS)
	start_match_timer.stop()
	DbSystem.game_is_playing = false
	DbSystem.game_is_end = true
#	get_tree().paused = true
#	back_button.visible = false
	ui_layer.show_cover()
	play_animation("fade")

#---------------------------------------------------------------------------

func end_match_countdown(seconds: int):
	if seconds <= 0:
		return
	match_end_time = seconds + OS.get_system_time_secs()
	end_match_timer.start()
	update_end_match_label()
	end_match_label.visible = true


func update_end_match_label():
	var seconds_remaining: int = match_end_time - OS.get_system_time_secs()
	_update_remote_end_match_label(seconds_remaining)


func _update_remote_end_match_label(seconds_remaining: int) -> void:
	if seconds_remaining < 1:
		end_match_label.visible = false
		stop_end_match_countdown()
	else:
		end_match_label.visible = true
	
	var seconds = seconds_remaining % 60
	end_match_label.text = "เกมจะจบใน " + str(seconds) + " วินาที"


func stop_end_match_countdown():
#	back_button.visible = false
	end_match_timer.stop()
#	get_tree().paused = true
	ui_layer.show_cover()
	play_animation("fade")

#--------------------------------------------------------------------------



#func _unhandled_input(event: InputEvent) -> void:
#	if event.is_action_pressed("pause"):
#		if ui_layer.current_screen_name in ['', 'SettingsScreen']:
#			ui_layer.show_screen('MenuScreen')
#			get_tree().paused = true
#		else:
#			ui_layer.hide_screen()
#			get_tree().paused = false


func _on_UILayer_back_button():
#	if ui_layer.current_screen_name in ['', 'SettingsScreen']:
	ui_layer.show_screen('MenuScreen')
	ui_layer.hide_back_button()
#		get_tree().paused = true
#		start_match_timer.paused = true
#	else:
#		ui_layer.hide_screen()
#		get_tree().paused = false
#		start_match_timer.paused = false


func _on_MenuScreen_exit_pressed():
	var alert_content: String

	alert_content = 'เกมจะจบลงและไม่คืนเงินที่ท่านใช้เล่น'

	ui_layer.show_alert('คุณต้องการที่จะออกจากเกม?', alert_content)
	var result: bool = yield(ui_layer, "alert_completed")
	
	if result:
		DbSystem.game_is_playing = false
		DbSystem.game_is_end = true
		
#		DbSystem.to_scene = "res://src/main/title/MenuScreen.tscn"
#		scene = get_tree().change_scene("res://src/main/title/LoadingScreen.tscn")
		scene = get_tree().change_scene("res://src/main/title/MenuScreen.tscn")
		
	else:
		DbSystem.game_is_playing = true
		DbSystem.game_is_end = false
		
		ui_layer.hide_screen()


func _on_StartMatchTime_timeout():
	update_start_match_label()


func _on_EndMatchTimer_timeout():
	update_end_match_label()


func _on_AnimationPlayer_animation_finished(anim_name):
	if AdventureMatch.win_loss == AdventureMatch.WinLoss.LOSS:
		player_lost()
	else:
		player_win()
