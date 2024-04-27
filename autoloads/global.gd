extends Node


var player_node
var score = 0


func restartLevel():
	print("debug, restarting level")
	var _result = get_tree().reload_current_scene()
