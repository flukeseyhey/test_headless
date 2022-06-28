extends "res://src/main/adventure/actors/BaseTank.gd"

class_name PlayerOffline

#const ShadowTank = preload("res://src/main/adventure/abilities/ShadowTank.tscn")

const Explosion = preload("res://src/objects/Explosion.tscn")
const die_ef = preload("res://src/main/adventure/actors/TankDestroy.tscn")


signal player_dead (killer_id)
signal shoot ()
signal hurt (damage, attacker_id, attack_vector)
signal weapon_type_changed (weapon_type)
signal ability_type_changed (ability_type)
signal ability_recharged (ability)


signal player_health_changed(new_health)
signal died

var tank_rotation = 0
var shooting = false
var can_shoot = true


onready var tank_ui = $AdventureLayer/TankHUD
onready var users_info = $AdventureLayer/TankHUD/UserInfo
onready var money_gain = $AdventureLayer/TankHUD/UserInfo/MoneyGain/Label

onready var player_info_health := $PlayerInfo/Background/VBoxContainer/Control/Label
onready var player_info_node := $PlayerInfo
onready var player_info_offset: Vector2 = player_info_node.position

#onready var collision_shape = $CollisionShape2D
#onready var team = $Team
onready var weapon_manager = $WeaponManager
onready var health_stat = $Health
onready var camera_transform = $CameraTransform

onready var joystick_handle = $AdventureLayer/TankHUD/JoyStickButton/Joystick/joystick_handle

onready var engine_sound := $EngineSound

onready var skill_boost_sound := $SkillSound/Boost
onready var skill_invis_sound := $SkillSound/Invis

onready var shoot_sound_normal := $ShootSound/Normal
onready var shoot_sound_lazer := $ShootSound/Lazer


var _is_info := false


func _ready() -> void:

	weapon_manager.initialize(team.team)
	health_stat.set_player_health(DbSystem.player_health)
	
	player_info_health.text = str(DbSystem.player_health) + "/" + str(DbSystem.player_health)
	player_info_node.set_as_toplevel(true)
	player_info_node.position = global_position + player_info_offset
	
	
	GlobalSignals.connect("shooted", self, "player_shooted")
	GlobalSignals.connect("update_gain_money", self, "handle_update_money")
	GlobalSignals.connect("adventure_end", self, "hide_ui")
#	GlobalSignals.connect("info_click", self, "_show_hide_all")
	
#func _input(event):
#	if event is InputEventScreenTouch and event.is_pressed() and can_shoot:
#		var TouchPoint = event.position
#
#		if ShootArea.has_point(TouchPoint):
#			shooting = true

#func _show_hide_all() -> void:
#	if _is_info:
#		tank_ui.visible = true
#		users_info.visible = true
#		_is_info = false
#	else:
#		tank_ui.visible = false
#		users_info.visible = false
#		_is_info = true

func show_ui() -> void:
	tank_ui.visible = true
	
func hide_ui() -> void:
	tank_ui.visible = false

func hide_ui_no_joy():
	$AdventureLayer/TankHUD/ShootButton.visible = false
	$AdventureLayer/TankHUD/SkillButton.visible = false
	$AdventureLayer/TankHUD/Cooldown.visible = false
	$AdventureLayer/TankHUD/SkillPrice.visible = false


func show_user_info() -> void:
	users_info.visible = true

func hide_user_info() -> void:
	users_info.visible = false


func _physics_process(delta: float) -> void:
	player_info_node.position = global_position + player_info_offset
	var movement_direction = joystick_handle.get_value()
	move_and_slide(movement_direction * DbSystem.player_speed)

	if joystick_handle.get_value():
		tank_rotation = movement_direction.angle()
		engine_sound.engine_state = engine_sound.EngineState.DRIVING
	else:
		engine_sound.engine_state = engine_sound.EngineState.IDLE

	set_tank_rotation()

	if shooting:
		var weapon := $WeaponManager/Pistol
		weapon.shoot()
		shooting = false


func set_tank_rotation():
	rotation = tank_rotation


func set_camera_transform(camera_path: NodePath):
	camera_transform.remote_path = camera_path


func get_team() -> int:
	return team.team


func handle_update_money():
	money_gain.text = str(DbSystem.money_gain)


func handle_hit():
	var enemy_damage
	match AdventureMatch.difficulty_level:
		AdventureMatch.DifficultyLevel.EASY:
			enemy_damage = DbSystem.enemy_damage * DbSystem.easy_mode_difficulty_multiple
		AdventureMatch.DifficultyLevel.NORMAL:
			enemy_damage = DbSystem.enemy_damage * DbSystem.normal_mode_difficulty_multiple
		AdventureMatch.DifficultyLevel.HARD:
			enemy_damage = DbSystem.enemy_damage * DbSystem.hard_mode_difficulty_multiple
			
	health_stat.player_health -= enemy_damage
	emit_signal("player_health_changed", health_stat.player_health)
	if health_stat.player_health <= 0:
		die()
	else:
		player_info_node.update_health(health_stat.player_health)
		player_info_health.text = str(health_stat.player_health) + "/" + str(DbSystem.player_health)


func spawn_effect(EFFECT: PackedScene, effect_position: Vector2 = global_position):
	if EFFECT:
		var effect = EFFECT.instance()
		get_tree().current_scene.add_child(effect)
		effect.global_position = effect_position
		return effect


func die():
	var explosion = Explosion.instance()
	get_parent().add_child(explosion)
	explosion.setup(global_position, 1.5, "fire")
	
	spawn_effect(die_ef)
	emit_signal("died")
	queue_free()


func player_shooted():
	shoot_sound_normal.play()


func _on_AdventureLayer_press_boost_skill():
	_use_skill_boost()

func _on_AdventureLayer_press_zap_skill():
	_use_skill_zap()

func _on_AdventureLayer_press_invis_skill():
	_use_skill_invisible()

func _on_AdventureLayer_shoot():
	shooting = true
#	_on_player_shoot()
