extends Node2D


onready var timer = $Timer

var boosting := false
var spawn_rate := 2
var spawn_counter := 0

signal using_ability()
#signal finished()

#func spawn() -> void:
#	var tank_parent: Node2D = get_parent()
#	var shadow_tank = ShadowTank.instance()
#	tank_parent.add_child(shadow_tank)
#	tank_parent.move_child(shadow_tank, 0)
#	shadow_tank.setup_shadow_tank(tank)

func _physics_process(delta: float) -> void:
	if boosting:
		if spawn_counter <= 0:
			spawn_counter = spawn_rate
			emit_signal("using_ability")
#			spawn()

		spawn_counter -= 1

func use_ability() -> void:
	if not boosting:
		DbSystem.player_default_speed = DbSystem.player_speed
		DbSystem.player_speed = DbSystem.player_speed * 4
		timer.start()
		boosting = true

func _on_Timer_timeout() -> void:
	DbSystem.player_speed = DbSystem.player_default_speed
	boosting = false
#	emit_signal("finished")
#	queue_free()
