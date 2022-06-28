extends Node

# For developers to set from the outside, for example:
#   Online.nakama_host = 'nakama.example.com'
#   Online.nakama_scheme = 'https'
var nakama_server_key: String = 'AzaktWUMOfvzoyhu3pJlhvTDYMdDKHHq'
#var nakama_host: String = '127.0.0.1'
#var nakama_host: String = '47.241.189.210'
var nakama_host: String = 'slotrachagame.com'
var nakama_port: int = 7350
#var nakama_scheme: String = 'http'
var nakama_scheme: String = 'https'

# Fon other scripts to access:
var nakama_client: NakamaClient setget _set_readonly_variable, get_nakama_client
var nakama_session: NakamaSession setget set_nakama_session
var nakama_socket: NakamaSocket setget _set_readonly_variable

# Internal variable for initializing the socket.
var _nakama_socket_connecting := false

#var thread
## Make this a node variable, or it will disconnect when the function that creates it returns.
#onready var socket := Nakama.create_socket_from(Online.nakama_client)

signal session_changed (nakama_session)
signal session_connected (nakama_session)
signal socket_connected (nakama_socket)

func _set_readonly_variable(_value) -> void:
	pass

func _ready() -> void:
	
	# Don't stop processing messages from Nakama when the game is paused.
	Nakama.pause_mode = Node.PAUSE_MODE_PROCESS
	
	
	if RachaAPI.is_test_demo:
		nakama_host = "8.214.18.227"
		nakama_scheme = "http"
	else:
		nakama_server_key = DbSystem.nakama_server_key
		nakama_host = DbSystem.nakama_server
		
		
	print(nakama_host)
	print(nakama_server_key)
	print(nakama_scheme)

func get_nakama_client() -> NakamaClient:
	if nakama_client == null:
		nakama_client = Nakama.create_client(
			nakama_server_key,
			nakama_host,
			nakama_port,
			nakama_scheme,
			Nakama.DEFAULT_TIMEOUT,
			NakamaLogger.LOG_LEVEL.ERROR)
	
	return nakama_client

func set_nakama_session(_nakama_session: NakamaSession) -> void:
	# Close out the old socket.
	if nakama_socket:
		nakama_socket.close()
		nakama_socket = null
	
	nakama_session = _nakama_session
	
	emit_signal("session_changed", nakama_session)
	
	if nakama_session and not nakama_session.is_exception() and not nakama_session.is_expired():
		emit_signal("session_connected", nakama_session)

func connect_nakama_socket() -> void:
	if nakama_socket != null:
		return
	if _nakama_socket_connecting:
		return
	_nakama_socket_connecting = true
	
	var new_socket = Nakama.create_socket_from(nakama_client)
	yield(new_socket.connect_async(nakama_session), "completed")
	nakama_socket = new_socket
	_nakama_socket_connecting = false
	
	emit_signal("socket_connected", nakama_socket)

func is_nakama_socket_connected() -> bool:
	   return nakama_socket != null && nakama_socket.is_connected_to_host()
