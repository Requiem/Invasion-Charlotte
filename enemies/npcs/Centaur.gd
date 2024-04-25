extends "res://enemies/npcs/GenericEnemy.gd"



func _ready():
	move_speed = 3


func respawn_or_disappear():
	queue_free()

