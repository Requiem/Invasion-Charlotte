
extends KinematicBody

var move_speed = 2
export var ACCELERATION_RATE = 0.1
export var RATE_OF_FIRE_SECONDS_PER_SHOT = 0.3
const HEIGHT_OF_PLAYER = Vector3(0, 1.5, 0) #TODO: is this correct?
const STARTING_HEALTH_POINTS = 3
const SMELLING_DISTANCE = 20
const MELEE_RANGE = 1

const NUM_DEATH_SOUNDS = 4

const gravity = 320

var player_node

signal enemy_died

#onready var raycast = $RayCast

var player = null
var dead = false
var starting_pos
var should_respawn
var is_flyer

###  AI code
var navAgent : NavigationAgent
var waypoint_index = 0
var actual_velocity : Vector3

export(NodePath) var waypoint_graph_node_path
onready var waypoint_graph = get_node_or_null(waypoint_graph_node_path)

var _previous_state
var _current_state
enum STATES {
	INIT,
	IDLE,
	PATROL,
	COMBAT,
	DECEASED
}

var can_hear
var can_see
var is_alerted

# state machine inputs
var has_just_been_alerted = false
var has_just_reached_destination = false
var has_reacted_to_attack = false

var num_health_points
var _enemy_position = null

###  AI Code







# Called when the node enters the scene tree for the first time.
func _ready():
	should_respawn = false
	player_node = Global.player_node
	
	#var anim_player = $AnimationPlayer
	#anim_player.play("Goblin")
	
	add_to_group("zombies")

	navAgent = $NavigationAgent
	if waypoint_graph and waypoint_graph.waypoint_list.size() > 0: 
		_add_next_waypoint_to_nav()

	
	_current_state = STATES.INIT
	num_health_points = STARTING_HEALTH_POINTS 
	_update_state_machine()


	_register_listener_for_player_gun_sounds()
	self.connect("enemy_died", player_node, "on_enemy_died")

		

func _update_state_machine():
	_previous_state = _current_state
	
	if _current_state == STATES.INIT:
		_current_state = STATES.IDLE
#		meshAnimationTree["parameters/conditions/idle"] = true
#		meshAnimationTree["parameters/conditions/walking"] = false
#		meshAnimationTree["parameters/conditions/alerted"] = false
		can_hear = true
		can_see = true

	elif _current_state == STATES.IDLE:
		can_see = true
		can_hear = true
		if num_health_points <= 0:
			_current_state = STATES.DECEASED
		elif has_just_been_alerted:
			_current_state = STATES.COMBAT
#			meshAnimationTree["parameters/conditions/alerted"] = true
#		elif waypoint_graph != null:
#			if waypoint_graph.waypoint_list.size() > 0:
#				_current_state = STATES.PATROL

	elif _current_state == STATES.PATROL:
#		meshAnimationTree["parameters/conditions/idle"] = false
#		meshAnimationTree["parameters/conditions/walking"] = true
#		meshAnimationTree["parameters/conditions/alerted"] = false
		can_hear = true
		can_see = true
		if num_health_points <= 0:
			_current_state = STATES.DECEASED
		elif has_just_been_alerted:
			_current_state = STATES.COMBAT

	elif _current_state == STATES.COMBAT:
		
		can_hear = true
		can_see = true
		if num_health_points <= 0:
			_current_state = STATES.DECEASED

	elif _current_state == STATES.DECEASED:
		can_hear = false
		can_see = false

	self.has_just_been_alerted = false


func _process(_delta):
	if ( ! is_instance_valid(player_node)):
		queue_free()
		return
		
	var _result = navAgent.get_next_location()
	_update_state_machine()
	_run_state_exit_events()
	_run_state_enter_events()
	_run_state_dependent_processes()
	#$Sprite3D.modulate = Color8(255, 255, 255)


func _run_state_exit_events():
	if _previous_state == STATES.COMBAT and _current_state != STATES.COMBAT:
		_exit_combat()
		_un_alert_the_npc()


func _un_alert_the_npc():
	is_alerted = false


func _exit_combat():
	stop_attacking()
	var _disconnect_result = $CombatReactionTimer.disconnect("timeout", self, "_start_attacking")
	$TargetTrackerTimer.disconnect("timeout", self, "track_target")


func stop_attacking():
	if $AttackTimer.is_connected("timeout", self, "_melee_attack"):
		$AttackTimer.disconnect("timeout", self, "_melee_attack")


