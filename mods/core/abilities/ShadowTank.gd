extends KinematicBody2D

onready var collision_shape := $CollisionShape2D

func setup_shadow_tank(tank) -> void:
	global_position = tank.global_position
	global_rotation = tank.global_rotation
	collision_shape.set_deferred("disabled", true)

func _on_Timer_timeout() -> void:
	queue_free()
