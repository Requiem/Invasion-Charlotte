extends Spatial

var Goblin = load("res://enemies/Goblin.tscn")


func _ready():
	spawn_enemies()
	
	
func _physics_process(delta):
	for object in get_tree().get_nodes_in_group("environment_objects"):
		var temp = Global.player_node.global_translation
		temp.y = 0
		object.look_at(temp, Vector3.UP)
	
	
func spawn_enemies():
	var spawn_point_list = get_tree().get_nodes_in_group("enemy_spawn_points") 
	for spawn_point in spawn_point_list:
		if spawn_point.spawning_is_enabled:
			spawn_goblin(spawn_point.translation)
	

func spawn_goblin(_position):
	var goblinInstance = Goblin.instance()
	goblinInstance.starting_pos = _position
	goblinInstance.translation = _position
	add_child(goblinInstance)
	goblinInstance.should_respawn = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func enable_spawn_points():
	for spawn_point in get_tree().get_nodes_in_group("enemy_spawn_points"):
		spawn_point.spawning_is_enabled = true


func _on_firstTV_tree_exited():
	enable_spawn_points()
	spawn_enemies()
