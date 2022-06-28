extends TextureRect


signal select_money()


func _on_1_pressed():
	get_parent().get_parent().get_node("AdventureMode/BetSetup/Money/Label").text = "1"
	emit_signal("select_money")


func _on_2_pressed():
	get_parent().get_parent().get_node("AdventureMode/BetSetup/Money/Label").text = "2"
	emit_signal("select_money")


func _on_5_pressed():
	get_parent().get_parent().get_node("AdventureMode/BetSetup/Money/Label").text = "5"
	emit_signal("select_money")


func _on_10_pressed():
	get_parent().get_parent().get_node("AdventureMode/BetSetup/Money/Label").text = "10"
	emit_signal("select_money")
