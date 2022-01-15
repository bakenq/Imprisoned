extends Node

func _ready():
	$VBoxContainer/VBoxContainer/Start.grab_focus()
	MusicController.play_music()

func _on_Start_pressed():
	get_tree().change_scene("res://Scenes/World.tscn")

func _on_Options_pressed():
	print("Options pressed")

func _on_Exit_pressed():
	get_tree().quit()
