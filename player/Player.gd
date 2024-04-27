extends KinematicBody

const MOVE_SPEED = 4
const MOUSE_SENS = 0.5
const gravity = 320

onready var anim_player = $AnimationPlayer
onready var raycast = $RayCast
onready var particles = $CanvasLayer/Control/Particles2D

onready var weapon_thumbs = {"firewand" : load("res://assets/weapons/firewandThumb.png") }

export var  player_health = 5
var equipped_weapon
var weapons = []

signal gun_fired

func _ready():
	self.equipped_weapon = 0
	self.weapons.append("crossbow")
	Global.player_node = self
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# this has to do with the music playing when the player dies, but not restarting the music
	if (not  MusicController.get_node("Music").playing):
		MusicController.play_music()


func show_instructions_for_reset():
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


func _process(_delta):
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
	var _result = move_and_collide(move_vec * MOVE_SPEED * delta)

	move_vec.y -= gravity * delta
	move_vec = move_and_slide(move_vec, Vector3.UP)

	if self.weapons[equipped_weapon] == "firewand":
		if Input.is_action_pressed("shoot"):
			anim_player.play("shoot")
			
			emit_signal("gun_fired")

			$CanvasLayer/Control/FireWand.set_offset(Vector2(rand_range(-5,5),rand_range(-5,5)))

			particles.emitting = true

			$crossbowSound.pitch_scale = rand_range(0.9,1.1)
			$crossbowSound.play()

			var coll = raycast.get_collider()
			if raycast.is_colliding() and coll.has_method("die"):
				raycast.get_collider().recieve_damage()
		else:
			anim_player.play("idle")
			particles.emitting = false
			$CanvasLayer/Control/FireWand.set_offset(Vector2(0,0))

	elif Input.is_action_pressed("shoot") and !anim_player.is_playing() and self.weapons[equipped_weapon] == "crossbow":
		anim_player.play("shoot")

		emit_signal("gun_fired")

		$crossbowSound.pitch_scale = rand_range(0.9,1.1)
		$crossbowSound.play()

		var coll = raycast.get_collider()
		if raycast.is_colliding() and coll.has_method("die"):
			raycast.get_collider().recieve_damage()

	if Input.is_action_just_pressed("swapWeapon"):
		particles.emitting = false
		if len(weapons) > 1:
			if equipped_weapon == 0:
				self.equip(1)
			else:
				self.equip(0)


func equip(slot):
	self.equipped_weapon = slot
	
	if equipped_weapon == 0:
		$CanvasLayer/Selector.set_offset(Vector2(0,0))
	else:
		$CanvasLayer/Selector.set_offset(Vector2(30,0))

	match weapons[equipped_weapon]:
		"crossbow":
			$CanvasLayer/Control/Crossbow.visible = true
			$CanvasLayer/Control/FireWand.visible = false
		"firewand":
			$CanvasLayer/Control/Crossbow.visible = false
			$CanvasLayer/Control/FireWand.visible = true

	anim_player.play("idle")


func pickup_weapon(slot, name):
	if slot == 0:
		$CanvasLayer/Thumb1.set_texture(weapon_thumbs[name])
	elif slot == 1:
		$CanvasLayer/Thumb2.set_texture(weapon_thumbs[name])


func receive_damage(amt):
	player_health -= amt

	if player_health < 5:
		$CanvasLayer/Heart5.hide()
	if player_health < 4 :
		$CanvasLayer/Heart4.hide()
	if player_health < 3:
		$CanvasLayer/Heart3.hide()
	if player_health < 2:
		$CanvasLayer/Heart2.hide()
	if player_health < 1:
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
	
	get_tree().change_scene("res://Menus/GameOver.tscn")
	#var _result = get_tree().reload_current_scene()
	queue_free()
