extends "res://src/ui/Screen.gd"

var PlayerStatus = preload("res://src/ui/PlayerStatus.tscn");

onready var status_container := $Panel/StatusContainer
onready var countdown_timer := $CountdownTimer
onready var room_tpye := $RoomType/Label
onready var panel := $Panel
onready var room_start_text := $Panel/Label

onready var animation := $AnimationPlayer

signal room_auto_start ()

func _ready() -> void:
	show_room_type()
	clear_players()
	panel.visible = false
	
	OnlineMatch.connect("player_joined", self, "_on_OnlineMatch_player_joined")
	OnlineMatch.connect("player_left", self, "_on_OnlineMatch_player_left")
	OnlineMatch.connect("player_status_changed", self, "_on_OnlineMatch_player_status_changed")
	OnlineMatch.connect("match_ready", self, "_on_OnlineMatch_match_ready")
	OnlineMatch.connect("match_not_ready", self, "_on_OnlineMatch_match_not_ready")
	
	
func show_room_type() -> void:
	countdown_timer.visible = true
	room_tpye.text = "ห้อง " + str(DbSystem.CurrentRoomType) + " บาท"


func check_players():
	var player_size = status_container.get_children().size()
	return player_size

func _show_screen(info: Dictionary = {}) -> void:
	var players: Dictionary = info.get("players", {})
	var match_id: String = info.get("match_id", '')
	var clear: bool = info.get("clear", false)
	
	if players.size() > 0 or clear:
		clear_players()
	
	for session_id in players:
		add_player(session_id, players[session_id]['username'], players[session_id]['peer_id'] == 1)
	

func clear_players() -> void:
	for child in status_container.get_children():
		status_container.remove_child(child)
		child.queue_free()

func add_player(session_id: String, username: String, is_host: bool = false) -> void:
	if not status_container.has_node(session_id):
		var status = PlayerStatus.instance()
		status_container.add_child(status)
		status.initialize(username, "กำลังเชื่อมต่อ...")
		status.name = session_id
		status.host = is_host

func remove_player(session_id: String) -> void:
	var status = status_container.get_node(session_id)
	if status:
		status.queue_free()

func set_status(session_id: String, status: String) -> void:
	var status_node = status_container.get_node(session_id)
	if status_node:
		status_node.set_status(status)

func get_status(session_id: String) -> String:
	var status_node = status_container.get_node(session_id)
	if status_node:
		return status_node.status
	return ''

func reset_status(status: String) -> void:
	for child in status_container.get_children():
		child.set_status(status)

#####
# OnlineMatch callbacks:
#####

func _on_OnlineMatch_player_joined(player) -> void:
	add_player(player.session_id, player.username, player.peer_id == 1)

func _on_OnlineMatch_player_left(player) -> void:
	remove_player(player.session_id)

func _on_OnlineMatch_player_status_changed(player, status) -> void:
	if status == OnlineMatch.PlayerStatus.CONNECTED:
		# Don't go backwards from 'READY!'
		if get_status(player.session_id) != 'พร้อม!':
			set_status(player.session_id, 'เชื่อมต่อแล้ว.')
	elif status == OnlineMatch.PlayerStatus.CONNECTING:
		set_status(player.session_id, 'กำลังเชื่อมต่อ...')



func _on_CountdownTimer_start_match_finished():
	emit_signal("room_auto_start")


func _on_CountdownTimer_show_player():
	panel.visible = true
	countdown_timer.visible = false
	animation.play("game_start_sec")
