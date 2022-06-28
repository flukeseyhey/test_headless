extends KinematicBody2D

onready var TANK_COLORS = {
	1: {
		body_sprite = $BodySprite1,
		turret_sprite = $TurretPivot/TurretSprite1,
	},
	2: {
		body_sprite = $BodySprite2,
		turret_sprite = $TurretPivot/TurretSprite2,
	},
	3: {
		body_sprite = $BodySprite3,
		turret_sprite = $TurretPivot/TurretSprite3,
	},
	4: {
		body_sprite = $BodySprite4,
		turret_sprite = $TurretPivot/TurretSprite4,
	},
	5: {
		body_sprite = $BodySprite5,
		turret_sprite = $TurretPivot/TurretSprite5,
	},
	6: {
		body_sprite = $BodySprite6,
		turret_sprite = $TurretPivot/TurretSprite6,
	},
	7: {
		body_sprite = $BodySprite7,
		turret_sprite = $TurretPivot/TurretSprite7
	},
	8: {
		body_sprite = $BodySprite8,
		turret_sprite = $TurretPivot/TurretSprite8,
	},
	9: {
		body_sprite = $BodySprite9,
		turret_sprite = $TurretPivot/TurretSprite9,
	},
	10: {
		body_sprite = $BodySprite10,
		turret_sprite = $TurretPivot/TurretSprite10,
	},
}

onready var body_sprite := $Body/BodySprite1
onready var turret_sprite := $TurretPivot/Turret/TurretSprite1

onready var collision_shape := $CollisionShape2D
onready var turret_pivot := $TurretPivot
onready var bullet_start_position := $TurretPivot/BulletStartPosition


func set_tank_color(index: int) -> void:
	body_sprite = TANK_COLORS[index]['body_sprite']
	turret_sprite = TANK_COLORS[index]['turret_sprite']
	body_sprite.visible = true
	turret_sprite.visible = true

