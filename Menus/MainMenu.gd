extends Control

var at_title_screen

const STORY_TEXT_LIST = ["In the heart of Gastonia, one of North Carolina's most prosperous and cultured towns, something strange is happening.",
	"Across town, retro game monsters are spilling out of CRT televisions in a torrent of 8-bit chaos, wreaking havoc in their wake.",
	"A pixelated goblin bursts out from the depths of your CRT screen, materializing in your room in a cacophony of electronic screeches before kidnapping you.",
	"You awaken in an arena with nothing but a crossbow in your possession. As vintage villains cheer in the stands for your defeat, you brace yourself for battle. Are you ready for the fight of your life?"]

var story_text_index

# Called when the node enters the scene tree for the first time.
func _ready():
	at_title_screen = true
	story_text_index = 0
	$StoryText.text = STORY_TEXT_LIST[0]
	$StoryText.text += " Press the Space Bar to Go......."


func _physics_process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		if (at_title_screen):
			story_text_index += 1
			at_title_screen = false
			$MainTitle.hide()
			$MainTitleInstructionText.hide()
			$StoryText.show()
		elif (story_text_index == STORY_TEXT_LIST.size() - 1):
			var _result = get_tree().change_scene("res://Arena.tscn")
		else:
			story_text_index += 1
			$StoryText.text = STORY_TEXT_LIST[story_text_index]
			$StoryText.text += " Press the Space Bar to Go......."

