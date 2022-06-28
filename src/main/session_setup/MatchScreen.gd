extends "res://src/ui/Screen.gd"

var current_scene

func _ready() -> void:
	OnlineMatch.connect("matchmaker_matched", self, "_on_OnlineMatch_matchmaker_matched")
	OnlineMatch.connect("match_created", self, "_on_OnlineMatch_created")
	OnlineMatch.connect("match_joined", self, "_on_OnlineMatch_joined")

func _on_online_mode(mode) -> void:
	# If our session has expired, show the ConnectionScreen again.
	if Online.nakama_session == null or Online.nakama_session.is_expired():
#		ui_layer.show_screen("ConnectionScreen", { next_screen = null, reconnect = true })
#		current_scene = get_tree().change_scene("res://src/main/SessionSetup.tscn")
		RachaAPI._on_connect_nakama_server()
		
		# Wait to see if we get a new valid session.
		yield(Online, "session_changed")
		if Online.nakama_session == null:
			return
	
	# Connect socket to realtime Nakama API if not connected.
	if not Online.is_nakama_socket_connected():
		Online.connect_nakama_socket()
		yield(Online, "socket_connected")
	
	ui_layer.hide_message()
	
	# Call internal method to do actual work.
	match mode:
		OnlineMatch.MatchMode.MATCHMAKER:
			_start_matchmaking()
		OnlineMatch.MatchMode.CREATE:
			_create_match()
		OnlineMatch.MatchMode.JOIN:
			_join_match()

func _start_matchmaking() -> void:
	var min_players = OnlineMatch.min_players
	
	ui_layer.hide_screen()
	ui_layer.show_message("กำลังค้นหาห้อง...")
	
	var data = {
		min_count = min_players,
		string_properties = {
			game = "retro_tank_party1",
		},
		query = "+properties.game:retro_tank_party1",
	}
	
	OnlineMatch.start_matchmaking(Online.nakama_socket, data)

func _on_OnlineMatch_matchmaker_matched(_players: Dictionary):
	ui_layer.hide_message()
	ui_layer.show_screen("ReadyScreen", { players = _players })

func _create_match() -> void:
	OnlineMatch.create_match(Online.nakama_socket)

func _on_OnlineMatch_created(match_id: String):
	ui_layer.show_screen("ReadyScreen", { match_id = match_id, clear = true })

func _join_match():
# =================================================================
	OnlineMatch._on_FIND(int(DbSystem.CurrentRoomType))
	print("ผู้เล่นค้นหาห้อง: ", DbSystem.CurrentRoomType, " บาท")
# =================================================================
	
#	var match_id = join_match_id_control.text.strip_edges()
#	var match_id = DbSystem.CurrentMatch
#	if match_id == '':
#		ui_layer.show_message("Need to paste Match ID to join")
#		return
#	if not match_id.ends_with('.'):
#		match_id += '.'
#	OnlineMatch.join_match(Online.nakama_socket, match_id)

func _on_OnlineMatch_joined(match_id: String):
	ui_layer.show_screen("ReadyScreen", { match_id = match_id, clear = true })

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if get_focus_owner() is Button:
		return
	
	if event.is_action_pressed("ui_accept"):
		get_tree().set_input_as_handled()
