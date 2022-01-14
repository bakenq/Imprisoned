extends KinematicBody2D

# Constants
const GRAVITY = 20
const UP = Vector2.UP
const knockback_speed = 0.4

export var hitpoints = 3

# Movement/States
var speed = 50
var motion = Vector2()
var moving_left = true
var is_moving = false

var getting_hit = false
var is_attacking = false
var dead = false


func _physics_process(_delta):
	move()
	detect_turn_around()

# Movement
func move():
	motion.y += GRAVITY
	
	if moving_left == true && is_attacking == false && getting_hit == false:
		motion.x = -speed
		start_Walk()
	elif moving_left == false && is_attacking == false && getting_hit == false:
		motion.x = speed
		start_Walk()
	else:
		lerp(motion.x,0,0.1)
	
	motion = move_and_slide(motion, UP)

# Dreht um wenn Plattform endet
func detect_turn_around():
	if not $RayCast2D_Down.is_colliding() and is_on_floor():
		moving_left = !moving_left
		scale.x = -scale.x
	if $RayCast2D_Side.is_colliding() and is_on_floor():
		moving_left = !moving_left
		scale.x = -scale.x

func hit():
	$AttackDetector.monitoring = true
	
func end_of_hit():
	$AttackDetector.monitoring = false
	
func start_Walk():
	$AnimatedSprite.play("Walk")

# Noch kein plan wie man vernünftig Knockback implementiert
func knockback():
	# motion = global_position * knockback_speed
	motion.x = lerp(global_position.x * knockback_speed, 0, 0.2)

func _on_PlayerDetector_body_entered(_body):
	if getting_hit == false && is_attacking == false:
		$AttackAreaDelay.start(0.7)
		motion.x = 0
		$AnimatedSprite.offset.y = -2
		$AnimatedSprite.offset.x = 8
		$AnimatedSprite.play("Attack")
		is_attacking = true


func _on_AttackDetector_body_entered(_body):
	pass
	#get_tree().reload_current_scene()


func _on_AnimatedSprite_animation_finished():
		if $AnimatedSprite.animation == "Attack":
			is_attacking = false
			$AnimatedSprite.offset.y = 0
			$AnimatedSprite.offset.x = 0
		#if $AnimatedSprite.animation == "GetHit":
			#getting_hit = false
			#is_attacking = false
		if $AnimatedSprite.animation == "Death":
			queue_free()

# Combat/Hit detection
func _on_Hitbox_area_entered(area):
	if area.is_in_group("Sword") && hitpoints == 0:
		#$AnimatedSprite.stop()
		motion.x = 0
		getting_hit = true
		dead = true
		is_attacking = false
		$AnimatedSprite.offset.y = 1
		$AnimatedSprite.offset.x = -4
		$AnimatedSprite.play("Death")
	elif area.is_in_group("Sword") && hitpoints > 0:
		#$AnimatedSprite.stop()
		#motion.x = 0
		getting_hit = true
		#knockback()
		#$AnimatedSprite.play("GetHit")
		$Effects.play("Hit")
		hitpoints = hitpoints - 1
		print_debug("EnemyHealth: " + str(hitpoints))


func _on_AttackAreaDelay_timeout():
	$AttackDetector/CollisionShape2D.disabled = false
	$PlayerDetector/CollisionShape2D.disabled = true
	$AttackAreaDelay2.start(0.2)
	$PlayerDetectorDelay.start(1.25)
	
func _on_AttackAreaDelay2_timeout():
	$AttackDetector/CollisionShape2D.disabled = true


func _on_Effects_animation_finished(anim_name):
	if anim_name == "Hit":
			getting_hit = false

func _on_PlayerDetectorDelay_timeout():
	$PlayerDetector/CollisionShape2D.disabled = false
