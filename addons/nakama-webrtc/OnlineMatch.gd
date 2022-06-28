extends Node

# For developers to set from the outside, for example:
#   OnlineMatch.max_players = 8
#   OnlineMatch.client_version = 'v1.2'
#   OnlineMatch.ice_servers = [ ... ]
#   OnlineMatch.use_network_relay = OnlineMatch.NetworkRelay.FORCED
var min_players := 2
var max_players := 10
var client_version := 'dev'
var ice_servers = [{ "urls": ["stun:stun.l.google.com:19302"] }]

var current_scene

# Declare a variable to store which presence is the host
var host_presence : NakamaRTAPI.UserPresence
var current_match

enum NetworkRelay {
	AUTO,
	FORCED,
	DISABLED
}
var use_network_relay: int = NetworkRelay.AUTO

# Nakama variables:
var nakama_socket: NakamaSocket setget _set_readonly_variable
var my_session_id: String setget _set_readonly_variable, get_my_session_id
var match_id: String setget _set_readonly_variable, get_match_id
var matchmaker_ticket: String setget _set_readonly_variable, get_matchmaker_ticket

# WebRTC variables:
var _webrtc_multiplayer: WebRTCMultiplayer
var _webrtc_peers: Dictionary
var _webrtc_peers_connected: Dictionary

var players: Dictionary
var _next_peer_id: int

enum GameMode {
	NONE = 0,
	ADVENTURE = 1,
	ONLINE = 2,
}
var game_mode: int = GameMode.NONE setget _set_readonly_variable, get_game_mode

enum MatchState {
	LOBBY = 0,
	MATCHING = 1,
	CONNECTING = 2,
	WAITING_FOR_ENOUGH_PLAYERS = 3,
	READY = 4,
	PLAYING = 5,
}
var match_state: int = MatchState.LOBBY setget _set_readonly_variable, get_match_state

enum MatchMode {
	NONE = 0,
	CREATE = 1,
	JOIN = 2,
	MATCHMAKER = 3,
}
var match_mode: int = MatchMode.NONE setget _set_readonly_variable, get_match_mode

enum PlayerStatus {
	CONNECTING = 0,
	CONNECTED = 1,
}

enum MatchOpCode {
	WEBRTC_PEER_METHOD = 9001,
	JOIN_SUCCESS = 9002,
	JOIN_ERROR = 9003,
}

signal error (message)
signal disconnected ()

signal match_created (match_id)
signal match_joined (match_id)
signal matchmaker_matched (players)

signal player_joined (player)
signal player_left (player)
signal player_status_changed (player, status)


signal start_match_countdown(seconds)
signal stop_match_countdown()

signal match_ready (players)
signal match_not_ready ()

class Player:
	var session_id: String
	var peer_id: int
	var username: String
	
	func _init(_session_id: String, _username: String, _peer_id: int) -> void:
		session_id = _session_id
		username = _username
		peer_id = _peer_id
	
	static func from_presence(presence: NakamaRTAPI.UserPresence, _peer_id: int) -> Player:
		return Player.new(presence.session_id, presence.username, _peer_id)
	
	static func from_dict(data: Dictionary) -> Player:
		return Player.new(data['session_id'], data['username'], int(data['peer_id']))
	
	func to_dict() -> Dictionary:
		return {
			session_id = session_id,
			username = username,
			peer_id = peer_id,
		}

static func serialize_players(_players: Dictionary) -> Dictionary:
	var result := {}
	for key in _players:
		result[key] = _players[key].to_dict()
	return result

static func unserialize_players(_players: Dictionary) -> Dictionary:
	var result := {}
	for key in _players:
		result[key] = Player.from_dict(_players[key])
	return result

func _set_readonly_variable(_value) -> void:
	pass

