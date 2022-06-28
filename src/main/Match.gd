extends Node2D

onready var game := $Game
onready var ui_layer := $UILayer

onready var mode_layer := $UILayer/Mode
onready var mode_cover := $UILayer/Overlay/Cover
onready var mode_description := $UILayer/ModeDescription
onready var error_cover_message := $UILayer/BgErrorMessage
onready var error_message := $UILayer/BgErrorMessage/ErrorMessage

var scene
var match_manager
var match_info: Dictionary


# -------------------------------------------------------------------------------------
const BATTLE_ROYALE = 'res://mods/core/modes/battle_royale/BattleRoyaleManager.tscn'
const DEATHMATCH = 'res://mods/core/modes/deathmatch/DeathmatchManager.tscn'
# -------------------------------------------------------------------------------------

func _ready() -> void:
	OnlineMatch.connect("error", self, "_on_OnlineMatch_error")
	OnlineMatch.connect("disconnected", self, "_on_OnlineMatch_disconnected")
	OnlineMatch.connect("player_left", self, "_on_OnlineMatch_player_left")
	
	randomize()
	
	var songs := ['Track1', 'Track2', 'Track3', 'Track4']
	Music.play(songs[randi() % songs.size()])


func show_mode(_title, _desc) -> void:
	mode_cover.visible = true
	mode_layer.visible = true
	mode_layer.text = _title
	mode_description.visible = true
	mode_description.text = _desc
	
func hide_mode() -> void:
	mode_cover.visible = false
	mode_layer.visible = false
	mode_description.visible = false

func scene_setup(operation: RemoteOperations.ClientOperation, info: Dictionary) -> void:
	# Store the match info for when we return to the match setup screen.
	match_info = info
	
	var match_mode = match_info.values()
	
	match_manager = load(info['manager_path']).instance()
	match_manager.name = "MatchManager"
	add_child(match_manager)
	match_manager.match_setup(info, self, game, ui_layer)
	
	if match_mode[0] == BATTLE_ROYALE:
		show_mode('BATTLE ROYALE', 'ผู้เล่นคนสุดท้ายที่รอดชีวิตคือผู้ชนะ')
	elif match_mode[0] == DEATHMATCH:
		show_mode('DEATHMATCH', 'ผู้เล่นที่ได้คะแนนเยอะสุดเป็นผู้ชนะ')
	else:
		hide_mode()
	
	ui_layer.show_back_button()
	operation.mark_done()
	yield(get_tree().create_timer(2.0), "timeout")
	hide_mode()

func scene_start() -> void:
	match_manager.match_start()

# END MATCH
func finish_match() -> void:
	if get_tree().is_network_server():
		match_manager.match_stop()
		# @todo pass current config so we start from the same settings
#		RemoteOperations.change_scene("res://src/main/MatchSetup.tscn", match_info)
		ui_layer.hide_back_button()
		game.visible = false
		OnlineMatch.leave()
		DbSystem.game_is_playing = false
		DbSystem.game_is_end = true

# END MATCH EXEPT PLAYER NOT ENOUGH
func quit_match() -> void:
	ui_layer.hide_back_button()
	game.visible = false
	OnlineMatch.leave()
	DbSystem.game_is_playing = false
	DbSystem.game_is_end = true

func _on_Game_game_error(message) -> void:
	_on_OnlineMatch_error(message)

func _on_Game_game_started() -> void:
	ui_layer.hide_screen()
	ui_layer.hide_all()
	ui_layer.show_back_button()

func _on_UILayer_back_button() -> void:
	if ui_layer.current_screen_name in ['', 'SettingsScreen']:
		ui_layer.show_screen('MenuScreen')
	else:
		ui_layer.hide_screen()

func _on_MenuScreen_exit_pressed() -> void:
	var alert_content: String
	
	alert_content = 'ระบบจะไม่คืนเครดิตและคุณจะไม่สามารถกลับเข้าห้องได้อีก'
	
	ui_layer.show_alert('คุณต้องการที่จะออกจากเกม?', alert_content)
	var result: bool = yield(ui_layer, "alert_completed")
	if result:
		if get_tree().is_network_server():
			finish_match()
			DbSystem.CurrentResultMatch = JSON.print({
				"result": "quit match"
			})
			OnlineMatch._on_END("host left")
#			yield(get_tree().create_timer(0.5), "timeout")
			DbSystem.game_is_playing = false
			DbSystem.game_is_end = true
		else:
			quit_match()
#			yield(get_tree().create_timer(0.5), "timeout")
			DbSystem.game_is_playing = false
			DbSystem.game_is_end = true
		
		scene = get_tree().change_scene("res://src/main/title/MenuScreen.tscn")
		

#func _unhandled_input(event: InputEvent) -> void:
#	# Trigger debugging action!
#	if event.is_action_pressed("special_debug"):
#		print (" ** DEBUG ** FORCING WEBRTC CONNECTIONS TO CLOSE **")
#		# Close all our peers to force a reconnect (to make sure it works).
#		for session_id in OnlineMatch._webrtc_peers:
#			var webrtc_peer = OnlineMatch._webrtc_peers[session_id]
#			webrtc_peer.close()

#####
# OnlineMatch callbacks
#####

func _on_OnlineMatch_error(message: String):
	if message != '':
		mode_cover.visible = true
		error_cover_message.visible = true
		error_message.text = message + " ระบบจะคืนเงินให้ผู้เล่นทั้งหมด"
		
	ui_layer.hide_screen()
	
	yield(get_tree().create_timer(2.0), "timeout")
	
	mode_cover.visible = false
	error_cover_message.visible = false
	
	quit_match()
	DbSystem.stop_sent_credit = false
	DbSystem.total_offline_bet("END", DbSystem.CurrentRoomType)
	DbSystem.stop_sent_credit = true
	
#	DbSystem.to_scene = "res://src/main/title/MenuScreen.tscn"
	Music.stop()
	scene = get_tree().change_scene("res://src/main/title/MenuScreen.tscn")
#	get_tree().change_scene("res://src/main/title/LoadingScreen.tscn")
	

func _on_OnlineMatch_disconnected():
	#_on_OnlineMatch_error("Disconnected from host")
	_on_OnlineMatch_error('')

# Removes player from their team (if teams are enabled) and returns false if 
# the team still no longer has enough players; otherwise it returns true.
func _remove_from_team(peer_id) -> bool:
	if match_info['config'].get('teams', false):
		var teams = match_info['teams']
		for team in teams:
			if peer_id in team:
				team.erase(peer_id)
				if team.size() == 0:
					return false
	return true

func _on_OnlineMatch_player_left(player) -> void:
	# Call deferred so we can still access the player on the players array
	# in all the other signal handlers.
	game.call_deferred("remove_player", player.peer_id)
	
	if not _remove_from_team(player.peer_id) or OnlineMatch.players.size() < 2:
		_on_OnlineMatch_error(player.username + " ออกจากห้อง ผู้เล่นไม่เพียงพอ ระบบจะคืนเงินให้กลับท่าน!")
	else:
		ui_layer.show_message(player.username + " ออกจากห้อง")
