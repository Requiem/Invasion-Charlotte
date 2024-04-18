extends Area

var Goblin = load("res://enemies/Goblin.tscn")
var GoblinSprite = load("res://assets/enemies/goblin1.png")
const TELEVISION_IMAGE_GROW_DURATION = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	$shrinkGrowTimer.connect("timeout", self, "_jump_out_of_tv")
	$shrinkGrowTimer.wait_time = TELEVISION_IMAGE_GROW_DURATION


func _jump_out_of_tv():
	_remove_tv_image()
	var goblinInstance = Goblin.instance()
	goblinInstance.tv_spawn_node = self
	get_tree().get_root().add_child(goblinInstance)
	goblinInstance.starting_pos = translation
	goblinInstance.translation = translation
	$shrinkGrowTimer.disconnect("timeout", self, "_jump_out_of_tv")
	$Tween.stop_all()

#spawn_goblin(spawn_point.translation)
#
#
#func spawn_goblin(_position):
#	var goblinInstance = Goblin.instance()
#	goblinInstance.starting_pos = _position
#	goblinInstance.translation = _position
#	add_child(goblinInstance)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_TV_body_entered(body):
	if body.is_in_group("player"):
		spawn()
	

func spawn():
	_grow_enemy_sprite()
	$shrinkGrowTimer.start()


func _remove_tv_image():
	$whatsOnTV.hide()

func _grow_enemy_sprite():
	$whatsOnTV.show()
	$whatsOnTV.texture = GoblinSprite
	#$Tween.interpolate_property($whatsOnTV, "pixel_size", 0.05, 3)
	$Tween.interpolate_property($whatsOnTV, "pixel_size", 0.01, 0.05, TELEVISION_IMAGE_GROW_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($whatsOnTV, "translation", Vector3(0, 0.25, -0.1), Vector3(0, 0.75, -0.1), TELEVISION_IMAGE_GROW_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	
	
	


