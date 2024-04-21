extends Node

var combat_music = load("res://assets/sounds/music_zapsplat_game_music_action_agressive_pounding_tense_electro_synth_028.wav")

func _ready():
	pass
	
func play_music():
	$Music.stream = combat_music
	$Music.play()
