extends Node2D


#export (int) var player_health = 100 setget set_player_health
#export (int) var enemy_health = 100 setget set_enemy_health
var player_health = DbSystem.player_health
var enemy_health = DbSystem.enemy_health


func set_player_health(new_health: int):
	player_health = clamp(new_health, 0, DbSystem.player_health)
	
func set_enemy_health(new_health: int):
	enemy_health = clamp(new_health, 0, DbSystem.enemy_health)
