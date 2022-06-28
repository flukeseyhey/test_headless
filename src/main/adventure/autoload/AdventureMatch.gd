extends Node


enum AdventureMode {
	NONE = 0,
	LEVEL = 1,
	ENDLESS = 2,
}
var adventure_mode: int = AdventureMode.NONE setget _set_readonly_variable, get_adventure_mode


enum DifficultyLevel {
	EASY = 0,
	NORMAL = 1,
	HARD = 2,
}
var difficulty_level: int = DifficultyLevel.EASY setget _set_readonly_variable, get_difficulty_level


enum WinLoss {
	NONE = 0,
	WIN = 1,
	LOSS = 2
}
var win_loss: int = WinLoss.NONE setget _set_readonly_variable, get_win_loss


func _set_readonly_variable(_value) -> void:
	pass


func get_adventure_mode() -> int:
	return adventure_mode


func get_difficulty_level() -> int:
	return difficulty_level


func get_win_loss() -> int:
	return win_loss


func _on_set_adventure_mode(_mode):
	adventure_mode = _mode


func _on_set_difficulty_level(_level):
	difficulty_level = _level


func _on_set_win_loss(_win_loss):
	win_loss = _win_loss
