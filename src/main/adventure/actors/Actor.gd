extends KinematicBody2D
class_name ActorOffline

const BRONZE_COIN: PackedScene = preload("res://src/main/adventure/coin/Bronze.tscn")
const SILVER_COIN: PackedScene = preload("res://src/main/adventure/coin/Silver.tscn")
const GOLD_COIN: PackedScene = preload("res://src/main/adventure/coin/Gold.tscn")

const Explosion = preload("res://src/objects/Explosion.tscn")
const die_ef = preload("res://src/main/adventure/actors/TankDestroy.tscn")

signal died

onready var player_info_health := $PlayerInfo/Background/VBoxContainer/Control/Label
onready var player_info_node := $PlayerInfo
onready var player_info_offset: Vector2 = player_info_node.position


onready var collision_shape = $CollisionShape2D
onready var health_stat = $Health
onready var ai = $AI
onready var weapon: Weapon = $Weapon
onready var team = $Team


var speed
var detector

var current_health


func _ready() -> void:
#	var node_name = self.get_name()
#	if node_name == "Ally" or node_name == "@Ally@24" or node_name == "@Ally@25" or node_name == "@Ally@26":
#		speed = DbSystem.ally_speed
#	else:
#		speed = DbSystem.enemy_speed
	set_health()
	set_speed()
		
	ai.initialize(self, weapon, team.team)
	weapon.initialize(team.team)
	
	player_info_node.set_as_toplevel(true)
	player_info_node.position = global_position + player_info_offset


func _physics_process(delta) -> void:
	player_info_node.position = global_position + player_info_offset


func set_health():
#	if AdventureMatch.adventure_mode == AdventureMatch.AdventureMode.LEVEL:
#		match AdventureMatch.difficulty_level:
#			AdventureMatch.DifficultyLevel.EASY:
#				var ran_health = rand_range(30, 60)
#				health_stat.set_enemy_health(ran_health)
#			AdventureMatch.DifficultyLevel.NORMAL:
#				var ran_health = rand_range(40, 80)
#				health_stat.set_enemy_health(ran_health)
#			AdventureMatch.DifficultyLevel.HARD:
#				var ran_health = rand_range(50, 100)
#				health_stat.set_enemy_health(ran_health)
#	else:
#		var ran_health = rand_range(30, 100)
#		health_stat.set_enemy_health(ran_health)
	var health = DbSystem.random_health_adventure()
	DbSystem.enemy_health = health
	health_stat.set_enemy_health(health)
	current_health = health
	player_info_health.text = str(current_health) + "/" + str(current_health)


func set_speed():
	if AdventureMatch.adventure_mode == AdventureMatch.AdventureMode.LEVEL:
		match AdventureMatch.difficulty_level:
			AdventureMatch.DifficultyLevel.EASY:
				speed = DbSystem.enemy_speed * DbSystem.easy_mode_difficulty_multiple
			AdventureMatch.DifficultyLevel.NORMAL:
				speed = DbSystem.enemy_speed * DbSystem.normal_mode_difficulty_multiple
			AdventureMatch.DifficultyLevel.HARD:
				speed = DbSystem.enemy_speed * DbSystem.hard_mode_difficulty_multiple
	else:
		speed = DbSystem.enemy_speed


func rotate_toward(location: Vector2):
	rotation = lerp_angle(rotation, global_position.direction_to(location).angle(), 0.1)


func velocity_toward(location: Vector2) -> Vector2:
	return global_position.direction_to(location) * speed


func has_reached_position(location: Vector2) -> bool:
	return global_position.distance_to(location) < 10


func get_team() -> int:
	return team.team


func handle_hit():
	health_stat.enemy_health -= DbSystem.player_damage
	if health_stat.enemy_health <= 0:
		die()
	else:
		player_info_node.update_health(health_stat.enemy_health)
		player_info_health.text = str(health_stat.enemy_health) + "/" + str(current_health)


func spawn_effect(EFFECT: PackedScene, effect_position: Vector2 = global_position):
	if EFFECT:
		var effect = EFFECT.instance()
		get_tree().current_scene.add_child(effect)
		effect.global_position = effect_position
#		rotation = self.
		return effect


func die():
	ai.set_state(ai.State.NONE)
	
	
	for ran_coin in randi() % DbSystem.n_coin_drop_max + DbSystem.n_coin_drop_min :
		random()
#		self.position.y += rand_range(-20, 20)
#		self.position.x += rand_range(-20, 20)
	
	var explosion = Explosion.instance()
	get_parent().add_child(explosion)
	explosion.setup(global_position, 1.5, "fire")
	
	spawn_effect(die_ef)
	emit_signal("died")
	queue_free()


func random():
	var main = get_tree().current_scene
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var my_random_number = rng.randi_range(1,100)
	
	var gold_coin_drop
	var silver_coin_drop
	var bornze_coin_drop
	
	
	if my_random_number <= DbSystem.coin_drop_rate[2]:
		gold_coin_drop = GOLD_COIN.instance()
		main.call_deferred("add_child", gold_coin_drop )
		gold_coin_drop.global_position = global_position
		if RachaAPI.is_show_debug: 
			print("gold drop")
		
	elif my_random_number > DbSystem.coin_drop_rate[2] and my_random_number <= DbSystem.coin_drop_rate[1]:
		silver_coin_drop = SILVER_COIN.instance()
		main.call_deferred("add_child", silver_coin_drop )
		silver_coin_drop.global_position = global_position
		if RachaAPI.is_show_debug: 
			print("silver drop")
		
	else:
		bornze_coin_drop = BRONZE_COIN.instance()
		main.call_deferred("add_child", bornze_coin_drop )
		bornze_coin_drop.global_position = global_position
		if RachaAPI.is_show_debug: 
			print("bornze drop")
	
