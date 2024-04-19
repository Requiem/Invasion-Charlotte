extends Node

var Goblin = load("res://enemies/Goblin.tscn")
var GoblinSprite = load("res://assets/enemies/goblin1.png")
const TELEVISION_IMAGE_GROW_DURATION = 3
var is_spawning = false

var health_points = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	$shrinkGrowTimer.connect("timeout", self, "_jump_out_of_tv")
	$shrinkGrowTimer.wait_time = TELEVISION_IMAGE_GROW_DURATION


func _jump_out_of_tv():
	_remove_tv_image()
	var goblinInstance = Goblin.instance()
	goblinInstance.tv_spawn_node = self
	get_tree().get_root().add_child(goblinInstance)
	goblinInstance.starting_pos = self.translation
	goblinInstance.translation = self.translation
	$Tween.stop_all()


func recieve_damage(collision_point):
		health_points -= 4
		if (health_points <= 0):
			die()


func die():
	queue_free()


func spawn():
	_grow_enemy_sprite()
	$shrinkGrowTimer.start()
	is_spawning = true


func _remove_tv_image():
	$whatsOnTV.hide()


func _grow_enemy_sprite():
	$whatsOnTV.show()
	$whatsOnTV.texture = GoblinSprite
	#$Tween.interpolate_property($whatsOnTV, "pixel_size", 0.05, 3)
	$Tween.interpolate_property($whatsOnTV, "pixel_size", 0.01, 0.05, TELEVISION_IMAGE_GROW_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($whatsOnTV, "translation", Vector3(0, 0.35, -0.1), Vector3(0, 0.75, -0.1), TELEVISION_IMAGE_GROW_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()


func _on_DetectionArea_body_entered(body):
	if body.is_in_group("player") and not is_spawning:
		spawn()
