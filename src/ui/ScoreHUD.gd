extends PanelContainer


onready var animation = $AnimationPlayer

#onready var temp_node = $ScoreFrame/ScoreDisplay/SubBackground/MarginContainer/Row/Empty
#onready var temp_node_parent = $ScoreFrame/ScoreDisplay/SubBackground/MarginContainer/Row/Empty/EntityScore

var node_size
var score_array = []

enum ToggleButtonMode {
	HIDE = 0,
	SHOW = 1
}
var toggle_button_mode: int = ToggleButtonMode.SHOW setget _set_readonly_variable, get_toggle_button_mode


func _set_readonly_variable(_value) -> void:
	pass


func get_toggle_button_mode() -> int:
	return toggle_button_mode


func _on_set_toggle_button_mode(_mode):
	toggle_button_mode = _mode

# เรียงตามน้อยไปมาก
func sort_ascending(a, b):
	if a < b:
		return true
	return false

# เรียงตามมากไปน้อย
func sort_descending(a, b):
	if a > b:
		return true
	return false

func get_same_value(a, b):
	if a == b:
		return true
	return false


func update_medal() -> void:
	print("node_size : ", node_size)
	for i in range(1, node_size + 1):
		var score_node_parent = get_node("ScoreFrame/ScoreDisplay/SubBackground/MarginContainer/Row/Entity%s/EntityScore" % i)
		score_node_parent.set_medal_texture(i)


func _get_score_node(index: int):
	return get_node("ScoreFrame/ScoreDisplay/SubBackground/MarginContainer/Row/Entity%s/EntityScore" % index)


func set_entity_count(count: int) -> void:
	node_size = count
	for i in range(1, 11):
		var score_node_parent = get_node("ScoreFrame/ScoreDisplay/SubBackground/MarginContainer/Row/Entity%s" % i)
		assert(score_node_parent != null)
		if score_node_parent:
			score_node_parent.visible = (i <= count)


func hide_entity_score(index: int) -> void:
	var score_node_parent = get_node("ScoreFrame/ScoreDisplay/SubBackground/MarginContainer/Row/Entity%s/EntityScore" % index)
	assert(score_node_parent != null)
	if score_node_parent:
		score_node_parent.visible = false


func set_entity_name(index: int, name: String) -> void:
	var score_node = _get_score_node(index)
	assert(score_node != null)
	if score_node:
		score_node.set_entity_name(name)


remotesync func set_score(index: int, score: int) -> void:
	print("set_score : ", index)
	var score_node = _get_score_node(index)
	print ("score_node : ", score_node)
	assert(score_node != null)
	if score_node:
		score_node.set_score(score)


remotesync func set_highest_score(index: int) -> void:
	for i in range(1, node_size + 1):
		
#		print(node_size)
#		print(score_array)
		
		var score_node_parent = get_node("ScoreFrame/ScoreDisplay/SubBackground/MarginContainer/Row/Entity%s/EntityScore" % i)
		var score_point = score_node_parent.get_score()
		
		print("score_point : ", score_point)
		
		score_array.append(score_point)
	
	score_array.sort_custom(self, "sort_descending")
	
	var before_node = get_node("ScoreFrame/ScoreDisplay/SubBackground/MarginContainer/Row/Entity%s" % (index - 1))
	var before_node_parent = get_node("ScoreFrame/ScoreDisplay/SubBackground/MarginContainer/Row/Entity%s/EntityScore" % (index - 1))
	var score_node = get_node("ScoreFrame/ScoreDisplay/SubBackground/MarginContainer/Row/Entity%s" % index )
	var score_node_parent = get_node("ScoreFrame/ScoreDisplay/SubBackground/MarginContainer/Row/Entity%s/EntityScore" % index)
	
	var score_point = score_node_parent.get_score()

	if score_point == score_array[0]:
		if not before_node:
			return
		else:
			before_node.remove_child(before_node_parent)
			score_node.add_child(before_node_parent)
			score_node.move_child(before_node_parent, 0)
			
			score_node.remove_child(score_node_parent)
			before_node.add_child(score_node_parent)
			before_node.move_child(score_node_parent, 0)
				
	score_array = []

func _on_HideButton_pressed():
	match toggle_button_mode:
		ToggleButtonMode.HIDE:
			animation.play("show")
			_on_set_toggle_button_mode(ToggleButtonMode.SHOW)
		ToggleButtonMode.SHOW:
			animation.play("hide")
			_on_set_toggle_button_mode(ToggleButtonMode.HIDE)
