extends "res://enemies/GenericEnemy.gd"


func _ready():
	is_flyer = true
	move_speed = 3.5


func respawn_or_disappear():
	queue_free()
