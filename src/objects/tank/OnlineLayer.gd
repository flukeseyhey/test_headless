extends CanvasLayer


signal normal_shoot()
signal railgun_shoot()
signal tracer_shoot()
signal spread_shoot()

signal skill_boost_press()
signal skill_zap_press()
signal skill_invisible_press()


func _on_Normal_pressed():
	emit_signal("normal_shoot")


func _on_Railgun_pressed():
	emit_signal("railgun_shoot")


func _on_Tracer_pressed():
	emit_signal("tracer_shoot")


func _on_Spread_pressed():
	emit_signal("spread_shoot")


func _on_Boost_pressed():
	emit_signal("skill_boost_press")


func _on_Zap_pressed():
	emit_signal("skill_zap_press")


func _on_Invisible_pressed():
	emit_signal("skill_invisible_press")
