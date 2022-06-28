extends CanvasLayer

onready var title = $PanelContainer/MarginContainer/Rows/Body/FrameGame/Title
onready var money_win = $PanelContainer/MarginContainer/Rows/Win
onready var money_bonus = $PanelContainer/MarginContainer/Rows/Bonus
onready var money_lose = $PanelContainer/MarginContainer/Rows/Lose

var scene

func _exit_tree() -> void:
	queue_free()


func set_title(win: bool):
	Music.play("Over")
	
	if AdventureMatch.adventure_mode == AdventureMatch.AdventureMode.LEVEL:
		if win:
			title.text = "คุณชนะ!"
			title.modulate = Color.green
			
		else:
			title.text = "คุณแพ้!"
			title.modulate = Color.red
	else:
		title.text = "จบเกม!"
		title.modulate = Color.green

func set_message(win, bonus):
	money_win.visible = true
	money_bonus.visible = true
	money_lose.visible = false
	money_win.text = "ได้รับเงินเดิมพันคืน " + str(win) + " บาท"
#	money_bonus.text = "ได้รับเงินรางวัล  " + bonus + " บาท"
	money_bonus.text = "ได้รับเงินรางวัล " + str(bonus - (DbSystem.total_pay - DbSystem.money_bet)) + " บาท"
	

func set_endless_message(win):
	money_win.visible = false
	money_bonus.visible = true
	money_lose.visible = false
	money_bonus.text = "ได้รับเงินรางวัล " + str(win - DbSystem.total_pay) + " บาท"

func set_lose_message(message):
	money_win.visible = false
	money_bonus.visible = false
	money_lose.visible = true
	money_lose.text = message


func _on_MainMenuButton_pressed() -> void:
	Sounds.play("Select")
	Music.stop()
#	Music.play("Menu")
	DbSystem.reset_game_to_default()
	scene = get_tree().change_scene("res://src/main/title/MenuScreen.tscn")
#	var menu_scene = DbSystem.MenuScene.instance()
#	add_child(menu_scene)
