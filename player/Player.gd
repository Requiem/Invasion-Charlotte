extends KinematicBody

const MOVE_SPEED = 4
const MOUSE_SENS = 0.5
const gravity = 320

onready var anim_player = $AnimationPlayer
onready var raycast = $RayCast

onready var player_health = 5
var has_assault_rifle

signal gun_fired

func _ready():
	self.has_assault_rifle = false
	Global.player_node = self
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#yield(get_tree(), "idle_frame")
	#get_tree().call_group("zombies", "set_player", self)
	if (not  MusicController.get_node("Music").playing):
		MusicController.play_music()
	
		
func flash_instructions_for_reset():
	$HUDInstructionText.show()
	

func _input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y -= MOUSE_SENS * event.relative.x
		rotation_degrees.x -= MOUSE_SENS * event.relative.y
		
		# clip the vertical axis viewing so camera can't flip around vertically
		if rotation_degrees.x > 89:
			rotation_degrees.x = 89
		if rotation_degrees.x < -89:
			rotation_degrees.x = -89


func _process(delta):
	if Input.is_action_pressed("exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("restart"):
		Global.restartLevel()


func _physics_process(delta):
	var move_vec = Vector3()
	if Input.is_action_pressed("move_forwards"):
		move_vec.z -= 1
	if Input.is_action_pressed("move_backwards"):
		move_vec.z += 1
	if Input.is_action_pressed("move_left"):
		move_vec.x -= 1
	if Input.is_action_pressed("move_right"):
		move_vec.x += 1
	move_vec = move_vec.normalized()
	move_vec = move_vec.rotated(Vector3(0, 1, 0), rotation.y)
	move_and_collide(move_vec * MOVE_SPEED * delta)

	move_vec.y -= gravity * delta
	move_vec = move_and_slide(move_vec, Vector3.UP)
	
	if Input.is_action_pressed("shoot") and self.has_assault_rifle == true:
		anim_player.play("shoot")
		
		emit_signal("gun_fired")
		
		$crossbowSound.pitch_scale = rand_range(0.9,1.1)
		$crossbowSound.play()
		
		var coll = raycast.get_collider()
		if raycast.is_colliding() and coll.has_method("die"):
			raycast.get_collider().recieve_damage(raycast.get_collision_point())
	elif Input.is_action_pressed("shoot") and !anim_player.is_playing():
		anim_player.play("shoot")
		
		emit_signal("gun_fired")
		
		$crossbowSound.pitch_scale = rand_range(0.9,1.1)
		$crossbowSound.play()
		
		var coll = raycast.get_collider()
		if raycast.is_colliding() and coll.has_method("die"):
			raycast.get_collider().recieve_damage(raycast.get_collision_point())


func receive_damage():
	player_health -= 1
	
	if player_health == 4:
		$CanvasLayer/Heart5.hide()
	elif player_health == 3 :
		$CanvasLayer/Heart4.hide()
	elif player_health == 2:
		$CanvasLayer/Heart3.hide()
	elif player_health == 1:
		$CanvasLayer/Heart2.hide()
	elif player_health == 0:
		die()
		
		
func heal(amount):
	player_health += amount
	
	if player_health > 1:
		$CanvasLayer/Heart2.show()
	if player_health > 2 :
		$CanvasLayer/Heart3.show()
	if player_health > 3:
		$CanvasLayer/Heart4.show()
	if player_health > 5:
		$CanvasLayer/Heart5.show()
		player_health = 5

func die():
	$HUDInstructionText.hide() #TODO: does this need to be here?
	Global.player_node = null
	get_tree().reload_current_scene()
	queue_free()