func _set_nakama_socket(_nakama_socket: NakamaSocket) -> void:
	if nakama_socket == _nakama_socket:
		return
	
	if nakama_socket:
		nakama_socket.disconnect("closed", self, "_on_nakama_closed")
		nakama_socket.disconnect("received_error", self, "_on_nakama_error")
		nakama_socket.disconnect("received_match_state", self, "_on_nakama_match_state")
		nakama_socket.disconnect("received_match_presence", self, "_on_nakama_match_presence")
		nakama_socket.disconnect("received_matchmaker_matched", self, "_on_nakama_matchmaker_matched")
	
	nakama_socket = _nakama_socket
	if nakama_socket:
		nakama_socket.connect("closed", self, "_on_nakama_closed")
		nakama_socket.connect("received_error", self, "_on_nakama_error")
		nakama_socket.connect("received_match_state", self, "_on_nakama_match_state")
		nakama_socket.connect("received_match_presence", self, "_on_nakama_match_presence")
		nakama_socket.connect("received_matchmaker_matched", self, "_on_nakama_matchmaker_matched")

func _on_set_game_mode(_mode):
	game_mode = _mode


# Define comparer functions
func _presence_comparer(a : NakamaRTAPI.UserPresence, b : NakamaRTAPI.UserPresence):
	return a.session_id < b.session_id

func _user_comparer(a : NakamaRTAPI.MatchmakerUser, b : NakamaRTAPI.MatchmakerUser):
	return a.presence.session_id < b.presence.session_id

# Upon receiving a matchmaker matched event, deterministically calculate the host by sorting the session Ids
func _on_matchmaker_matched(matchmaker_matched : NakamaRTAPI.MatchmakerMatched):
	matchmaker_matched.users.sort_custom(self, "_user_comparer")
	host_presence = matchmaker_matched.users[0].presence
	current_match = yield(nakama_socket.join_match_async(matchmaker_matched.match_id), "completed")
#	current_match = yield(socket.join_match_async(matchmaker_matched.match_id), "completed")
	
	print("host_presence : ", host_presence)
	print("current_match : ", current_match)

# When receiving a match presence event, check if the host left and if so recalculate the host presence
func _on_match_presence(match_presence_event : NakamaRTAPI.MatchPresenceEvent):
	for presence in match_presence_event.leaves:
		if presence.session_id == host_presence.session_id:
			current_match.presences.sort_custom(self, "_presence_comparer")
			if len(current_match.presences) < 1:
				host_presence = current_match.self_user
			else:
				host_presence = current_match.presences[0]

# =================================================================================================================
func _on_CREATE(datax: NakamaRTAPI.Match, roomtype, rmin, rmax):
	var data = get_node("/root/RachaAPI/str2json").GET_CREATEMATCH('tank_battle', datax.match_id, roomtype, rmin, rmax)
	data = get_node("/root/RachaAPI/AES").call("Encrypt", data, DbSystem.appid)
	data = get_node("/root/RachaAPI/str2json").call("LastStep", data)
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, "_com_CREATE")
	var error = http_request.request(DbSystem.go_server_host + "/MTCREATE", [], true, HTTPClient.METHOD_POST, data)
	if error != OK:
		 push_error("An error occurred in the HTTP request.")
	
func _com_CREATE(result, response_code, headers, body):
	var response = body.get_string_from_utf8()
	var data = body.get_string_from_utf8()
	data = get_node("/root/RachaAPI/AES").call("Decrypt", data.percent_decode(), "Rachapasswodgood")
	data = parse_json(data)
	if RachaAPI.is_show_debug:
		print("create state : ", data["state"])

func _on_FIND(type: int):
	var data = get_node("/root/RachaAPI/str2json").GET_FINDMATCH('tank_battle', type)
	data = get_node("/root/RachaAPI/AES").call("Encrypt", data, DbSystem.appid)
	data = get_node("/root/RachaAPI/str2json").call("LastStep", data)
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, "_com_FIND")
	var error = http_request.request(DbSystem.go_server_host + "/MTFINDMATCH", [], true, HTTPClient.METHOD_POST, data)
	if error != OK:
		 push_error("An error occurred in the HTTP request.")
	
func _com_FIND(result, response_code, headers, body):
	var response = body.get_string_from_utf8()
	var data = body.get_string_from_utf8()
	
	data = get_node("/root/RachaAPI/AES").call("Decrypt", data.percent_decode(), "Rachapasswodgood")
	data = parse_json(data)
	if RachaAPI.is_show_debug:
		print("find golang match state : ", data["state"])
	
	if data["roomid"] != "":
		DbSystem.CurrentMatch = data["roomid"]
		join_match(Online.nakama_socket, DbSystem.CurrentMatch)
	else:
		create_match(Online.nakama_socket)

