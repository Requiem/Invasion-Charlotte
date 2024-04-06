extends KinematicBody

const MOVE_SPEED = 3
var player_node = null

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	player_node = Global.player_node
	
	pass # Replace with function body.

func _physics_process(delta):
	var vec_to_player = player_node.translation - translation
	vec_to_player = vec_to_player.normalized()
	self.look_at(player_node.translation, Vector3.UP)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
