extends Node

var musik = load("res://Sound/HintergurndMusikAmbiente.wav")


func _ready():
	pass 


func play_music():
	$Musik.stream = musik
	$Musik.play()


