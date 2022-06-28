extends Control

onready var title_label := $FindMatch
onready var title_timer := $Timer
onready var animation := $AnimationPlayer

signal start_match_finished ()
signal show_player()
#signal show_second(text)

var match_end_time = 0


func _ready() -> void:
	OnlineMatch.connect("start_match_countdown", self, "_start_match_countdown")
	OnlineMatch.connect("stop_match_countdown", self, "_stop_match_countdown")
	animation.play("pic_find_match")

# ========================================================= AUTO START MATCH

func _stop_match_countdown() -> void:
	title_timer.stop()
	animation.play("pic_find_match")
	
func _start_match_countdown(seconds: int) -> void:
	if seconds <= 0:
		return
	match_end_time = OS.get_system_time_secs() + seconds
	title_timer.start()
	_update_label()
	title_label.visible = true

func _update_label():
	var seconds_remaining: int = match_end_time - OS.get_system_time_secs()
	rpc("_update_remote_label", seconds_remaining)

remotesync func _update_remote_label(seconds_remaining: int) -> void:
	if seconds_remaining < 0:
		title_label.visible = false
		title_timer.stop()
		if is_network_master():
			emit_signal("start_match_finished")
	elif seconds_remaining == 3:
		emit_signal("show_player")
	elif seconds_remaining == 4:
		animation.stop()
	else:
		title_label.visible = true
		
	var seconds = seconds_remaining % 60
#	emit_signal("show_second", "เกมจะเริ่มใน " + str(seconds).pad_zeros(2) + " วินาที")
#	title_label.text = "เกมจะเริ่มใน " + str(seconds).pad_zeros(2) + " วินาที"

func _on_Timer_timeout() -> void:
	_update_label()