# =================================================================================================================

func _on_RES_FIND(roomid: String):
	var data = get_node("/root/RachaAPI/str2json").GET_TKEND("quit", roomid, DbSystem.CurrentResultMatch, "")
	data = get_node("/root/RachaAPI/AES").call("Encrypt", data, DbSystem.appid)
	data = get_node("/root/RachaAPI/str2json").call("LastStep", data)
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	var error = http_request.request(DbSystem.go_server_host + "/MTRESFINDMATCH", [], true, HTTPClient.METHOD_POST, data)
	if error != OK:
		 push_error("An error occurred in the HTTP request.")

# =================================================================================================================

func _on_END(cmd):
	var data = get_node("/root/RachaAPI/str2json").GET_TKEND(cmd, DbSystem.CurrentMatch, DbSystem.CurrentResultMatch, DbSystem.CurrentPlayerSession)
	data = get_node("/root/RachaAPI/AES").call("Encrypt", data, DbSystem.appid)
	data = get_node("/root/RachaAPI/str2json").call("LastStep", data)
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, "_com_END")
	var error = http_request.request(DbSystem.go_server_host + "/MTEND", [], true, HTTPClient.METHOD_POST, data)
	if error != OK:
		print("An error occurred in the HTTP request.")
	
func _com_END(result, response_code, headers, body):
	var response = body.get_string_from_utf8()
	var data = body.get_string_from_utf8()
	data = get_node("/root/RachaAPI/AES").call("Decrypt", data.percent_decode(), "Rachapasswodgood")
	data = parse_json(data)
	if RachaAPI.is_show_debug:
		print("end state : ", data["state"])
	
# =================================================================================================================

func _on_START(roomid: String):
	var data = get_node("/root/RachaAPI/str2json").GET_TKSTART(roomid)
	data = get_node("/root/RachaAPI/AES").call("Encrypt", data, DbSystem.appid)
	data = get_node("/root/RachaAPI/str2json").call("LastStep", data)
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, "_com_START")
	var error = http_request.request(DbSystem.go_server_host + "/MTSTART", [], true, HTTPClient.METHOD_POST, data)
	if error != OK:
		 push_error("An error occurred in the HTTP request.")

func _com_START(result, response_code, headers, body):
	var response = body.get_string_from_utf8()
	var data = body.get_string_from_utf8()
	data = get_node("/root/RachaAPI/AES").call("Decrypt", data.percent_decode(), "Rachapasswodgood")
	data = parse_json(data)
	if RachaAPI.is_show_debug:
		print("start state : ", data["state"])
	DbSystem.golang_start_match = data["state"]

# =================================================================================================================

func create_match(_nakama_socket: NakamaSocket) -> void:
	leave()
	_set_nakama_socket(_nakama_socket)
	match_mode = MatchMode.CREATE
	
	var create_data = yield(nakama_socket.create_match_async(), "completed")
	
	if create_data.is_exception():
		leave()
		emit_signal("error", "Failed to create match: " + str(create_data.get_exception().message))
		if RachaAPI.is_show_debug:
			print("create match failed")
	else:
		if RachaAPI.is_show_debug:
			print("create match success")
		_on_nakama_match_created(create_data)
		_on_CREATE(create_data, DbSystem.CurrentRoomType, min_players, max_players)

func join_match(_nakama_socket: NakamaSocket, _match_id: String) -> void:
	leave()
	_set_nakama_socket(_nakama_socket)
	match_mode = MatchMode.JOIN
	
	var join_data = yield(nakama_socket.join_match_async(_match_id), "completed")
#	print (join_data)
	
	if join_data.is_exception():
		leave()
		emit_signal("error", "ไม่สามารถเข้าห้องได้")
		DbSystem.CurrentResultMatch = JSON.print({
			"result": "join error"
		})
		if RachaAPI.is_show_debug:
			print("join state : joining error, creating new room")
