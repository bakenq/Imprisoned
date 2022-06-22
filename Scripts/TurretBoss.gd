extends Node2D

var FIREBALL = preload("res://Scenes/FireballBoss.tscn")
var FIREBALL_LEFT = preload("res://Scenes/FireballLeftBoss.tscn")

var ready = false

func _ready():
	pass # Replace with function body.
	
func _physics_process(_delta):
	pass
	#$AnimationPlayer.play("buildup")
	#if ready:
		#shoot()

func shoot():
	var fireball: Node2D = FIREBALL.instance()
	get_tree().current_scene.add_child(fireball)
	fireball.global_position = global_position
	ready = false
	$Fireball.play()
	
func shoot2():
	var fireball_left: Node2D = FIREBALL_LEFT.instance()
	get_tree().current_scene.add_child(fireball_left)
	fireball_left.global_position = global_position
	ready = false
	$Fireball.play()


func _on_AnimationPlayer_animation_finished(buildup):
	ready = true
