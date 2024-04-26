extends "res://enemies/npcs/GenericEnemy.gd"

var tv_spawn_node


# Called when the node enters the scene tree for the first time.
func _ready():
	rate_of_fire_seconds_per_shot = 1


func die():
	.die()
	
	if (tv_spawn_node != null and ! is_instance_valid(tv_spawn_node)):
		queue_free()
	elif ( ! should_respawn):
		queue_free()
	else:
		respawn()


func respawn():	
	if (tv_spawn_node != null and is_instance_valid(tv_spawn_node)):
		tv_spawn_node.spawn()
		queue_free()
	else:		
		$CollisionShape.disabled = false
		translation = starting_pos
		dead = false

		_current_state = STATES.INIT
		num_health_points = STARTING_HEALTH_POINTS
		_register_listener_for_player_gun_sounds()


func playtakedamagesound():
	play_random_death_noise()


func play_random_death_noise():
	randomize()
	var randomIndex = (randi() % NUM_DEATH_SOUNDS) + 1
	get_node("GoblinDamageSound" + str(randomIndex)).play()
