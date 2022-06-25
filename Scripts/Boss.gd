extends KinematicBody2D

var HEART = preload("res://Scenes/Heart.tscn")

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
var deathsound = 0  

func _physics_process(delta):
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

# Dreht um wenn Plattform endet
func detect_turn_around():
	if not $RayCast2D_Down.is_colliding() and is_on_floor():
		moving_left = !moving_left
		scale.x = -scale.x
		#$TurretRight.scale.x = -$TurretRight.scale.x
		#$TurretLeft.scale.x = -$TurretLeft.scale.x
	if $RayCast2D_Side.is_colliding() and is_on_floor():
		moving_left = !moving_left
		scale.x = -scale.x
		#$TurretRight.scale.x = -$TurretRight.scale.x
		#$TurretLeft.scale.x = -$TurretLeft.scale.x
		
func spawn_heart():
	var heart: Node2D = HEART.instance()
	get_tree().current_scene.add_child(heart)
	heart.global_position = global_position

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
	if getting_hit == false && is_attacking == false:
		$AttackAreaDelay.start(0.7)
		motion.x = 0
		$AnimatedSprite.offset.y = -2
		$AnimatedSprite.offset.x = 8
		
		$TurretRight/AnimationPlayer.play("buildup")
		$FireballBuildup.start(1.5)
		#$Hitbox.position.x = 8
		#$Hitbox/CollisionShape2D.position.x = -3
		if dead == false:
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
			#$Hitbox.position.x = 0
		#if $AnimatedSprite.animation == "GetHit":
			#getting_hit = false
			#is_attacking = false
		if $AnimatedSprite.animation == "Death":
			pass
			#spawn_heart()
			#queue_free()

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
		$OnDeathTimer.start(3.0)

		
	elif area.is_in_group("Sword") && hitpoints > 0:
		#$AnimatedSprite.stop()
		#motion.x = 0
		getting_hit = true
		$Skt_gettinghit.play()
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
	#$TurretRight.shoot()
	

	
	#$TurretRight.shoot2()

	
func _on_AttackAreaDelay2_timeout():
	$AttackDetector/CollisionShape2D.disabled = true


func _on_Effects_animation_finished(anim_name):
	if anim_name == "Hit":
			getting_hit = false

func _on_PlayerDetectorDelay_timeout():
	$PlayerDetector/CollisionShape2D.disabled = false
	
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


func _on_FireballBuildup_timeout():
	if moving_left:
		$TurretRight.shoot()
		$TurretRight2.shoot2()
	elif !moving_left:
		$TurretRight.shoot2()
		$TurretRight2.shoot()


func _on_OnDeathTimer_timeout():
	get_tree().change_scene("res://Scenes/WinScreen.tscn")
