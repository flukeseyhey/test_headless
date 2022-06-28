extends Area2D
class_name BulletOffline

var Explosion = preload("res://src/objects/Explosion.tscn")

var speed = DbSystem.bullet_speed


onready var kill_timer = $KillTimer


var direction := Vector2.ZERO
var team: int = -1


func _ready() -> void:
	kill_timer.start()


func _physics_process(delta: float) -> void:
	if direction != Vector2.ZERO:
		var velocity = direction * speed

		global_position += velocity

func explode(type: String):
	var explosion = Explosion.instance()
	explosion.set_as_toplevel(true)
	get_parent().add_child(explosion)
	explosion.setup(global_position, 0.5, type)

func set_direction(direction: Vector2):
	self.direction = direction
	rotation += direction.angle()


func _on_KillTimer_timeout() -> void:
	explode("smoke")
	queue_free()


func _on_Bullet_body_entered(body: Node) -> void:
	if body.has_method("handle_hit"):
		GlobalSignals.emit_signal("bullet_impacted", body.global_position, direction)
		if body.has_method("get_team") and body.get_team() != team:
			body.handle_hit()
		explode("fire")
	else:
		explode("smoke")
	queue_free()
