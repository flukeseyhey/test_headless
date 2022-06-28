extends Node2D
#--------------------------------------------
#extends "res://src/main/Match.gd"
#--------------------------------------------

onready var ui_layer: UILayer = $UILayer
onready var match_screen = $UILayer/Screens/MatchScreen
onready var ready_screen = $UILayer/Screens/ReadyScreen
onready var message_label = $UILayer/Overlay/Message

var players_ready := {}
var players_session := {}

var current_scene

func _ready() -> void:
	# Make extra sure that we aren't in an existing match when this scene starts.
	OnlineMatch.leave()
	OnlineMatch.connect("error", self, "_on_OnlineMatch_error")
	OnlineMatch.connect("disconnected", self, "_on_OnlineMatch_disconnected")
	OnlineMatch.connect("player_status_changed", self, "_on_OnlineMatch_player_status_changed")
	OnlineMatch.connect("player_left", self, "_on_OnlineMatch_player_left")
	
	ui_layer.show_back_button()
	
	Music.play("Menu")
	# ---------------------------------
#	match_screen._on_online_mode(OnlineMatch.MatchMode.MATCHMAKER)
	match_screen._on_online_mode(OnlineMatch.MatchMode.JOIN)
	# ---------------------------------
	
#####
# UI callbacks
#####

func _on_UILayer_back_button() -> void:
	ui_layer.hide_message()
	
	if ui_layer.current_screen_name == 'ReadyScreen':
		var alert_content: String
	
		if get_tree().is_network_server():
			alert_content = 'จะทำให้ห้องปิดลงและจะทำให้\nผู้เล่นอื่นออกจากห้องด้วย'
		else:
			alert_content = 'คุณจะออกจากห้องและหากต้องการเข้าเล่นใหม่ให้กดที่ห้องเดิม'
		
		ui_layer.show_alert('คุณแน่ใจที่จะออกเกม?', alert_content)
		var result: bool = yield(ui_layer, "alert_completed")
		
		if not result:
			return
			
		if get_tree().is_network_server():
			var i = 1
			for session_id in OnlineMatch.players:
				players_session['"' + str(i) + '"'] = '"' + str(session_id) + '"'
				i += 1
			
			DbSystem.CurrentPlayerSession = players_session
			
			DbSystem.CurrentResultMatch = JSON.print({
				"result": "quit match"
			})
			
			OnlineMatch._on_END("host left")
		else:
			OnlineMatch._on_END("left")

#	OnlineMatch._on_LEFT(DbSystem.CurrentMatch)
	OnlineMatch.leave()
	
#	DbSystem.to_scene = "res://src/main/title/MenuScreen.tscn"
	current_scene = get_tree().change_scene("res://src/main/title/MenuScreen.tscn")
	
#	var loading_scene = load("res://src/main/title/LoadingScreen.tscn").instance()
#	add_child(loading_scene)
	
#	if ui_layer.current_screen_name in ['ConnectionScreen', 'MatchScreen']:
#		get_tree().change_scene("res://src/main/Title.tscn")
#	else:
#		get_tree().change_scene("res://src/main/Title.tscn")
#		ui_layer.show_screen("MatchScreen")


#func _check_players_ready() -> bool:
#	for session_id in OnlineMatch.players:
#		if not players_ready.has(session_id):
#			return false
#	return true

#func _on_ReadyScreen_ready_pressed() -> void:
#	Sounds.play("Select")
#	rpc("player_ready", OnlineMatch.get_my_session_id())

#remotesync func player_ready(session_id: String) -> void:
#	ready_screen.set_status(session_id, "READY!")
#	if get_tree().is_network_server() and not players_ready.has(session_id):
#		players_ready[session_id] = true
#		_start_match_if_all_ready()
#		OnlineMatch._on_START(DbSystem.CurrentMatch)

func _on_ReadyScreen_room_auto_start():
	rpc("room_auto_start", OnlineMatch.get_my_session_id())

