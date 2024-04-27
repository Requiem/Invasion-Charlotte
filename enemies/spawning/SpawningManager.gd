
extends Node

const NUMBER_OF_SPAWN_POINTS_TO_ENABLE = 13
const TOTAL_NUMBER_OF_WAVES = 2

var Goblin = load("res://enemies/npcs/Goblin.tscn")
var Hornet = load("res://enemies/npcs/Hornet.tscn")
var Centaur = load("res://enemies/npcs/Centaur.tscn")
var HealthPack = load("res://pickups/HealthPack.tscn")
var SpawnTree = load("res://enemies/spawning/SpawnTree.tscn")

var new_spawn_point_random_chance = 0
var centaur_random_chance = 0
var hornet_random_chance = 0
var health_pack_random_chance = 0

const STARTING_SPAWN_POINTS = 4

const RANDOM_SPAWN_INC = 250
const CENTAUR_SPAWN_INC = 15
const HORNET_SPAWN_INC = 5
const HEALTH_PACK_INC = 200

onready var tree_spawn_point_list = get_tree().get_nodes_in_group("spawn_spawn_points") 
onready var all_spawn_point_list = get_tree().get_nodes_in_group("enemy_spawn_points")
onready var random_spawn_point_list = []
onready var health_pack_spawn_point_list = get_tree().get_nodes_in_group("health_pack_spawns")

var current_wave_num

signal WAVE_COMPLETE

func _ready():
	current_wave_num = 0
	_setup_arena()
	
	for _i in range(0, STARTING_SPAWN_POINTS):
		random_spawn_point_list.append(all_spawn_point_list.pop_front())
	

# setup arena with spawn points and enemies
func _setup_arena():
	print("debug about to enable spawn points")
	#var enemy_spawn_point_list = get_tree().get_nodes_in_group("enemy_spawn_points") 
	enable_tree_spawn_points()
	spawn_spawn_points()
	start_next_wave()
	#spawn_enemies(enemy_spawn_point_list)
	
	
func _physics_process(_delta):
	_make_sprites_face_the_player()


func _make_sprites_face_the_player():
	for object in get_tree().get_nodes_in_group("environment_objects"):
		var temp = Global.player_node.global_translation
		temp.y = 0
		object.get_node("Image").look_at(temp, Vector3.UP)


# this is where enemy waves are intialized	
func on_enemy_died():
	var enemies_list = get_tree().get_nodes_in_group("enemies") 
	print("debug, enemies_list_size: " + str(enemies_list.size()))
	if (enemies_list.size() == 1):
		print("debug, all enemies eliminated, starting next wave")
		#if (current_wave_num == TOTAL_NUMBER_OF_WAVES):
		#	on_all_waves_finished()
		#else:
		start_next_wave()
		

func start_next_wave():
	current_wave_num += 1
	health_pack_random_chance += HEALTH_PACK_INC
	
	var _enemy_spawn_point_list =  []#get_tree().get_nodes_in_group("enemy_spawn_points_wave_" + str(current_wave_num)) 
	
	if rand_range(new_spawn_point_random_chance, 1000) > 800:
		new_spawn_point_random_chance = 0
		random_spawn_point_list.append(all_spawn_point_list.pop_front())
	
	for node in random_spawn_point_list:
		if  rand_range(hornet_random_chance * current_wave_num, 1000) > 900:
			_enemy_spawn_point_list.append(["hornet", node])
			hornet_random_chance = 0
			centaur_random_chance += CENTAUR_SPAWN_INC
			
		elif rand_range(centaur_random_chance * current_wave_num, 1000) > 750:
			_enemy_spawn_point_list.append(["centaur", node])
			centaur_random_chance = 0
			hornet_random_chance += HORNET_SPAWN_INC
			
		else:
			_enemy_spawn_point_list.append(["goblin", node])
			centaur_random_chance += CENTAUR_SPAWN_INC
			hornet_random_chance += HORNET_SPAWN_INC
			
	if rand_range(health_pack_random_chance, 1000) > 750:
		health_pack_random_chance = 0;
		spawn_health_pack(health_pack_spawn_point_list[int(rand_range(0, len(health_pack_spawn_point_list) - 1))])
		
		
	
	enable_spawn_points(_enemy_spawn_point_list)
	spawn_enemies(_enemy_spawn_point_list)
	
		
# the end of the game
func on_all_waves_finished():
	print("debug, all enemies eliminated")
	get_tree().get_root().get_node("World/Player").show_instructions_for_reset()
		
	
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
		print("Spawn Point: ",spawn_point)
		if spawn_point[1].spawning_is_enabled:
			if (spawn_point[0] == "goblin"):
				print("debug, goblin spawning at " + str(spawn_point[1].global_translation))
				spawn_goblin(spawn_point[1].global_translation)
			elif (spawn_point[0] == "centaur"):
				print("debug, centaur spawning at " + str(spawn_point[1].global_translation))
				spawn_centaur(spawn_point[1].global_translation)
			elif (spawn_point[0] == "hornet"):
				print("debug, hornet spawning at " + str(spawn_point[1].global_translation))
				spawn_hornet(spawn_point[1].global_translation)

func spawn_centaur(_position):
	var centaurInstance = Centaur.instance()
	centaurInstance.starting_pos = _position
	centaurInstance.translation = _position
	call_deferred("add_child", centaurInstance)
	centaurInstance.should_respawn = true #TODO: should not respawn, right
	centaurInstance.add_to_group("enemies")
	centaurInstance.connect("enemy_died", self, "on_enemy_died")

func spawn_hornet(_position):
	var hornetInstance = Hornet.instance()
	hornetInstance.starting_pos = _position
	hornetInstance.translation = _position
	call_deferred("add_child", hornetInstance)
	hornetInstance.should_respawn = true #TODO: should not respawn, right
	hornetInstance.add_to_group("enemies")
	hornetInstance.connect("enemy_died", self, "on_enemy_died")
	

func spawn_goblin(_position):
	var goblinInstance = Goblin.instance()
	goblinInstance.starting_pos = _position
	goblinInstance.translation = _position
	call_deferred("add_child", goblinInstance)
	goblinInstance.should_respawn = true
	goblinInstance.add_to_group("enemies")
	goblinInstance.connect("enemy_died", self, "on_enemy_died")

func spawn_health_pack(_position):
	print("Spawning medpack")
	var t = _position.transform
	var healthInstance = HealthPack.instance()
	#healthInstance.starting_pos = _position
	#healthInstance.translation = 
	healthInstance.set_position(t)
	call_deferred("add_child", healthInstance)
	#healthInstance.should_respawn = true
	#healthInstance.add_to_group("enemies")
	#healthInstance.connect("enemy_died", self, "on_enemy_died")

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
		spawn_point[1].spawning_is_enabled = true


func _on_first_tv_destroyed():
	enable_first_wave()


func enable_first_wave():
	start_next_wave()
