extends "res://enemies/npcs/GenericEnemy.gd"



func _ready():
	move_speed = 3
	melee_range = 2
	rate_of_fire_seconds_per_shot = 1


func respawn_or_disappear():
	queue_free()