func _melee_attack():
	if ( ! is_instance_valid(player_node)):
		queue_free()
		return
		
	player_node.receive_damage()
	print("debug Melee attacked ")
	pass


func _run_state_enter_events():	
	if _current_state == STATES.COMBAT and _previous_state != STATES.COMBAT:
		self.has_reacted_to_attack = false
		_alert_the_npc(player_node.global_transform.origin)
		_enter_combat()
	elif _current_state == STATES.DECEASED and _previous_state != STATES.DECEASED:
		#$PatrolTimer.disconnect("timeout", self, "_on_to_next_destination")
		_unregister_listener_for_player_gun_sounds()
		#_change_mesh_color(Color(0,0,0,1))
		#play_dying_animation()
		#EnemySoundController.play_next_death_sound()
		_remove_npc_from_player_collisions()
		#spawn_ammo()
		$ObliterationTimer.connect("timeout", self, "_fade_away")
		$ObliterationTimer.start()


func _remove_npc_from_player_collisions():
	collision_mask &= ~2
	collision_layer &= ~2
	

func _register_listener_for_player_gun_sounds():
	player_node.connect("gun_fired", self, "_react_to_gun_sound")


func _unregister_listener_for_player_gun_sounds():
	player_node.disconnect("gun_fired", self, "_react_to_gun_sound")


func _react_to_gun_sound():
#	if can_hear and Vector3(global_transform.origin - player_node.global_transform.origin).length() <= MAXIMUM_EARSHOT_DISTANCE * weapon_noise_level_ratio:
#		if ! is_alerted:
#			self.has_just_been_alerted = true
	if can_hear and ! is_alerted:
		self.has_just_been_alerted = true

func _enter_combat():
	if not $CombatReactionTimer.is_connected("timeout", self, "_start_attacking"):
		var _connect_result = $CombatReactionTimer.connect("timeout", self, "_start_attacking")
		$CombatReactionTimer.start()
	if not $TargetTrackerTimer.is_connected("timeout", self, "track_target"):
		var _connect_result = $TargetTrackerTimer.connect("timeout", self, "track_target")
		$TargetTrackerTimer.start()


func _start_attacking():
	self.has_reacted_to_attack = true


func track_target():
	if ( ! is_instance_valid(player_node)):
		queue_free()
		return
		
	self._enemy_position = player_node.global_translation
	navAgent.set_target_location(self._enemy_position)


func _alert_the_npc(position_of_interest):
	self._enemy_position = position_of_interest
	navAgent.set_target_location(position_of_interest)
	self.is_alerted = true


func _run_state_dependent_processes():
	if _current_state == STATES.IDLE:
		_notice_the_player_if_in_los()

	elif _current_state == STATES.PATROL:
		turn_towards_target(get_next_waypoint())
		_move_toward_waypoint(get_next_waypoint())
		_notice_the_player_if_in_los()

	elif _current_state == STATES.COMBAT:
		if self._enemy_position == null:
			print("Error: enemy_position is null")
		_notice_the_player_if_in_los()
		
		turn_towards_target(navAgent.get_next_location())	
		self._enemy_position = player_node.translation
		if player_is_visible() and self._enemy_position != null and self.has_reacted_to_attack and _is_within_attack_range():
			#meshAnimationTree["parameters/running/Blend2/blend_amount"] = 0.0
			attack()
		elif self.has_reacted_to_attack:
			stop_attacking()
			_move_toward_position(navAgent.get_next_location())

	elif _current_state == STATES.DECEASED:
		pass


func _is_within_attack_range():
	var distance_to_enemy = translation.distance_to(self._enemy_position)
	return distance_to_enemy < MELEE_RANGE


func _move_toward_position(target_pos):
#	var direction = global_transform.origin.direction_to(target_pos)
#	var final_velocity = direction * MOVE_SPEED
#	self.actual_velocity.x = lerp(self.actual_velocity.x, final_velocity.x, ACCELERATION_RATE)
#	self.actual_velocity.z = lerp(self.actual_velocity.z, final_velocity.z, ACCELERATION_RATE)
#
#	self.actual_velocity *= Vector3(1, 0, 1) # vector for feet on the ground
#	self.actual_velocity.y -= 4.0
#	var _move_result = move_and_slide(self.actual_velocity*10, Vector3.UP)
	#meshAnimationTree["parameters/running/Blend2/blend_amount"] = 1.0
	var vec_to_player = player_node.translation
	
	var direction = global_transform.origin.direction_to(vec_to_player)
	var final_velocity = direction * move_speed
	
	#vec_to_player = vec_to_player.normalized()
	self.look_at(player_node.translation, Vector3.UP)
	move_and_slide(final_velocity * move_speed)	
	

