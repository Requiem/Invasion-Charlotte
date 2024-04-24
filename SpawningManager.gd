
extends Node

var NUMBER_OF_SPAWN_POINTS_TO_ENABLE = 13

var Goblin = load("res://enemies/Goblin.tscn")
var SpawnTree = load("res://SpawnTree.tscn")
onready var enemy_spawn_point_list = get_tree().get_nodes_in_group("enemy_spawn_points") 
onready var tree_spawn_point_list = get_tree().get_nodes_in_group("spawn_spawn_points") 


func _ready():
	print("debug about to enable spawn points")
	enable_tree_spawn_points()
	spawn_spawn_points()
	spawn_enemies()
	
	
func _physics_process(delta):
	for object in get_tree().get_nodes_in_group("environment_objects"):
		var temp = Global.player_node.global_translation
		temp.y = 0
		object.look_at(temp, Vector3.UP)
	for object in get_tree().get_nodes_in_group("enemies"):
		var temp = Global.player_node.global_translation
		temp.y = 0
		object.look_at(temp, Vector3.UP)

	
	
func spawn_spawn_points():
	for spawn_point in tree_spawn_point_list:
		if spawn_point.spawning_is_enabled:
			spawn_tree(spawn_point.translation)
	

func spawn_tree(_position):
	var treeInstance = SpawnTree.instance()
	add_child(treeInstance)
	treeInstance.translation = _position
	
	
func spawn_enemies():
	for spawn_point in enemy_spawn_point_list:
		if spawn_point.spawning_is_enabled:
			print(str(spawn_point.global_translation))
			spawn_goblin(spawn_point.global_translation)
	

func spawn_goblin(_position):
	var goblinInstance = Goblin.instance()
	goblinInstance.starting_pos = _position
	goblinInstance.translation = _position
	call_deferred("add_child", goblinInstance)
	goblinInstance.should_respawn = true
	goblinInstance.add_to_group("enemies")


func enable_tree_spawn_points():
	var indexes_to_spawn_trees = pickRandomIndexes(tree_spawn_point_list, NUMBER_OF_SPAWN_POINTS_TO_ENABLE)
	print("debug inside enable_tree_spawn_points")
	for spawn_point_index in indexes_to_spawn_trees:
		tree_spawn_point_list[spawn_point_index].spawning_is_enabled = true
		
		
func pickRandomIndexes(list: Array, N: int) -> Array:
	var randomIndexes = []
	var listSize = list.size()

	# Ensure N does not exceed the size of the list
	N = min(N, listSize)


	# Pick random indexes
	while randomIndexes.size() < N:
		randomize()
		var rand = randi()
		var randomIndex = rand % listSize
		if ( ! randomIndexes.has(randomIndex)):
			randomIndexes.append(randomIndex)

	return randomIndexes


func enable_spawn_points():
	for spawn_point in enemy_spawn_point_list:
		spawn_point.spawning_is_enabled = true


func _on_first_tv_destroyed():
	enable_first_wave()


func enable_first_wave():
	enemy_spawn_point_list = get_tree().get_nodes_in_group("enemy_spawn_points") 
	enable_spawn_points()
	spawn_enemies()

