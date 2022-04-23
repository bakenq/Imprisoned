extends Node2D

var FIREBALL = preload("res://Scenes/Fireball.tscn")

var ready = false

func _ready():
	pass # Replace with function body.
	
func _physics_process(_delta):
	$AnimationPlayer.play("buildup")
	if ready:
		shoot()

func shoot():
	var fireball: Node2D = FIREBALL.instance()
	get_tree().current_scene.add_child(fireball)
	fireball.global_position = global_position
	ready = false
	$Fireball.play()


func _on_AnimationPlayer_animation_finished(buildup):
	ready = true
