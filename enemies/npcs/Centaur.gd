extends "res://enemies/npcs/GenericEnemy.gd"



func _ready():
	melee_range = 2
	rate_of_fire_seconds_per_shot = 1
	#DAMAGE_AMOUNT = 1


func respawn_or_disappear():
	queue_free()