remotesync func room_auto_start(session_id: String) -> void:
	ready_screen.set_status(session_id, "READY!")
	if get_tree().is_network_server() and not players_ready.has(session_id):
		players_ready[session_id] = true
		_start_match_if_timeout()
		OnlineMatch._on_START(DbSystem.CurrentMatch)

#func _start_match_if_all_ready() -> void:
#	if _check_players_ready():
#		if OnlineMatch.match_state != OnlineMatch.MatchState.PLAYING:
#			OnlineMatch.start_playing()
#		RemoteOperations.change_scene("res://src/main/MatchSetup.tscn")
		
func _start_match_if_timeout() -> void:
	Music.stop()
#	if _check_players_ready():
	if OnlineMatch.match_state != OnlineMatch.MatchState.PLAYING:
		OnlineMatch.start_playing()
	RemoteOperations.change_scene("res://src/main/MatchSetup.tscn")
#####
# OnlineMatch callbacks
#####

#================================================================================

func _on_GET_SESSION():
	var data = get_node("/root/RachaAPI/str2json").GET_GETSESSION(DbSystem.CurrentMatch)
	data = get_node("/root/RachaAPI/AES").call("Encrypt", data, DbSystem.appid)
	data = get_node("/root/RachaAPI/str2json").call("LastStep", data)
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, "_com_GET_SESSION")
	var error = http_request.request(DbSystem.go_server_host + "/MTGETSESSION", [], true, HTTPClient.METHOD_POST, data)
	if error != OK:
		 push_error("An error occurred in the HTTP request.")
	
func _com_GET_SESSION(result, response_code, headers, body):
	var response = body.get_string_from_utf8()
	var data = body.get_string_from_utf8()
	
	data = get_node("/root/RachaAPI/AES").call("Decrypt", data.percent_decode(), "Rachapasswodgood")
	data = parse_json(data)
	
	var session = data['player_session']
	session = parse_json(session)

	print("find session state : ", data["state"])
	
	if data['state'] == "found":
		if DbSystem.CurrentMySessionID == session["2"]:
			_on_OnlineMatch_host_left(0.5)
		else:
			_on_OnlineMatch_host_left(1.5)
	else:
		OnlineMatch.leave()
		get_tree().change_scene("res://src/main/title/MenuScreen.tscn")

#================================================================================

func _on_OnlineMatch_host_left(time):
	ui_layer.show_cover()
	ui_layer.show_message("กำลังย้ายห้องใหม่")
	ready_screen.visible = false
	yield(get_tree().create_timer(time), "timeout")
	ui_layer.hide_cover()
	DbSystem.to_scene = "res://src/main/SessionSetup.tscn"
	get_tree().change_scene("res://src/main/title/LoadingScreen.tscn")

func _on_OnlineMatch_error(message: String):
	if message != '':
		message_label.text = message
#		ui_layer.show_message(message)
#	ui_layer.hide_screen()
	
#	yield(get_tree().create_timer(1.0), "timeout")
	get_tree().change_scene("res://src/main/title/MenuScreen.tscn")
	
func _on_OnlineMatch_disconnected():
	#_on_OnlineMatch_error("Disconnected from host")
	_on_OnlineMatch_error('')
#	yield(get_tree().create_timer(1.0), "timeout")+
	_on_GET_SESSION()

func _on_OnlineMatch_player_left(player) -> void:
	ui_layer.show_message(player.username + " has left")
	players_ready.erase(player.session_id)
	
	# It's possible that all players marked ready except for the one who left,
	# so check if all are ready, and if so, start the match.
#	call_deferred("_start_match_if_all_ready")

func _on_OnlineMatch_player_status_changed(player, status) -> void:
	if status == OnlineMatch.PlayerStatus.CONNECTED:
		if get_tree().is_network_server():
			# Tell this new player about all the other players that are already ready.
			for session_id in players_ready:
				rpc_id(player.peer_id, "player_ready", session_id)

