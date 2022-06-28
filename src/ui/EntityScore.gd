extends PanelContainer

const RANK_1 = preload("res://assets/leaderboard/rank_1.png")
const RANK_2 = preload("res://assets/leaderboard/rank_2.png")
const RANK_3 = preload("res://assets/leaderboard/rank_3.png")
const RANK_4 = preload("res://assets/leaderboard/rank_4.png")
const RANK_5 = preload("res://assets/leaderboard/rank_5.png")
const RANK_6 = preload("res://assets/leaderboard/rank_6.png")
const RANK_7 = preload("res://assets/leaderboard/rank_7.png")
const RANK_8 = preload("res://assets/leaderboard/rank_8.png")
const RANK_9 = preload("res://assets/leaderboard/rank_9.png")
const RANK_10 = preload("res://assets/leaderboard/rank_10.png")

onready var entity_name_label = $MarginContainer/VBoxContainer/NameLabel
onready var entity_score_label = $MarginContainer/VBoxContainer/ScoreLabel
onready var entity_medal = $MarginContainer/VBoxContainer/Medal

var rank_medal = [RANK_1, RANK_2, RANK_3, RANK_4, RANK_5, RANK_6, RANK_7, RANK_8, RANK_9, RANK_10]

func set_entity_name(name: String) -> void:
	entity_name_label.text = name

func set_score(score: int) -> void:
	entity_score_label.text = str(score)

func get_score():
	var score = int(entity_score_label.text)
	return score

func set_medal_texture(_index) -> void:
	var path_texture
	
	for i in range(0, _index):
		path_texture = rank_medal[i]
	
	entity_medal.set_texture(path_texture)
