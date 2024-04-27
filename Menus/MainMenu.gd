extends Control

var at_title_screen

const MENU_ITEM_MAIN_TITLE = 0
const MENU_ITEM_CREDITS = 1
const MENU_ITEM_STORY_1 = 2
const MENU_ITEM_STORY_2 = 3
const MENU_ITEM_STORY_3 = 4
const MENU_ITEM_STORY_4 = 5
const STORY_ITEM_ARRAY_OFFSET = 2

var _current_menu_item

const STORY_TEXT_LIST = ["In the heart of Gastonia, one of North Carolina's most prosperous and cultured towns, something strange is happening.",
	"Across town, retro game monsters are spilling out of CRT televisions in a torrent of 8-bit chaos, wreaking havoc in their wake.",
	"A pixelated goblin bursts out from the depths of your CRT screen, materializing in your room in a cacophony of electronic screeches before kidnapping you.",
	"You awaken in an arena with nothing but a crossbow in your possession. As vintage villains cheer in the stands for your defeat, you brace yourself for battle. Are you ready for the fight of your life?"]


# Called when the node enters the scene tree for the first time.
func _ready():
	_current_menu_item = MENU_ITEM_MAIN_TITLE

func _physics_process(_delta):
	# go forward on the menu screen
	if Input.is_action_just_pressed("ui_accept"):
		if _current_menu_item == MENU_ITEM_MAIN_TITLE:
			_current_menu_item = MENU_ITEM_STORY_1
			
		elif _current_menu_item == MENU_ITEM_CREDITS:
			_current_menu_item = MENU_ITEM_MAIN_TITLE
			
		elif _current_menu_item == MENU_ITEM_STORY_1:
			_current_menu_item = MENU_ITEM_STORY_2
			
		elif _current_menu_item == MENU_ITEM_STORY_2:
			_current_menu_item = MENU_ITEM_STORY_3
			
		elif _current_menu_item == MENU_ITEM_STORY_3:
			_current_menu_item = MENU_ITEM_STORY_4
			
		elif _current_menu_item == MENU_ITEM_STORY_4:
			var _result = get_tree().change_scene("res://Arena.tscn")
			
		_show_correct_menu_items()		
	

	# go back on the menu screen
	if Input.is_action_just_pressed("ui_cancel"):
		if _current_menu_item == MENU_ITEM_MAIN_TITLE:
			_current_menu_item = MENU_ITEM_CREDITS
			
		elif _current_menu_item == MENU_ITEM_CREDITS:
			_current_menu_item = MENU_ITEM_MAIN_TITLE
			
		elif _current_menu_item == MENU_ITEM_STORY_1:
			_current_menu_item = MENU_ITEM_MAIN_TITLE
			
		elif _current_menu_item == MENU_ITEM_STORY_2:
			_current_menu_item = MENU_ITEM_STORY_1
			
		elif _current_menu_item == MENU_ITEM_STORY_3:
			_current_menu_item = MENU_ITEM_STORY_2
			
		elif _current_menu_item == MENU_ITEM_STORY_4:
			_current_menu_item = MENU_ITEM_STORY_3
		
		_show_correct_menu_items()		


func _show_correct_menu_items():
	if _current_menu_item == MENU_ITEM_MAIN_TITLE:
		$MainTitle.show()
		$MainTitleInstructionText.show()
		$Credits.hide()
		$StoryText.hide()
	elif _current_menu_item == MENU_ITEM_CREDITS:
		$MainTitle.hide()
		$MainTitleInstructionText.hide()
		$Credits.show()
		$StoryText.hide()
	else:
		$MainTitle.hide()
		$MainTitleInstructionText.hide()
		$Credits.hide()
		$StoryText.show()
		$StoryText.text = STORY_TEXT_LIST[_current_menu_item - STORY_ITEM_ARRAY_OFFSET]
		$StoryText.text += " Press the Space Bar to Go......."
	
