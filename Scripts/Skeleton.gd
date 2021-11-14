extends Area2D

export var hitpoints = 3
var dead = false

var facing_right = false
var getting_hit = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if getting_hit == false && dead == false:
		$AnimatedSprite.play("Idle")
		
	if facing_right == true:
		$AnimatedSprite.scale.x = 1
		$CollisionShape2D.position.x = -4.25
	else:
		$AnimatedSprite.scale.x = -1
		$CollisionShape2D.position.x = 4.25
		
	
func _on_Skeleton_area_entered(area):	
	if area.is_in_group("Sword") && hitpoints == 0:
		dead = true
		$AnimatedSprite.play("Death")
	else:
		getting_hit = true
		$AnimatedSprite.play("GetHit")
		hitpoints = hitpoints - 1
		print_debug(hitpoints)

func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "GetHit":
		getting_hit = false
	if $AnimatedSprite.animation == "Death":
		queue_free()
