extends "res://src/components/weapons/BaseBullet.gd"

onready var ray_cast := $RayCast2D
onready var line := $Line2D


var speed = 2000
var growing := true
var bounced := false

const LASER_COLORS := {
	1: Color("bc0e00"),
	2: Color("00ff52"),
	3: Color("38ffde"),
	4: Color("00aeef"),
	5: Color("f7e322"),
	6: Color("d07130"),
	7: Color("ef67be"),
	8: Color("6c2fbc"),
	9: Color("ffffff"),
	10: Color("25a043"),
	
}

func _ready():
	line.set_as_toplevel(true)
	line.global_position = Vector2(0, 0)

func setup_bullet(tank, weapon_type) -> void:
	.setup_bullet(tank, weapon_type)
	
	line.default_color = LASER_COLORS[player_index]
	
	line.add_point(global_position)

func can_hit(body: PhysicsBody2D) -> bool:
	# Only allow to hit ourselves after the first bounce.
	return bounced or body != tank

func _physics_process(delta: float) -> void:
	if growing:
		var increment = vector * delta * speed
		ray_cast.cast_to = Vector2(increment.length(), 0)
		ray_cast.force_raycast_update()
		if ray_cast.is_colliding():
			global_position = ray_cast.get_collision_point()
			
			var collider = ray_cast.get_collider()
			# bit 2 = bullets
			if collider.get_collision_mask_bit(2):
				var collision_normal = ray_cast.get_collision_normal()
				if collision_normal != Vector2.ZERO:
					vector = vector.bounce(collision_normal).normalized()
					rotation = vector.angle()
					bounced = true
			
			ray_cast.clear_exceptions()
			ray_cast.add_exception(collider)
		else:
			global_position += increment
		
		line.add_point(global_position)
	else:
		line.remove_point(0)
		if line.points.size() == 0:
			queue_free()

func _on_LifetimeTimer_timeout() -> void:
	growing = false

