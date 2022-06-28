extends Area2D

onready var label := $Visual/OuterRect/InnerRect/Label
onready var outer_rect := $Visual/OuterRect
onready var collision_shape := $CollisionShape2D
onready var sound := $Sound

onready var itm_boost := $Visual/boost
onready var itm_invisible := $Visual/invisible
onready var itm_zap := $Visual/zap

onready var itm_railgun := $Visual/railgun
onready var itm_tracer := $Visual/tracer
onready var itm_spread := $Visual/spread
onready var itm_heal := $Visual/heal




export (String) var letter := "P" setget set_letter
export (Color) var color := Color('#00ff00') setget set_color

var _pickup




func _ready():
	$AnimationPlayer.play("shine")


func set_letter(_letter: String) -> void:
	if letter != _letter:
		letter = _letter
		if label == null:
			
			yield(self, "ready")
			
#######################โชว์รูปเวลาเก็บไอเท็ม##############################	
		
			if	letter == "B":
				itm_boost.show()
				
			if	letter == "I":
				itm_invisible.show()	
				
			if	letter == "Z":
				itm_zap.show()
			
			if	letter == "H":
				itm_heal.show()	
				
				
			if	letter == "T":
				itm_tracer.show()
				
			if	letter == "S":
				itm_spread.show()	
				
			if	letter == "R":
				itm_railgun.show()
				
			
				
####################################################################	
		
		label.text = _letter

func set_color(_color: Color) -> void:
	if label == null:
		yield(self, "ready")
	color = _color
	outer_rect.color = color
	label.add_color_override("font_color", color)

func setup_pickup(pickup) -> void:
	_pickup = pickup
	set_letter(pickup.letter)

func _on_Powerup_body_entered(body: PhysicsBody2D) -> void:
	if _pickup:
		_pickup.pickup(body)
	
	visible = false
	collision_shape.set_deferred("disabled", true)
	sound.play()

func _on_Sound_finished() -> void:
	queue_free()