#		yield(get_tree().create_timer(1.0),"timeout")
		_on_RES_FIND(_match_id)
		yield(get_tree().create_timer(2.0),"timeout")
		
		DbSystem.to_scene = "res://src/main/SessionSetup.tscn"
		
#		var loading_scene = DbSystem.SessionScene.instance()
#		add_child(loading_scene)
		
#		current_scene = get_tree().change_scene("res://src/main/title/LoadingScreen.tscn")
		current_scene = get_tree().change_scene("res://src/main/SessionSetup.tscn")
	else:
		_on_nakama_match_join(join_data)

func start_matchmaking(_nakama_socket: NakamaSocket, data: Dictionary = {}) -> void:
	leave()
	_set_nakama_socket(_nakama_socket)
	match_mode = MatchMode.MATCHMAKER
	
	if data.has('min_count'):
		data['min_count'] = max(min_players, data['min_count'])
	else:
		data['min_count'] = min_players
	
	if data.has('max_count'):
		data['max_count'] = min(max_players, data['max_count'])
	else:
		data['max_count'] = max_players
	
	if client_version != '':
		if not data.has('string_properties'):
			data['string_properties'] = {}
		data['string_properties']['client_version'] = client_version
		
		var query = '+properties.client_version:' + client_version
		if data.has('query'):
			data['query'] += ' ' + query
		else:
			data['query'] = query
	
	match_state = MatchState.MATCHING
	var result = yield(nakama_socket.add_matchmaker_async(data.get('query', '*'), data['min_count'], data['max_count'], data.get('string_properties', {}), data.get('numeric_properties', {})), 'completed')
	if result.is_exception():
		leave()
		emit_signal("error", "ห้องทั้งหมดที่มี ไม่สามารถเข้าร่วมได้")
	else:
		matchmaker_ticket = result.ticket

func start_playing() -> void:
	assert(match_state == MatchState.READY)
	match_state = MatchState.PLAYING

func leave(close_socket: bool = false) -> void:
	# WebRTC disconnect.
	if _webrtc_multiplayer:
		_webrtc_multiplayer.close()
		get_tree().set_network_peer(null)
	
	# Nakama disconnect.
	if nakama_socket:
		if match_id:
			yield(nakama_socket.leave_match_async(match_id), 'completed')
		elif matchmaker_ticket:
			yield(nakama_socket.remove_matchmaker_async(matchmaker_ticket), 'completed')
		if close_socket:
			nakama_socket.close()
			_set_nakama_socket(null)
	
	# Initialize all the variables to their default state.
	my_session_id = ''
	match_id = ''
	matchmaker_ticket = ''
	_create_webrtc_multiplayer()
	_webrtc_peers = {}
	_webrtc_peers_connected = {}
	players = {}
	_next_peer_id = 1
	match_state = MatchState.LOBBY
	match_mode = MatchMode.NONE
	

func _create_webrtc_multiplayer() -> void:
	if _webrtc_multiplayer:
		_webrtc_multiplayer.disconnect("peer_connected", self, "_on_webrtc_peer_connected")
		_webrtc_multiplayer.disconnect("peer_disconnected", self, "_on_webrtc_peer_disconnected")
	
	_webrtc_multiplayer = WebRTCMultiplayer.new()
	_webrtc_multiplayer.connect("peer_connected", self, "_on_webrtc_peer_connected")
	_webrtc_multiplayer.connect("peer_disconnected", self, "_on_webrtc_peer_disconnected")

func get_my_session_id() -> String:
	return my_session_id

func get_match_id() -> String:
	return match_id

func get_matchmaker_ticket() -> String:
	return matchmaker_ticket



func get_game_mode() -> int:
	return game_mode

func get_match_mode() -> int:
	return match_mode



func get_match_state() -> int:
	return match_state

func get_session_id(peer_id: int):
	for session_id in players:
		if players[session_id]['peer_id'] == peer_id:
			return session_id
	return null

func get_player_by_peer_id(peer_id: int):
	var session_id = get_session_id(peer_id)
	if session_id:
		return players[session_id]
	return null

func get_players_by_peer_id() -> Dictionary:
	var result := {}
	for player in players.values():
		result[player.peer_id] = player
	return result

