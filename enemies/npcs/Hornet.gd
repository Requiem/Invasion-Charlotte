extends "res://enemies/npcs/GenericEnemy.gd"


func _ready():
	is_flyer = true
	move_speed = 3.5


func respawn_or_disappear():
	queue_free()


# the hornet knows all
func player_is_detected():
	return true
