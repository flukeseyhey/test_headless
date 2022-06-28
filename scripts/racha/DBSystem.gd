extends Node


# ============================= APPLICATION SETTING ============================
# go server connection
var rachamaster = '' #ไม่ต้องใส่ / ต่อท้าย
#var rachamaster: String = 'https://rachamaster.com' #ไม่ต้องใส่ / ต่อท้าย
var go_server_host: String = 'https://matchmaking.rachaarena.com' #ไม่ต้องใส่ / ต่อท้าย
#var go_server_host: String = 'http://localhost' #ไม่ต้องใส่ / ต่อท้าย
var nakama_server = ""
var headless_server = ""
var nakama_server_key = ""

# ret user
var money = 0.0
var appid = ""

# fake nakama login
var username = "TankBattle"
var nakama_email = "tankbattle@rachadev.com"
var nakama_password = "tankbattleatrachadevdotcom"

# application
var to_scene = ""
var state_offline_sound_button = ""
var state_muti_ui_button = ""
var loading_status = "Loading..."
var game_is_playing = false
var game_is_end = false
var log_in = false
var scene
var stop_sent_credit = true

const LoadingScene = preload("res://src/main/title/LoadingScreen.tscn")
const MenuScene = preload("res://src/main/title/MenuScreen.tscn")
const AdventureScene = preload("res://src/main/adventure/Main.tscn")
const GameOverScreen = preload("res://src/main/adventure/UI/GameOverScreen.tscn")

# ==============================================================================


# ============================= ONLINE MODE BET SETTING ====================
var committion = 15
# thread
#var mutex
#var thread
# ==============================================================================


# ============================= ADVENTURE MODE SETTING =========================
var player_health = 100
var player_speed = 400
var player_default_speed = 400
var player_damage = 10

var enemy_health = 100
var enemy_speed = 400
var enemy_damage = 10

var easy_mode_kill_count = 4
var normal_mode_kill_count = 5
var hard_mode_kill_count = 6

var easy_mode_difficulty_multiple = 0.5
var normal_mode_difficulty_multiple = 1.0
var hard_mode_difficulty_multiple = 1.5

var bullet_speed = 12 #normal
var tracer_speed = 12 #tracer
var laser_speed = 12 #laser

var money_gain = 0.0
var total_money_gain = 0.0

var easy_match_timer = 90
var normal_match_timer = 120
var hard_match_timer = 180

var boost_price = 0.75
var zap_price = 1.25
var invis_price = 2.00

var coin_bet = 0.00
var total_pay = 0.00
var money_bet = 0.00

var skill_boost_cooldown = 0.5
var skill_zap_cooldown = 2.0
var skill_invisible_cooldown = 5.0

var enable_skill_boost = true
var enable_skill_zap = true
var enable_skill_invisible = true

#var endless_kill_count = 0

#Coin Drops
var money_bronze_coin_value = 0.02
var money_silver_coin_value = 0.05
var money_gold_coin_value = 0.15

var gold = 1
var silver = 1
var bronze = 1

var n_coin_drop_min = 5
var n_coin_drop_max = 8

var coin_drop_rate = [85, 15, 5]


var map_rect: Rect2
# ==============================================================================


# ============================= ONLINE MODE SETTING ============================
# nakama create match
var CurrentMatch = ""
var CurrentRoomType = 1.0
var CurrentResultMatch = {}
var CurrentPlayerSession = {}
var CurrentMySessionID

# both mode(random) = 0, battle_royale = 1, death_match = 2
var set_enable_online_mode = 2

# game mode win count
var battle_royale_count = 1 # kill
var death_match_count = 2 # mins

var online_player_health = 100
var online_bullet_speed = 600

var TANK_DEFAULT_SPEED = 400
var TANK_DEFAULT_TURN_SPEED = 5


# end match
var host_score = {}


# golang match state
var golang_start_match = "invalid"

#var test_map = true
var test_map = false
#var test_map_size = 0 # 0 = small, 1 med, 2 = large


func _ready():
	pass


# ==============================================================================
func random_health_adventure():
	var random
	if AdventureMatch.adventure_mode == AdventureMatch.AdventureMode.LEVEL:
		match AdventureMatch.difficulty_level:
			AdventureMatch.DifficultyLevel.EASY:
				random = rand_range(4, 6)
			AdventureMatch.DifficultyLevel.NORMAL:
				random = rand_range(5, 8)
			AdventureMatch.DifficultyLevel.HARD:
				random = rand_range(6, 10)
	else:
		random = rand_range(4, 10)
		
	return int(random) * 10

func reset_game_to_default():
	money_bet = 0
	total_pay = 0
	
	money_gain = 0
	total_money_gain = 0
	
	CurrentRoomType = 0
	CurrentMatch = ""
	CurrentResultMatch = {}
	CurrentPlayerSession = {}
	CurrentMySessionID = ""
	
	host_score = {}
	
	game_is_end = true
	game_is_playing = false


func total_online_bet(total_bet):
	RachaAPI._on_BET(total_bet)
#	var error = RachaAPI._on_BET(total_bet)
#	if error != OK:
#		push_error("error from HTTP request")
	


func total_offline_bet(code, total_bet):
	if game_is_end == false and stop_sent_credit == false:
		RachaAPI._on_BET_RES(code, total_bet)
		total_offline_bet(false, total_bet)
	elif game_is_end == true and stop_sent_credit == false:
		RachaAPI._on_BET_RES(code, total_bet)
		stop_sent_credit = true
	yield(get_tree().create_timer(0.7777777),"timeout")
	
	DbSystem.CurrentRoomType = 0.00
