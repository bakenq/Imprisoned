extends Area2D

export var speed = 250
const LEFT = Vector2.LEFT

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	var direction = LEFT.rotated(rotation) * speed * delta
	global_position += direction


func destroy():
	queue_free()

func _on_Fireball_area_entered(_area):
	destroy()


func _on_Fireball_body_entered(_body):
	destroy()


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_ResetTimer_timeout():
	pass # Replace with function body.
