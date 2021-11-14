extends KinematicBody2D

const UP = Vector2(0,-1)
const GRAVITY = 20
const MAXFALLSPEED = 350
const MAXSPEED = 75
const ACCEL = 5


export var hitpoints = 10
var dead = false
var getting_hit = false

var facing_right = false
var motion = Vector2(0,0)
var is_moving = false

var knockback_force = 100

var player = null



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _physics_process(delta):
	
	motion.y += GRAVITY
	
	if motion.y > MAXFALLSPEED:
		motion.y = MAXFALLSPEED
	
	motion.x = clamp(motion.x,-MAXSPEED,MAXSPEED)
	
	if facing_right == true:
		$AnimatedSprite.scale.x = 1
		$CollisionShape2D.position.x = 4.25
		#get_node("AttackArea").set_scale(Vector2(1,1))
	else:
		$AnimatedSprite.scale.x = -1
		$CollisionShape2D.position.x = -4.25
		#get_node("AttackArea").set_scale(Vector2(-1,1))

	if player:
		if position.direction_to(player.position).x < 0 && getting_hit == false:
			motion.x -= ACCEL
			facing_right = true
			$AnimatedSprite.play("Walk")
			#print_debug("left")
		elif position.direction_to(player.position).x > 0 && getting_hit == false:
			motion.x += ACCEL
			facing_right = false
			$AnimatedSprite.play("Walk")
			#print_debug("right")
		else:
			motion.x = lerp(motion.x,0,0.1)
			if is_moving == false && getting_hit == false:
				$AnimatedSprite.play("Idle")
		
	motion = move_and_slide(motion, UP)


func knockback():
	if facing_right == true:
		motion = global_position * Vector2(10,3)
	elif facing_right == false:
		motion = global_position * Vector2(-10,3)
		
func _on_DetectionRadius_body_entered(body):
	player = body


func _on_DetectionRadius_body_exited(body):
	player = null

func _on_Skeleton_area_entered(area):
	if area.is_in_group("Sword") && hitpoints == 0:
		#$AnimatedSprite.stop()
		getting_hit = true
		dead = true
		$AnimatedSprite.play("Death")
	else:
		#$AnimatedSprite.stop()
		getting_hit = true
		knockback()
		$AnimatedSprite.play("GetHit")
		hitpoints = hitpoints - 1
		print_debug(hitpoints)

func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "GetHit":
		getting_hit = false
	if $AnimatedSprite.animation == "Death":
		queue_free()
