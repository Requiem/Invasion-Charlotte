extends Node

var Goblin = load("res://enemies/npcs/Goblin.tscn")
var GoblinSprite = load("res://assets/enemies/goblin1.png")
const TELEVISION_IMAGE_GROW_DURATION = 2
const INITIAL_TV_IMAGE_SIZE = 0.005
const FINAL_TV_IMAGE_SIZE = 0.015
var is_spawning = false

onready var SpawningManager = get_tree().get_root().get_node("World/SpawningManager")

var health_points = 10

signal television_destroyed

# Called when the node enters the scene tree for the first time.
func _ready():
	var _result = $shrinkGrowTimer.connect("timeout", self, "_jump_out_of_tv")
	$shrinkGrowTimer.wait_time = TELEVISION_IMAGE_GROW_DURATION
	_result = self.connect("television_destroyed", SpawningManager, "_on_first_tv_destroyed")


func _jump_out_of_tv():
	_remove_tv_image()
	var goblinInstance = Goblin.instance()
	goblinInstance.tv_spawn_node = self
	get_tree().get_root().add_child(goblinInstance)
	goblinInstance.starting_pos = self.get_node("Image/whatsOnTV").global_translation
	goblinInstance.translation = self.get_node("Image/whatsOnTV").global_translation
	goblinInstance.should_respawn = true
	$Tween.stop_all()


func recieve_damage(amt):
		health_points -= amt
		if (health_points <= 0):
			die()


func die():
	emit_signal("television_destroyed")
	queue_free()


func spawn():
	_grow_enemy_sprite()
	$shrinkGrowTimer.start()
	is_spawning = true


func _remove_tv_image():
	$Image/whatsOnTV.hide()


func _grow_enemy_sprite():
	$Image/whatsOnTV.show()
	$Image/whatsOnTV.texture = GoblinSprite
	#$Tween.interpolate_property($whatsOnTV, "pixel_size", 0.05, 3)
	$Tween.interpolate_property($Image/whatsOnTV, "pixel_size", INITIAL_TV_IMAGE_SIZE, FINAL_TV_IMAGE_SIZE, TELEVISION_IMAGE_GROW_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($Image/whatsOnTV, "translation", Vector3(0, 1.05, -0.1), Vector3(0, 1, -0.1), TELEVISION_IMAGE_GROW_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()


func _on_DetectionArea_body_entered(body):
	if body.is_in_group("player") and not is_spawning:
		spawn()
