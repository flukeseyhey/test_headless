extends Node2D

var TankScene = preload("res://src/objects/Tank.tscn")
var FreeSpaceDetector = preload("res://src/game/FreeSpaceDetector.tscn")

onready var map: Node2D = $Map
onready var players_node := $Players
onready var player_camera := $PlayerCamera
#onready var camera := $Camera2D
onready var watch_camera := $WatchCamera
onready var hud := $CanvasLayer/HUD
onready var timer = $ZoomTimer
onready var animation = $AnimationPlayer

var map_scene: PackedScene
var game_started := false
var players := {}
var players_alive := {}
var possible_pickups := []


signal game_error (message)
signal game_started ()
signal player_spawned (tank)
signal player_dead (player_id, killer_id)
signal make_player_controlled (my_tank, player_id)

class Player:
	var peer_id: int
	var name: String
	var index: int
	var team: int
	
	func _init(_peer_id: int, _name: String, _index: int, _team: int = -1):
		peer_id = _peer_id
		name = _name
		index = _index
		team = _team

func _ready():
	GlobalSignals.connect("player_cam_zoom_in", self, "_zoom_in")
	GlobalSignals.connect("player_cam_zoom_out", self, "_zoom_out")



func _get_synchronized_rpc_methods() -> Array:
	return ['respawn_player']

# Initializes the game so that it is ready to really start.
func game_setup(_players: Dictionary, map_path: String, player_start_transforms = null, operation: RemoteOperations.ClientOperation = null) -> void:
	get_tree().set_pause(true)
	
	if game_started:
		game_stop()
	
	hud.clear_all_labels()
	
	players = _players
	game_started = true
	
	if not load_map(map_path):
		emit_signal("game_error", "Unable to load map")
		if operation:
			operation.mark_done(false)
		return
	
	if is_network_master():
		# Build up a list of possible contents for drawing randomly.
		for pickup_path in Modding.find_resources("pickups"):
			var pickup = load(pickup_path)
			for i in range(pickup.rarity):
				possible_pickups.append(pickup)
	
	for peer_id in players:
		var player = players[peer_id]
		var start_transform = player_start_transforms[player.index - 1] if player_start_transforms and player.index <= player_start_transforms.size() else null
		respawn_player(peer_id, start_transform)
		
	
	var my_id: int = get_tree().get_network_unique_id()
	make_player_controlled(my_id) #######################################################################################################################################################
	
	if operation:
		operation.mark_done(true)

func respawn_player(peer_id: int, start_transform = null) -> void:
	if players_node.has_node(str(peer_id)):
		return
	
	if not players.has(peer_id):
		return
	var player = players[peer_id]
	players_alive[peer_id] = player
	
	var tank = TankScene.instance()
	tank.name = str(peer_id)
	players_node.add_child(tank)
	
#	tank.set_camera_transform(camera.get_path())
#	tank._hook_set_camera_transform(player_camera.get_path())
#	enable_watch_camera(false)
	
	if start_transform:
		tank.global_transform = start_transform
	else:
		var player_start_transforms = map.get_player_start_transforms()
		tank.global_transform = player_start_transforms[player.index - 1]
	
	tank.setup_tank(self, player)
	tank.connect("player_dead", self, "_on_player_dead", [peer_id])
	
	emit_signal("player_spawned", tank)


func make_player_controlled(peer_id) -> void:
	var my_player := players_node.get_node(str(peer_id))
	if my_player and not my_player.player_controlled:
		my_player.player_controlled = true
		_setup_player_camera(my_player)
		emit_signal("make_player_controlled", my_player, peer_id)
	else:
		print ("Unable to make player controlled: node not found")

func get_tank(player_id: int):
	return players_node.get_node(str(player_id))

func get_my_tank():
	for peer_id in players_alive:
		var tank := players_node.get_node(str(peer_id))
		if tank.player_controlled:
			return tank
	return null

# Actually start the game on this client.
remotesync func game_start() -> void:
	if map.has_method('map_start'):
		map.map_start(self)
	emit_signal("game_started")
	get_tree().set_pause(false)

func game_stop() -> void:
	if map.has_method('map_stop'):
		map.map_stop(self)
	
	game_started = false
	
	players_alive.clear()
	watch_camera.current = true
	
	for child in players_node.get_children():
		players_node.remove_child(child)
		child.queue_free()

func load_map(path: String) -> bool:
	var new_map_scene = load(path)
	if not new_map_scene or not new_map_scene is PackedScene:
		return false
	
	map_scene = new_map_scene
	reload_map()
	
	return true

func reload_map() -> void:
	if not map_scene:
		return
	
	var map_index = map.get_index()
	remove_child(map)
	map.queue_free()
	
	map = map_scene.instance()
	map.name = 'Map'
	add_child(map)
	move_child(map, map_index)
	
	_setup_watch_camera()

func _setup_watch_camera() -> void:
	var viewport_rect = get_viewport_rect()
	var map_rect = map.get_map_rect()
	
	watch_camera.global_position = map_rect.position + (map_rect.size / 2)
	# Yes, on non-square maps, this will zoom differently on the X and Y,
	# but so far, no one has ever noticed this.
	watch_camera.zoom.x = max(1.0, map_rect.size.x / viewport_rect.size.x)
	watch_camera.zoom.y = max(1.0, map_rect.size.y / viewport_rect.size.y)

func _setup_player_camera(my_player) -> void:
#	my_player.camera = camera
	my_player.camera = player_camera
#	camera.global_position = my_player.global_position
	player_camera.global_position = my_player.global_position
	watch_camera.current = false
	player_camera.current = true
#	camera.current = true
	
	# Enable positional audio when the player_camera is enabled.
	Globals.use_positional_audio = true
	
	if map.has_method('get_map_rect'):
		var map_rect = map.get_map_rect()
		
#		camera.limit_left = map_rect.position.x
#		camera.limit_top = map_rect.position.y
#		camera.limit_right = map_rect.end.x
#		camera.limit_bottom = map_rect.end.y
		player_camera.limit_left = map_rect.position.x
		player_camera.limit_top = map_rect.position.y
		player_camera.limit_right = map_rect.end.x
		player_camera.limit_bottom = map_rect.end.y

func kill_player(player_id) -> void:
	var player_node = players_node.get_node(str(player_id))
	if player_node:
		if player_node.has_method("die"):
			player_node.die()
		else:
			# If there is no die method, we do the most important things it
			# would have done.
			player_node.queue_free()
			_on_player_dead(-1, player_id)

func remove_player(player_id) -> void:
	players.erase(player_id)
	kill_player(player_id)

func enable_watch_camera(enable: bool = true) -> void:
#	camera.current = not enable
	player_camera.current = not enable
	watch_camera.current = enable
	
	# Disable positional audio when the watch camera is enabled.
	Globals.use_positional_audio = not enable

func _on_player_dead(killer_id, player_id) -> void:
	# Ensure this will only ever be called once per player
	if players_alive.has(player_id):
		players_alive.erase(player_id)
		
		var player_node = players_node.get_node(str(player_id))
		if player_node and player_node.player_controlled:
			hud.clear_all_labels()
		
		emit_signal("player_dead", player_id, killer_id)


func create_free_space_detector():
	var detector = FreeSpaceDetector.instance()
	add_child(detector)
	return detector


var zoom_done = true


func _zoom_in():
	if zoom_done:
		timer.start()
		animation.play("zoom_in")
		zoom_done = false


func _zoom_out():
	if zoom_done:
		timer.start()
		animation.play("zoom_out")
		zoom_done = false


func _on_ZoomTimer_timeout():
	print("zoom done")
	zoom_done = true
	
