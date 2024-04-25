extends Area


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var player_node = Global.player_node
onready var amount = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	self.look_at(player_node.translation, Vector3.UP)


func _on_HealthPack_body_entered(body):
		if body.is_in_group("player"):
			player_node.heal(amount)
			queue_free()