func get_player_names_by_peer_id() -> Dictionary:
	var result := {}
	for session_id in players:
		result[players[session_id]['peer_id']] = players[session_id]['username']
	return result

func _on_nakama_error(data) -> void:
	if RachaAPI.is_show_debug:
		print ("ERROR:")
		print(data)
	leave()
	emit_signal("error", "Websocket connection error")

func _on_nakama_closed() -> void:
	leave()
	emit_signal("disconnected")

 ############################################# เลขห้อง #######################################

func _on_nakama_match_created(data: NakamaRTAPI.Match) -> void:
	match_id = data.match_id
	DbSystem.CurrentMatch = data.match_id
	my_session_id = data.self_user.session_id
	var my_player = Player.from_presence(data.self_user, 1)
	players[my_session_id] = my_player
	_next_peer_id = 2
	
	_webrtc_multiplayer.initialize(1)
	get_tree().set_network_peer(_webrtc_multiplayer)
	
	emit_signal("match_created", match_id)
	emit_signal("player_joined", my_player)
	emit_signal("player_status_changed", my_player, PlayerStatus.CONNECTED)

func _on_nakama_match_presence(data: NakamaRTAPI.MatchPresenceEvent) -> void:
	for u in data.joins:
		if u.session_id == my_session_id:
			continue
		
		if match_mode == MatchMode.CREATE:
			if match_state == MatchState.PLAYING:
				# Tell this player that we've already started
				nakama_socket.send_match_state_async(match_id, MatchOpCode.JOIN_ERROR, JSON.print({
					target = u['session_id'],
					reason = 'Sorry! The match has already begun.',
				}))
			
			if players.size() < max_players:
				var new_player = Player.from_presence(u, _next_peer_id)
				_next_peer_id += 1
				players[u.session_id] = new_player
				emit_signal("player_joined", new_player)
				
				# Tell this player (and the others) about all the players peer ids.
				nakama_socket.send_match_state_async(match_id, MatchOpCode.JOIN_SUCCESS, JSON.print({
					players = serialize_players(players),
					client_version = client_version,
				}))
				
				_webrtc_connect_peer(new_player)
			else:
				# Tell this player that we're full up!
				nakama_socket.send_match_state_async(match_id, MatchOpCode.JOIN_ERROR, JSON.print({
					target = u['session_id'],
					reason = 'Sorry! The match is full.,',
				}))
		elif match_mode == MatchMode.MATCHMAKER:
			emit_signal("player_joined", players[u.session_id])
			_webrtc_connect_peer(players[u.session_id])
	
	for u in data.leaves:
		if u.session_id == my_session_id:
			continue
		if not players.has(u.session_id):
			continue
		
		var player = players[u.session_id]
		_webrtc_disconnect_peer(player)
		
		# If the host disconnects, this is the end!
		if player.peer_id == 1:
			DbSystem.CurrentMySessionID = get_my_session_id()
			leave()
			emit_signal("error", "ห้องนี้ถูกปิดโดยเข้าของห้อง")
			
		else:
			players.erase(u.session_id)
			emit_signal("player_left", player)
			
			if players.size() < min_players:
				# If state was previously ready, but this brings us below the minimum players,
				# then we aren't ready anymore.
				if match_state == MatchState.READY:
					match_state = MatchState.WAITING_FOR_ENOUGH_PLAYERS
					emit_signal("match_not_ready")
					
				emit_signal("stop_match_countdown")
			else:
				# If the remaining players are all fully connected, then set 
				# the match state to ready.
				if _webrtc_peers_connected.size() == players.size() - 1:
					match_state = MatchState.READY;
					emit_signal("match_ready", players)

func _on_nakama_match_join(data: NakamaRTAPI.Match) -> void:
	match_id = data.match_id
	my_session_id = data.self_user.session_id
	if match_mode == MatchMode.JOIN:
		emit_signal("match_joined", match_id)
	elif match_mode == MatchMode.MATCHMAKER:
		for u in data.presences:
			if u.session_id == my_session_id:
					continue
			_webrtc_connect_peer(players[u.session_id])

