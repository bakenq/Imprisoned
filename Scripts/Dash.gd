extends Node2D

const dash_delay = 0.75

onready var duration_timer = $DurationTimer
onready var ghost_timer = $GhostTimer
var ghost_scene = preload("res://Scenes/DashGhost.tscn")
var can_dash = true
var sprite

func start_dash(sprite2, duration):
	self.sprite = sprite2
	
	duration_timer.wait_time = duration
	duration_timer.start()
	
	ghost_timer.start()
	instance_ghost()
	
	
func instance_ghost():
	var ghost: AnimatedSprite = ghost_scene.instance()
	get_parent().get_parent().add_child(ghost)
	
	ghost.global_position = global_position
	ghost.frames = sprite.frames
	ghost.animation = sprite.animation
	ghost.frame = sprite.frame
	ghost.scale.x = sprite.scale.x

func is_dashing():
	return !duration_timer.is_stopped()

func end_dash():
	ghost_timer.stop()
	
	can_dash = false
	yield(get_tree().create_timer(dash_delay), "timeout")
	can_dash = true

func _on_DurationTimer_timeout():
	end_dash()


func _on_GhostTimer_timeout():
	instance_ghost()
