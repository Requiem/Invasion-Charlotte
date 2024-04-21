extends Node


var player_node


func restartLevel():
	print("debug, restarting level")
	var _result = get_tree().reload_current_scene()
