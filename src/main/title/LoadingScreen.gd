extends Control


onready var error_cover = $UILayer/Cover
onready var error_bg_cover = $UILayer/BgCover
onready var error_cover_message = $UILayer/BgErrorMessage
onready var error_message = $UILayer/BgErrorMessage/ErrorMessage
onready var loading_status = $Message
onready var animation = $AnimationPlayer
onready var debug_message = $UILayer/DebugMessage

onready var progress_bar = $ProgressBarIn


var current_scene
var scene_loaded = false
var chk_agent_once := false

var loader
var wait_frames
var time_max = 100 # msec


#func goto_scene(path): # game requests to switch to this scene
#	loader = ResourceLoader.load_interactive(path)
#	if loader == null: # check for errors
#		return
#	set_process(true)

#	current_scene.queue_free() # get rid of the old scene
#	wait_frames = 1


func _ready():
	RachaAPI.connect("get_game_data", self, "_on_RachaAPI_get_game_data")
	RachaAPI.connect("agent_valid", self, "_on_RachaAPI_agent_valid_state")
	RachaAPI.connect("agent", self, "_on_RachaAPI_agent_state")
	RachaAPI.connect("ret_success", self, "_on_RachaAPI_ret_state")
	RachaAPI.connect("logged_in", self, "_on_Nakama_login")
	RachaAPI.connect("connection_message", self, "_on_show_message")
	GlobalSignals.connect("loading_debug_message", self, "_on_set_debug")
	
#	var root = get_tree().get_root()
#	current_scene = root.get_child(root.get_child_count() -1)
	
	_hide_status_bar()
	_on_show_debug_message()
	animation.play("loading")
	
	if DbSystem.log_in:
		progress_bar.play("100")
#		yield(get_tree().create_timer(2.0), "timeout")
#		goto_scene(DbSystem.to_scene)
		current_scene = get_tree().change_scene(DbSystem.to_scene)
		
	else:
		RachaAPI._on_GET_URL()
		_show_status_bar()


func _show_status_bar() -> void:
	$ProgressBarOut.visible = true
	progress_bar.visible = true
	loading_status.visible = true


func _hide_status_bar() -> void:
	$ProgressBarOut.visible = false
	progress_bar.visible = false
	loading_status.visible = false


func _on_set_debug(message: String) -> void:
	debug_message.text = message


func _on_RachaAPI_get_game_data(state) -> void:
	_show_status_bar()


func _on_RachaAPI_agent_valid_state(state):
#	debug_message.text = "Debug : Check agent valid : " + str(state)
	if not chk_agent_once:
		progress_bar.play("25")
		
	if state != "success":
		print("An error occurred in the HTTP request.")
		_on_show_message(RachaAPI.agent_valid_message)
	
	chk_agent_once = true


func _on_RachaAPI_agent_state(state):
#	debug_message.text = "Debug : Check agent : " + str(state)
	progress_bar.play("50")
	if state != "success":
		print("An error occurred in the HTTP request.")
		_on_show_message(RachaAPI.agent_message)


func _on_RachaAPI_ret_state():
	progress_bar.play("75")
	debug_message.text = "Debug : Ret user success"
	RachaAPI._on_connect_nakama_server()


func _on_Nakama_login():
	progress_bar.play("100")
	debug_message.text = "Debug : Login to Nakama success"
	DbSystem.log_in = true
	Globals.title_shown = true
#	current_scene = get_tree().change_scene("res://src/main/title/StartScreen.tscn")
	current_scene = get_tree().change_scene("res://src/main/title/MenuScreen.tscn")

#	var menu_scene = DbSystem.MenuScene.instance()
#	add_child(menu_scene)


func _on_show_message(message) -> void:
#	print(message)
	loading_status.visible = false
	$ProgressBarOut.visible = false
	progress_bar.visible = false
	error_bg_cover.visible = true
	error_cover.visible = true
	error_cover_message.visible = true
	error_message.text = message
	debug_message.visible = false


func _on_show_debug_message() -> void:
	debug_message.text = "Debug : Loading..."
	if RachaAPI.is_show_debug:
		debug_message.visible = true
	else:
		debug_message.visible = false

