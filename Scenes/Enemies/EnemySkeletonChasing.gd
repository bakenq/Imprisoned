extends KinematicBody2D

# Constants
const GRAVITY = 20
const UP = Vector2.UP
const knockback_speed = 0.4
const MAXSPEED = 75
const ACCEL = 5

export var hitpoints = 3

# Movement/States
var speed = 50
var chase_speed = 90
var motion = Vector2()
var moving_left = true
var is_chasing = false
var chasing_left = true
var turning = false

var getting_hit = false
var is_attacking = false
var dead = false
var deathsound = 0

var player = null


func _physics_process(delta):	
	if is_chasing == true && is_attacking == false:
		chase()
	else:
		move()
		detect_turn_around()

# Movement
func move():
	motion.y += GRAVITY
	
	if moving_left == true && is_attacking == false && getting_hit == false:
		motion.x = -speed
		start_Walk()
		moveSoundSKT()
	elif moving_left == false && is_attacking == false && getting_hit == false:
		motion.x = speed
		start_Walk()
		moveSoundSKT()
	else:
		lerp(motion.x,0,0.1)
	
	motion = move_and_slide(motion, UP)
	
	
func chase():
	motion.y += GRAVITY
	
	#motion.x = clamp(motion.x,-MAXSPEED,MAXSPEED)
	if moving_left == true:
		$AnimatedSprite.flip_h = false
		$CollisionShape2D.position.x = 5
		
		$RayCast2D_Down.position.x = -22
		$RayCast2D_Side.position.x = -6.25
		$RayCast2D_Side.scale.x = 1
		
		$Hitbox/CollisionShape2D.position.x = 5
		$PlayerDetector/CollisionShape2D.position.x = -10
		$AttackDetector/CollisionShape2D.position.x = -10
		
	elif moving_left == false:
		$AnimatedSprite.flip_h = true
		$CollisionShape2D.position.x = 0
		
		$RayCast2D_Down.position.x = 22
		$RayCast2D_Side.position.x = 9.25
		$RayCast2D_Side.scale.x = -1
		
		$Hitbox/CollisionShape2D.position.x = 0
		$PlayerDetector/CollisionShape2D.position.x = 16
		$AttackDetector/CollisionShape2D.position.x = 16

	if is_chasing == true:
		if position.direction_to(player.position).x < 0 && getting_hit == false:
			motion.x = -chase_speed
			moving_left = true
			moveSoundSKT() #sound
			$AnimatedSprite.play("Walk")
			#print_debug("left")
		elif position.direction_to(player.position).x > 0 && getting_hit == false:
			motion.x = chase_speed
			moving_left = false
			moveSoundSKT() #sound
			$AnimatedSprite.play("Walk")
			#print_debug("right")
		
	motion = move_and_slide(motion, UP)

# Dreht um wenn Plattform endet oder auf Wand trifft
func detect_turn_around():
	if not $RayCast2D_Down.is_colliding() and is_on_floor():
		moving_left = !moving_left
		scale.x = -scale.x
		print(scale.x)
		print("test")
	if $RayCast2D_Side.is_colliding() and is_on_floor() && turning == false:
		if moving_left == true:
			$TurnTimer.start(0.5)
			turning = true
			moving_left = false
			
			$AnimatedSprite.flip_h = true
			$CollisionShape2D.position.x = 0
		
			$RayCast2D_Down.position.x = 22
			$RayCast2D_Side.position.x = 9.25
			$RayCast2D_Side.scale.x = -1
		
			$Hitbox/CollisionShape2D.position.x = 0
			$PlayerDetector/CollisionShape2D.position.x = 16
			$AttackDetector/CollisionShape2D.position.x = 16
			
		elif moving_left == false:
			$TurnTimer.start(0.5)
			turning = true
			moving_left = true
			
			$AnimatedSprite.flip_h = false
			$CollisionShape2D.position.x = 5
		
			$RayCast2D_Down.position.x = -22
			$RayCast2D_Side.position.x = -6.25
			$RayCast2D_Side.scale.x = 1
		
			$Hitbox/CollisionShape2D.position.x = 5
			$PlayerDetector/CollisionShape2D.position.x = -10
			$AttackDetector/CollisionShape2D.position.x = -10

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

func _on_PlayerDetector_body_entered(body):
	is_chasing = false
	if getting_hit == false && is_attacking == false:
		if moving_left:
			$AttackAreaDelay.start(0.7)
			motion.x = 0
			$AnimatedSprite.offset.y = -2
			$AnimatedSprite.offset.x = 8
			$Hitbox/CollisionShape2D.position.x = -3
			if dead == false:
				$AnimatedSprite.play("Attack")
				$Skt_meleesound.play()
				is_attacking = true
		else:
			$AttackAreaDelay.start(0.7)
			motion.x = 0
			$AnimatedSprite.offset.y = -2
			$AnimatedSprite.offset.x = -10
			$Hitbox/CollisionShape2D.position.x = 0
			$AnimatedSprite.play("Attack")
			$Skt_meleesound.play()
			is_attacking = true


func _on_AttackDetector_body_entered(body):
	pass
	#get_tree().reload_current_scene()


func _on_AnimatedSprite_animation_finished():
		if $AnimatedSprite.animation == "Attack":
			is_attacking = false
			$AnimatedSprite.offset.y = 0
			$AnimatedSprite.offset.x = 0
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
		deathsound += 1 #sound
		deathsoundstopskt() #sound
		$AttackAreaDelay.stop()
		$AttackDetector/CollisionShape2D.disabled = true
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
		$Skt_gettinghit.play() #sound
		hitpoints = hitpoints - 1
		print_debug("EnemyHealth: " + str(hitpoints))


func _on_AttackAreaDelay_timeout():
	$AttackDetector/CollisionShape2D.disabled = false
	$PlayerDetector/CollisionShape2D.disabled = true
	$ChaseDetectionRadius/CollisionShape2D.disabled = true
	
	$AttackAreaDelay2.start(0.2)
	$PlayerDetectorDelay.start(1.25)
	$ChaseDetectionDelay.start(1.3)
	
func _on_AttackAreaDelay2_timeout():
	$AttackDetector/CollisionShape2D.disabled = true


func _on_Effects_animation_finished(anim_name):
	if anim_name == "Hit":
			getting_hit = false


func _on_PlayerDetectorDelay_timeout():
	$PlayerDetector/CollisionShape2D.disabled = false


func _on_ChaseDetectionRadius_body_entered(body1):
	player = body1
	is_chasing = true
	print_debug(is_chasing)


func _on_ChaseDetectionRadius_body_exited(body1):
	player = null
	is_chasing = false
	print_debug(is_chasing)


func _on_TurnTimer_timeout():
	turning = false


func _on_ChaseDetectionDelay_timeout():
	$ChaseDetectionRadius/CollisionShape2D.disabled = false
	
	
	
func deathsoundstopskt():
	if deathsound == 1:
		$Deathsound1.play()
	if deathsound > 1:
		$Deathsound1.stop()

func moveSoundSKT():
	if motion.x != 0 && is_on_floor():
		if !$Skt_Walking.playing:
			$Skt_Walking.pitch_scale = rand_range(0.8, 1.0)
			$Skt_Walking.play()
	elif motion.x == 0 && is_on_floor():
		$Skt_Walking.stop()



