extends Area2D

onready var animation = $AnimationPlayer

var time = 0

enum CoinEnterState {
	NONE = 0,
	PLAYER = 1,
	OBSTACLES = 2
}
var coin_enter_state: int = CoinEnterState.NONE setget _set_readonly_variable, get_coin_enter_state


func _set_readonly_variable(_value) -> void:
	pass


func get_coin_enter_state() -> int:
	return coin_enter_state


func _on_set_coin_enter_state(_state):
	coin_enter_state = _state


func _ready():
	animation.play("coinbouncing")
	position.y += rand_range(-100, 100)
	position.x += rand_range(-100, 100)

func _process(delta):
	
	time += delta
	
	if coin_enter_state == CoinEnterState.OBSTACLES:
		position.x -= rand_range(-10, 10) * delta
		position.y -= rand_range(-10, 10) * delta
		
#		_on_set_coin_enter_state(CoinEnterState.NONE)
	
		if int(time) % 5 == 0:
			_on_set_coin_enter_state(CoinEnterState.NONE)


func _on_VisibilityNotifier2D_screen_exited() -> void:
	queue_free()


func _on_Coin_body_entered(body):
	var bronze = DbSystem.bronze
	var bronze_value = DbSystem.money_bronze_coin_value
	
	var silver = DbSystem.silver
	var silver_value = DbSystem.money_silver_coin_value
	
	var gold = DbSystem.gold
	var gold_value = DbSystem.money_gold_coin_value

	if body.is_in_group("player"):
		if RachaAPI.is_show_debug: 
			print("coin in player")
		_on_set_coin_enter_state(CoinEnterState.PLAYER)
		var node_name = self.get_name()
		
		match AdventureMatch.adventure_mode:
			AdventureMatch.AdventureMode.LEVEL:
				
				if AdventureMatch.difficulty_level == AdventureMatch.DifficultyLevel.EASY:
					bronze_value = bronze_value * DbSystem.money_bet * DbSystem.easy_mode_difficulty_multiple
					silver_value = silver_value * DbSystem.money_bet * DbSystem.easy_mode_difficulty_multiple
					gold_value = gold_value * DbSystem.money_bet * DbSystem.easy_mode_difficulty_multiple
				elif AdventureMatch.difficulty_level == AdventureMatch.DifficultyLevel.NORMAL:
					bronze_value = bronze_value * DbSystem.money_bet * DbSystem.normal_mode_difficulty_multiple
					silver_value = silver_value * DbSystem.money_bet * DbSystem.normal_mode_difficulty_multiple
					gold_value = gold_value * DbSystem.money_bet * DbSystem.normal_mode_difficulty_multiple
				else:
					bronze_value = bronze_value * DbSystem.money_bet * DbSystem.hard_mode_difficulty_multiple
					silver_value = silver_value * DbSystem.money_bet * DbSystem.hard_mode_difficulty_multiple
					gold_value = gold_value * DbSystem.money_bet * DbSystem.hard_mode_difficulty_multiple
					
				
				if node_name.begins_with("B") or node_name.begins_with("@B"):
					DbSystem.money_gain += stepify(bronze * bronze_value, 0.01)
					if RachaAPI.is_show_debug: 
						print("Bronze cound value : ", stepify(bronze * bronze_value, 0.01))
					
				elif node_name.begins_with("S") or node_name.begins_with("@S"):
					DbSystem.money_gain += stepify(silver * silver_value, 0.01)
					if RachaAPI.is_show_debug: 
						print("Silver cound value : ", stepify(silver * silver_value, 0.01))
					
				else:
					DbSystem.money_gain += stepify(gold * gold_value, 0.01)
					if RachaAPI.is_show_debug: 
						print("Gold cound value : ", stepify(gold * gold_value, 0.01))
					
					
			AdventureMatch.AdventureMode.ENDLESS:

				if DbSystem.endless_kill_count <= 3:
					bronze_value = bronze_value * 0.5 * DbSystem.money_bet
					silver_value = silver_value * 0.5 * DbSystem.money_bet
					gold_value = gold_value * 0.5 * DbSystem.money_bet
				elif DbSystem.endless_kill_count > 3 and DbSystem.endless_kill_count <= 7:
					bronze_value = bronze_value * 0.75 * DbSystem.money_bet
					silver_value = silver_value * 0.75 * DbSystem.money_bet
					gold_value = gold_value * 0.75 * DbSystem.money_bet
				elif DbSystem.endless_kill_count > 7 and DbSystem.endless_kill_count <= 12:
					bronze_value =  bronze_value * 1.0 * DbSystem.money_bet
					silver_value =  silver_value * 1.0 * DbSystem.money_bet
					gold_value =  gold_value * 1.0 * DbSystem.money_bet
				elif DbSystem.endless_kill_count > 12 and DbSystem.endless_kill_count <= 16:
					bronze_value =  bronze_value * 1.25 * DbSystem.money_bet
					silver_value =  silver_value * 1.25 * DbSystem.money_bet
					gold_value =  gold_value * 1.25 * DbSystem.money_bet
				else:
					bronze_value =  bronze_value * 1.50 * DbSystem.money_bet
					silver_value =  silver_value * 1.50 * DbSystem.money_bet
					gold_value =  gold_value * 1.5 * DbSystem.money_bet
				
				if node_name.begins_with("B") or node_name.begins_with("@B"):
					DbSystem.money_gain += stepify(bronze * bronze_value, 0.01)
					if RachaAPI.is_show_debug: 
						print("Bronze cound value : ", stepify(bronze * bronze_value, 0.01))
					
				elif node_name.begins_with("S") or node_name.begins_with("@S"):
					DbSystem.money_gain += stepify(silver * silver_value, 0.01)
					if RachaAPI.is_show_debug: 
						print("Silver cound value : ", stepify(silver * silver_value, 0.01))
					
				else:
					DbSystem.money_gain += stepify(gold * gold_value, 0.01)
					if RachaAPI.is_show_debug: 
						print("Gold cound value : ", stepify(gold * gold_value, 0.01))
		
		GlobalSignals.emit_signal("update_gain_money")
		Sounds.play("Coin")
		queue_free()
	
	else:
		if RachaAPI.is_show_debug: 
			print("coin in obstacles")
		_on_set_coin_enter_state(CoinEnterState.OBSTACLES)



