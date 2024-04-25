
extends Node

const NUMBER_OF_SPAWN_POINTS_TO_ENABLE = 13
const TOTAL_NUMBER_OF_WAVES = 1

var Goblin = load("res://enemies/Goblin.tscn")
var SpawnTree = load("res://SpawnTree.tscn")
#onready var enemy_spawn_point_list = get_tree().get_nodes_in_group("enemy_spawn_points") 
onready var tree_spawn_point_list = get_tree().get_nodes_in_group("spawn_spawn_points") 
var current_wave_num

func _ready():
	_setup_arena()
	current_wave_num = 0
	

func _setup_arena():
	print("debug about to enable spawn points")
	var enemy_spawn_point_list = get_tree().get_nodes_in_group("enemy_spawn_points") 
	enable_tree_spawn_points()
	spawn_spawn_points()
	spawn_enemies(enemy_spawn_point_list)
	
	
func _physics_process(delta):
	for object in get_tree().get_nodes_in_group("environment_objects"):
		var temp = Global.player_node.global_translation
		temp.y = 0
		object.look_at(temp, Vector3.UP)
	for object in get_tree().get_nodes_in_group("enemies"):
		var temp = Global.player_node.global_translation
		temp.y = 0
		object.look_at(temp, Vector3.UP)

	
func on_enemy_died():
	var enemies_list = get_tree().get_nodes_in_group("enemies") 
	if (enemies_list.size() == 1):
		print("debug, all enemies eliminated, starting next wave")
		if (current_wave_num == TOTAL_NUMBER_OF_WAVES-1):
			on_all_waves_finished()
		else:
			start_next_wave()
		

func start_next_wave():
	current_wave_num += 1
	var _enemy_spawn_point_list = get_tree().get_nodes_in_group("enemy_spawn_points_wave_" + str(current_wave_num)) 
	enable_spawn_points(_enemy_spawn_point_list)
	spawn_enemies(_enemy_spawn_point_list)
	
		
func on_all_waves_finished():
	print("debug, all enemies eliminated")
	get_tree().get_root().get_node("World/Player").flash_instructions_for_reset()
		
	
func spawn_spawn_points():
	for spawn_point in tree_spawn_point_list:
		if spawn_point.spawning_is_enabled:
			spawn_tree(spawn_point.translation)
	

func spawn_tree(_position):
	var treeInstance = SpawnTree.instance()
	add_child(treeInstance)
	treeInstance.translation = _position
	
	
func spawn_enemies(_enemy_spawn_point_list):
	for spawn_point in _enemy_spawn_point_list:
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
	goblinInstance.connect("enemy_died", self, "on_enemy_died")


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


func enable_spawn_points(_enemy_spawn_point_list):
	for spawn_point in _enemy_spawn_point_list:
		spawn_point.spawning_is_enabled = true


func _on_first_tv_destroyed():
	enable_first_wave()


func enable_first_wave():
	var _enemy_spawn_point_list = get_tree().get_nodes_in_group("enemy_spawn_points") 
	enable_spawn_points(_enemy_spawn_point_list)
	spawn_enemies(_enemy_spawn_point_list)

