extends "res://enemies/npcs/GenericEnemy.gd"



func _ready():
	move_speed = 3
	melee_range = 3
	rate_of_fire_seconds_per_shot = 0.1


func respawn_or_disappear():
	queue_free()