func _on_nakama_matchmaker_matched(data: NakamaRTAPI.MatchmakerMatched) -> void:
	if data.is_exception():
		leave()
		emit_signal("error", "Matchmaker error")
		return
	
	my_session_id = data.self_user.presence.session_id
	
	# Use the list of users to assign peer ids.
	for u in data.users:
		players[u.presence.session_id] = Player.from_presence(u.presence, 0)
	var session_ids = players.keys();
	session_ids.sort()
	for session_id in session_ids:
		players[session_id].peer_id = _next_peer_id
		_next_peer_id += 1
	
	# Initialize multiplayer using our peer id
	_webrtc_multiplayer.initialize(players[my_session_id].peer_id)
	get_tree().set_network_peer(_webrtc_multiplayer)
	
	emit_signal("matchmaker_matched", players)
	emit_signal("player_status_changed", players[my_session_id], PlayerStatus.CONNECTED)
	
	# Join the match.
	var result = yield(nakama_socket.join_matched_async(data), "completed")
	if result.is_exception():
		leave()
		emit_signal("error", "ไม่สามารถเข้าห้องได้")
	else:
		_on_nakama_match_join(result)

func _on_nakama_match_state(data: NakamaRTAPI.MatchData) -> void:
	var json_result = JSON.parse(data.data)
	if json_result.error != OK:
		return
		
	var content = json_result.result
	if data.op_code == MatchOpCode.WEBRTC_PEER_METHOD:
		if content['target'] == my_session_id:
			var session_id = data.presence.session_id
			if not _webrtc_peers.has(session_id):
				return
			var webrtc_peer = _webrtc_peers[session_id]
			match content['method']:
				'set_remote_description':
					webrtc_peer.set_remote_description(content['type'], content['sdp'])
				
				'add_ice_candidate':
					if _webrtc_check_ice_candidate(content['name']):
						#print ("Receiving ice candidate: %s" % content['name'])
						webrtc_peer.add_ice_candidate(content['media'], content['index'], content['name'])
				
				'reconnect':
					_webrtc_multiplayer.remove_peer(players[session_id]['peer_id'])
					_webrtc_reconnect_peer(players[session_id])
	if data.op_code == MatchOpCode.JOIN_SUCCESS && match_mode == MatchMode.JOIN:
		var host_client_version = content.get('client_version', '')
		if client_version != host_client_version:
			leave()
			emit_signal("error", "Client version doesn't match host")
			return
		
		var content_players = unserialize_players(content['players'])
		for session_id in content_players:
			if not players.has(session_id):
				players[session_id] = content_players[session_id]
				_webrtc_connect_peer(players[session_id])
				emit_signal("player_joined", players[session_id])
				if session_id == my_session_id:
					_webrtc_multiplayer.initialize(players[session_id].peer_id)
					get_tree().set_network_peer(_webrtc_multiplayer)
					
					emit_signal("player_status_changed", players[session_id], PlayerStatus.CONNECTED)
	if data.op_code == MatchOpCode.JOIN_ERROR:
		if content['target'] == my_session_id:
			leave()
			emit_signal("error", content['reason'])
			return

func _webrtc_connect_peer(player: Player) -> void:
	# Don't add the same peer twice!
	if _webrtc_peers.has(player.session_id):
		return
	
	# If the match was previously ready, then we need to switch back to not ready.
	if match_state == MatchState.READY:
		emit_signal("match_not_ready")
	
	# If we're already PLAYING, then this is a reconnect attempt, so don't mess with the state.
	# Otherwise, change state to CONNECTING because we're trying to connect to all peers.
	if match_state != MatchState.PLAYING:
		match_state = MatchState.CONNECTING
	
	var webrtc_peer := WebRTCPeerConnection.new()
	webrtc_peer.initialize({
		"iceServers": ice_servers,
	})
	webrtc_peer.connect("session_description_created", self, "_on_webrtc_peer_session_description_created", [player.session_id])
	webrtc_peer.connect("ice_candidate_created", self, "_on_webrtc_peer_ice_candidate_created", [player.session_id])
	
	_webrtc_peers[player.session_id] = webrtc_peer
	
	#get_tree().multiplayer._del_peer(u['peer_id'])
	_webrtc_multiplayer.add_peer(webrtc_peer, player.peer_id)
	
	if my_session_id.casecmp_to(player.session_id) < 0:
		var result = webrtc_peer.create_offer()
		if result != OK:
			emit_signal("error", "Unable to create WebRTC offer")

