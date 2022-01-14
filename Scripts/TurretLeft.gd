extends Node2D

var FIREBALL = preload("res://Scenes/FireballLeft.tscn")

var ready = true

func _ready():
	pass # Replace with function body.
	
func _physics_process(_delta):
	if ready:
		shoot()

func shoot():
	var fireball: Node2D = FIREBALL.instance()
	get_tree().current_scene.add_child(fireball)
	fireball.global_position = global_position
	ready = false
		
	$Timer.start(2.0)

func _on_Timer_timeout():
	ready = true
