extends "res://enemies/npcs/GenericEnemy.gd"


func _ready():
	is_flyer = true
	move_speed = 3.5
	rate_of_fire_seconds_per_shot = 1
	min_attack_range = 1.5

func respawn_or_disappear():
	queue_free()


# the hornet knows all
func player_is_detected():
	return true
