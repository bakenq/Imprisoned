extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("Heart")


func _on_Heart_area_entered(area):
	if (area.is_in_group("Player")):
		queue_free()
