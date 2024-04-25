extends Area


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var player_node = Global.player_node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	self.look_at(player_node.translation, Vector3.UP)
	

func _on_AssaultRiflePickup_body_entered(body):
	if body.is_in_group("player"):
		player_node.equipped_weapon = "firewand"
		player_node.weapons.append("firewand")
		player_node.equip(1)
		queue_free()
