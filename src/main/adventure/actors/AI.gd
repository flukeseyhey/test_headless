extends Node2D
class_name AI


signal state_changed(new_state)


enum State {
	NONE,
	PATROL,
	ENGAGE,
	ADVANCE
}


export (bool) var should_draw_path_line := false


onready var patrol_timer = $PatrolTimer
onready var path_line = $PathLine
onready var collision_shape = $DetectionZone/CollisionShape2D


var current_state: int = -1 setget set_state
var actor: ActorOffline = null
var target: KinematicBody2D = null
var weapon: Weapon = null
var team: int = -1

# PATROL STATE
var origin: Vector2 = Vector2.ZERO
var patrol_location: Vector2 = Vector2.ZERO
var patrol_location_reached: bool = false
var actor_velocity: Vector2 = Vector2.ZERO

# ADVANCE STATE
var next_base: Vector2 = Vector2.ZERO

var pathfinding: Pathfinding


func _ready() -> void:
	GlobalSignals.connect("set_team", self, "player_update_team")
	set_state(State.PATROL)
	path_line.visible = should_draw_path_line


func _physics_process(delta: float) -> void:
	path_line.global_rotation = 0
	
	match current_state:
		State.PATROL:
			if not patrol_location_reached:
				var path = pathfinding.get_new_path(global_position, patrol_location)
				if path.size() > 1:
					actor_velocity = actor.velocity_toward(path[1])
					actor.rotate_toward(path[1])
					actor.move_and_slide(actor_velocity)
					set_path_line(path)
				else:
					patrol_location_reached = true
					actor_velocity = Vector2.ZERO
					patrol_timer.start()
					path_line.clear_points()
		State.ENGAGE:
			if target != null and weapon != null:
				patrol_location_reached = true
				path_line.clear_points()
				actor.rotate_toward(target.global_position)
				if abs(actor.global_position.angle_to(target.global_position)) < 0.1 :
					weapon.shoot()
					actor_velocity = actor.velocity_toward(target.global_position)
					actor.move_and_slide(actor_velocity / 1.25)
				else:
					weapon.shoot()
					actor_velocity = actor.velocity_toward(target.global_position)
					actor.move_and_slide(actor_velocity / 1.25)
					
			else:
				if RachaAPI.is_show_debug: 
					print("In the engage state but no weapon/target")
		State.ADVANCE:
			var path = pathfinding.get_new_path(global_position, next_base)
			if path.size() > 1:
				actor_velocity = actor.velocity_toward(path[1])
				actor.rotate_toward(path[1])
				actor.move_and_slide(actor_velocity)
				set_path_line(path)
			else:
				set_state(State.PATROL)
				path_line.clear_points()
		_:
			if RachaAPI.is_show_debug: 
				print("Error: found a state for our enemy that should not exist")
			


func initialize(actor: KinematicBody2D, weapon: Weapon, team: int):
	self.actor = actor
	self.weapon = weapon
	self.team = team

	weapon.connect("weapon_out_of_ammo", self, "handle_reload")


func set_path_line(points: Array):
	if not should_draw_path_line:
		return

	var local_points := []
	for point in points:
		if point == points[0]:
			local_points.append(Vector2.ZERO)
		else:
			local_points.append(point - global_position)

	path_line.points = local_points


func set_state(new_state: int):
	if new_state == current_state:
		return

	if new_state == State.PATROL:
		origin = global_position
		patrol_timer.start()
		patrol_location_reached = true

	elif new_state == State.ADVANCE:
		if actor.has_reached_position(next_base):
			set_state(State.PATROL)

	current_state = new_state
	emit_signal("state_changed", current_state)

func player_update_team(boolean) -> void:
	if boolean:
#		_on_DetectionZone_body_exited(target)
		collision_shape.shape.radius = 50
#		set_state(State.PATROL)
	else:
		collision_shape.shape.radius = 325
#		set_state(State.ENGAGE)

func handle_reload():
	weapon.start_reload()


func _on_PatrolTimer_timeout() -> void:
	var patrol_range = 400
	var random_x = rand_range(-patrol_range, patrol_range)
	var random_y = rand_range(-patrol_range, patrol_range)
	patrol_location = Vector2(random_x, random_y) + origin
	patrol_location_reached = false


func _on_DetectionZone_body_entered(body: Node) -> void:
	if current_state != State.NONE:
		if body.has_method("get_team") and body.get_team() != team:
			set_state(State.ENGAGE)
			target = body


func _on_DetectionZone_body_exited(body: Node) -> void:
	if current_state != State.NONE:
		if target and body == target:
			set_state(State.PATROL)
			target = null
