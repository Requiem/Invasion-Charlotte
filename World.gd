extends Spatial

var Goblin = load("res://Goblin.tscn")


func _ready():
	spawn_enemies()
	
	
func _physics_process(delta):
	for tree in get_tree().get_nodes_in_group("trees"):
		tree.look_at(Global.player_node.global_translation, Vector3.UP)
	

func spawn_enemies():
	for spawn_point in get_tree().get_nodes_in_group("enemy_spawn_points"):
		spawn_goblin(spawn_point.translation)
	

func spawn_goblin(_position):
	var goblinInstance = Goblin.instance()
	goblinInstance.translation = _position
	add_child(goblinInstance)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
