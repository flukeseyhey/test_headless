extends KinematicBody2D


const ShadowTank = preload("res://src/main/adventure/abilities/ShadowTank.tscn")

onready var boost_skill := $Boost
onready var zap_skill := $Zap
onready var invisible := $Invisible

onready var collision_shape := $CollisionShape2D

onready var team := $Team

var tank
var tank_visible := true

const VISIBLE_COLOR := Color(1.0, 1.0, 1.0, 1.0)
const INVISIBLE_COLOR := Color(1.0, 1.0, 1.0, 0.38)

func _ready():
	tank = self
	detector = create_free_space_detector()
	detector.connect("free_space_found", self, "_on_free_space_found")

#func _on_player_shoot() -> void:
#	invisible.expose_hidden_tank()


func _use_skill_boost() -> void:
	boost_skill.use_ability()

func _use_skill_zap() -> void:
	use_ability()

func _use_skill_invisible() -> void:
	invisible.use_ability()



#func _on_Boost_using_ability():
#	var tank_parent: Node2D = tank.get_parent()
#	var shadow_tank = ShadowTank.instance()
#	tank.add_child(shadow_tank)
#	tank.move_child(shadow_tank, 0)
#	shadow_tank.setup_shadow_tank(tank)


func _on_Zap_using_zap():
	pass # Replace with function body.


func _on_Invisible_set_tank_visible(_tank_visible):
	tank_visible = _tank_visible
	tank.visible = true
	tank.modulate = VISIBLE_COLOR if tank_visible else INVISIBLE_COLOR
	
	if _tank_visible:
#		print("team player")
		#	team.team = team.TeamName.ENEMY
		GlobalSignals.emit_signal("set_team", false)
	else:
#		print("team enemy")
		#	team.team = team.TeamName.ENEMY
		GlobalSignals.emit_signal("set_team", true)
		



func _on_Invisible_blink_timeout():
	tank.visible = false if tank.visible else true


#func _on_Invisible_finished():
#	print("team player")
##	team.team = team.TeamName.PLAYER
#	GlobalSignals.emit_signal("set_team", false)



# -------------------------------------------------------------------------------

var FreeSpaceDetector = preload("res://src/game/FreeSpaceDetector.tscn")

onready var tween := $Zap/Tween
onready var hiding_sound := $Zap/HidingSound
onready var showing_sound := $Zap/ShowingSound

const TANK_SIZE := Vector2(128, 128)

var ability_type
var marked_as_finished := false

#var game

var detector
var map_rect: Rect2

enum ZapStage {
	NONE,
	DETECTING,
	HIDING,
	HIDDEN,
	SHOWING,
}

var zap_stage = ZapStage.NONE
var destination: Vector2

func use_ability() -> void:
	if zap_stage == ZapStage.NONE and not detector.detecting:
		zap_stage = ZapStage.DETECTING
		detector.start_detecting(DbSystem.map_rect, TANK_SIZE)

#func _hook_tank_shoot(event) -> void:
#	if zap_stage >= ZapStage.DETECTING:
#		event.stop_propagation()

func mark_finished() -> void:
#	if zap_stage != ZapStage.NONE:
#		charges = 0
#	else:
	.mark_finished()

func _on_free_space_found(_destination) -> void:
	if zap_stage != ZapStage.DETECTING:
		return

	destination = _destination

	tank.collision_shape.set_deferred("disabled", true)

	zap_stage = ZapStage.HIDING
	tween.interpolate_property(tank, "scale", Vector2(1.0, 1.0), Vector2.ZERO, 0.15)
	tween.start()

	if not tank.is_network_master():
		tank.player_info_node.visible = false

	hiding_sound.play()

func create_free_space_detector():
	var detector = FreeSpaceDetector.instance()
	add_child(detector)
	return detector

func _on_Tween_tween_all_completed() -> void:
	if zap_stage == ZapStage.HIDING:
#		print("zap hidden")
		zap_stage = ZapStage.HIDDEN
		tank.visible = false
#		if tank.is_network_master():
		tween.interpolate_property(tank, "global_position", tank.global_position, destination, 1.0)
		tween.start()
#		else:
#			tank.global_position = destination
	elif zap_stage == ZapStage.HIDDEN:
		# Make sure this runs on all clients, because we aren't tweening on 
		# non-hosts.
#		if tank.is_network_master():
#			rpc("show_tank")
#			print("show")
			show_tank()
#		emit_signal("show_tank")
	elif zap_stage == ZapStage.SHOWING:
		zap_stage = ZapStage.NONE
		tank.collision_shape.set_deferred("disabled", false)
		
#		if charges <= 0:
#		emit_signal("finished")

func show_tank() -> void:
	zap_stage = ZapStage.SHOWING
	tank.visible = true
	tank.player_info_node.visible = true
	tween.interpolate_property(tank, "scale", Vector2.ZERO, Vector2(1.0, 1.0), 0.15)
	tween.start()
	showing_sound.play()