func _webrtc_disconnect_peer(player: Player) -> void:
	var webrtc_peer = _webrtc_peers[player.session_id]
	webrtc_peer.close()
	_webrtc_peers.erase(player.session_id)
	_webrtc_peers_connected.erase(player.session_id)

func _webrtc_reconnect_peer(player: Player) -> void:
	var old_webrtc_peer = _webrtc_peers[player.session_id]
	if old_webrtc_peer:
		old_webrtc_peer.close()
	
	_webrtc_peers_connected.erase(player.session_id)
	_webrtc_peers.erase(player.session_id)
	
	if RachaAPI.is_show_debug:
		print ("Starting WebRTC reconnect...")
	
	_webrtc_connect_peer(player)
	
	emit_signal("player_status_changed", player, PlayerStatus.CONNECTING)
	
	if match_state == MatchState.READY:
		match_state = MatchState.CONNECTING
		emit_signal("match_not_ready")

func _webrtc_check_ice_candidate(name: String) -> bool:
	if use_network_relay == NetworkRelay.AUTO:
		return true
	
	var is_relay: bool = "typ relay" in name
	
	if use_network_relay == NetworkRelay.FORCED:
		return is_relay
	return !is_relay

func _on_webrtc_peer_session_description_created(type: String, sdp: String, session_id: String) -> void:
	var webrtc_peer = _webrtc_peers[session_id]
	webrtc_peer.set_local_description(type, sdp)
	
	# Send this data to the peer so they can call call .set_remote_description().
	nakama_socket.send_match_state_async(match_id, MatchOpCode.WEBRTC_PEER_METHOD, JSON.print({
		method = "set_remote_description",
		target = session_id,
		type = type,
		sdp = sdp,
	}))

func _on_webrtc_peer_ice_candidate_created(media: String, index: int, name: String, session_id: String) -> void:
	if not _webrtc_check_ice_candidate(name):
		return
	
	#print ("Sending ice candidate: %s" % name)
	
	# Send this data to the peer so they can call .add_ice_candidate()
	nakama_socket.send_match_state_async(match_id, MatchOpCode.WEBRTC_PEER_METHOD, JSON.print({
		method = "add_ice_candidate",
		target = session_id,
		media = media,
		index = index,
		name = name,
	}))

func _on_webrtc_peer_connected(peer_id: int) -> void:
	for session_id in players:
		if players[session_id]['peer_id'] == peer_id:
			_webrtc_peers_connected[session_id] = true
			if RachaAPI.is_show_debug:
				print ("WebRTC peer connected: " + str(peer_id))
			emit_signal("player_status_changed", players[session_id], PlayerStatus.CONNECTED)

	# We have a WebRTC peer for each connection to another player, so we'll have one less than
	# the number of players (ie. no peer connection to ourselves).
	if _webrtc_peers_connected.size() == players.size() - 1:
		if players.size() >= min_players:
			# All our peers are good, so we can assume RPC will work now.
			match_state = MatchState.READY;
			emit_signal("match_ready", players)
			emit_signal("start_match_countdown", 10)
			
		else:
			match_state = MatchState.WAITING_FOR_ENOUGH_PLAYERS

func _on_webrtc_peer_disconnected(peer_id: int) -> void:
	if RachaAPI.is_show_debug:
		print ("WebRTC peer disconnected: " + str(peer_id))
	
	for session_id in players:
		if players[session_id]['peer_id'] == peer_id:
			# We initiate the reconnection process from only one side (the offer side).
			if my_session_id.casecmp_to(session_id) < 0:
				# Tell the remote peer to restart their connection.
				nakama_socket.send_match_state_async(match_id, MatchOpCode.WEBRTC_PEER_METHOD, JSON.print({
					method = "reconnect",
					target = session_id,
				}))
			
				# Initiate reconnect on our end now (the other end will do it when they receive
				# the message above).
				_webrtc_reconnect_peer(players[session_id])
