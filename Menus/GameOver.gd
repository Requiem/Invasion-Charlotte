extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const MENU_ITEM_GAME_OVER = 0
const MENU_ITEM_START_GAME = 1
const MENU_ITEM_MAIN_MENU = 2

var _current_menu_item

# Called when the node enters the scene tree for the first time.
func _ready():
	_current_menu_item = MENU_ITEM_GAME_OVER

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
# go forward on the menu screen
	
	if Input.is_action_just_pressed("ui_accept"):
		if _current_menu_item == MENU_ITEM_GAME_OVER:
			var _result = get_tree().change_scene("res://Arena.tscn")
			
	elif Input.is_action_just_pressed("ui_cancel"):
		if _current_menu_item == MENU_ITEM_GAME_OVER:
			MusicController.stop_music()
			var _result = get_tree().change_scene("res://Menus/MainMenu.tscn")
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
		_show_correct_menu_items()
		
		
func _show_correct_menu_items():
	if _current_menu_item == MENU_ITEM_GAME_OVER:
		$GameOver.show()
		
