





extends KinematicBody

const MOVE_SPEED = 3
const gravity = 320

var player_node

onready var raycast = $RayCast
onready var anim_player = $AnimationPlayer

var player = null
var dead = false


# Called when the node enters the scene tree for the first time.
func _ready():
	player_node = Global.player_node
#	anim_player.play("walk")
	add_to_group("zombies")


func _physics_process(delta):
	var vec_to_player = player_node.translation - translation
	vec_to_player = vec_to_player.normalized()
	self.look_at(player_node.translation, Vector3.UP)
	
	if dead:
		return
	if player == null:
		return
	
#	var vec_to_player = player.translation - translation
#	vec_to_player = vec_to_player.normalized()
#	raycast.cast_to = vec_to_player * 1.5
	
	move_and_collide(vec_to_player * MOVE_SPEED * delta)
	
	var move_vec = vec_to_player
	move_vec.y -= gravity * delta
	move_vec = move_and_slide(move_vec, Vector3.UP)
	
	if raycast.is_colliding():
		var coll = raycast.get_collider()
		if coll != null and coll.name == "Player":
			pass
			#coll.die()

func _fade_away():
	queue_free()

func die():
	dead = true
	$CollisionShape.disabled = true
#	anim_player.play("die")
	$ObliterationTimer.connect("timeout", self, "_fade_away")
	$ObliterationTimer.start()

func set_player(p):
	player = p