func attack():
	if not $AttackTimer.is_connected("timeout", self, "_melee_attack"):
		$AttackTimer.wait_time = RATE_OF_FIRE_SECONDS_PER_SHOT
		var _connect_result = $AttackTimer.connect("timeout", self, "_melee_attack")
		$AttackTimer.start()
	pass


func player_is_visible():
	var is_visible = false
	var overlaps = $VisionArea.get_overlapping_bodies()
	if overlaps.size() > 0:
		for overlap in overlaps:
			if overlap.name == "Player":
				$VisionRaycast.look_at(player_node.translation + HEIGHT_OF_PLAYER, Vector3.UP)
				$VisionRaycast.force_raycast_update()

				if ! grid_map_is_in_the_way(player_node.translation):
					if self._enemy_position == null:
						self._enemy_position = player_node.translation
					is_visible = true
				break
	else:
		is_visible = true

	return is_visible

# for firing projectiles
func grid_map_is_in_the_way(player_position):
	var space_state = get_world().direct_space_state
	var selection = space_state.intersect_ray($VisionRaycast.global_translation, player_position)
	return _map_selection(selection)


func _map_selection(selection):
	if selection.empty():
		return false
	else: 
		return selection["collider"] is GridMap
		

func get_next_waypoint():
	return waypoint_graph.waypoint_list[waypoint_index]


func _move_toward_waypoint(target_pos):
	if global_transform.origin.distance_to(target_pos) < 0.1:
		if not self.has_just_reached_destination:
			self.has_just_reached_destination = true
			$PatrolTimer.start()
		return
	
	_move_toward_position(target_pos)


func turn_towards_target(target_pos):
	self.look_at(player_node.translation, Vector3.UP)


func _notice_the_player_if_in_los():
	if can_see == true:
		if player_is_visible() and self._enemy_position != null:
			if ! self.is_alerted:
				self.has_just_been_alerted = true


func _add_next_waypoint_to_nav():
	waypoint_index += 1
	# reset waypoint index so it loops through the waypoints
	if waypoint_index >= waypoint_graph.waypoint_list.size():
		waypoint_index = 0


func _physics_process(delta):
	if ( ! is_instance_valid(player_node)):
		queue_free()
		return
		
	var vec_to_player = player_node.translation - translation
#	vec_to_player = vec_to_player.normalized()
#	self.look_at(player_node.translation, Vector3.UP)
	$Sprite3D.look_at(player_node.translation, Vector3.UP)

	if (player_node.translation.distance_to(translation) < SMELLING_DISTANCE):
		self.has_just_been_alerted = true
	
#	var vec_to_player = player.translation - translation
#	vec_to_player = vec_to_player.normalized()
#	raycast.cast_to = vec_to_player * 1.5
	
#	move_and_collide(vec_to_player * MOVE_SPEED * delta)

	if not is_flyer:
		var move_vec = Vector3()
		move_vec.y -= gravity * delta
		move_vec = move_and_slide(move_vec, Vector3.UP)

	if dead:
		return
	if player == null:
		return

#
#	if raycast.is_colliding():
#		var coll = raycast.get_collider()
#		if coll != null and coll.name == "Player":
#			pass
#			#coll.die()


func _fade_away():
	die()


func recieve_damage(collision_point):
	if _current_state != STATES.DECEASED:
		#if _is_headshot(collision_point):
		#	num_health_points = 0
		#else:		
		#	num_health_points -= 3
			
		num_health_points -= 3
		$Sprite3D.modulate = Color8(255, 0, 0)
		$DamageTimer.start()
		playtakedamagesound()
		
		
		if _current_state != STATES.COMBAT: #TODO: make independent of current state. timing could be off?
			if ! is_alerted:
				self.has_just_been_alerted = true
#		if num_health_points >= 0:
#			EnemySoundController.play_next_injury_sound()

func playtakedamagesound():
	pass


func die():
	dead = true
	$CollisionShape.disabled = true
#	anim_player.play("die")
	$ObliterationTimer.disconnect("timeout", self, "_fade_away")
	emit_signal("enemy_died")

	respawn_or_disappear()
	
	
# the death and respawn of enemies needs to be handled in the subclass	
func respawn_or_disappear():
	pass


		



func set_player(p):
	player = p

func _on_DamageTimer_timeout():
	$Sprite3D.modulate = Color8(255,255,255) 
