extends Node2D

onready var lifetime_timer := $LifetimeTimer
onready var warning_timer := $WarningTimer
onready var visible_timer := $VisibleTimer
onready var blink_timer := $BlinkTimer

var ability_type
var marked_as_finished := false

var used := false

signal set_tank_visible(tank_visible)
signal blink_timeout()
#signal finished()

func use_ability() -> void:
	if not used:
		used = true
		emit_signal("set_tank_visible", false)
		
		warning_timer.start()
		lifetime_timer.start()


func expose_hidden_tank() -> void:
	if used:
#		set_tank_visible(true)
		emit_signal("set_tank_visible", true)
		visible_timer.start()

#func _on_tank_shoot() -> void:
#	expose_hidden_tank()

#func _on_tank_hurt(damage, attacker_id, attack_vector) -> void:
#	expose_hidden_tank()

#func _on_tank_weapon_type_changed(weapon_type: WeaponType) -> void:
#	if weapon_type != Tank.BaseWeaponType:
#		expose_hidden_tank()

#func _hook_tank_pickup(event) -> void:
#	expose_hidden_tank()

func _on_VisibleTimer_timeout() -> void:
#	set_tank_visible(false)
	if used:
		emit_signal("set_tank_visible", false)
	

func _on_WarningTimer_timeout() -> void:
	if blink_timer.is_stopped():
		blink_timer.start()

func _on_BlinkTimer_timeout() -> void:
	emit_signal("blink_timeout")

func _on_LifetimeTimer_timeout() -> void:
	blink_timer.stop()
	
	# Make sure we don't get stuck invisible
	used = false
	emit_signal("set_tank_visible", true)
#	emit_signal("finished")
	
#	queue_free()
	
