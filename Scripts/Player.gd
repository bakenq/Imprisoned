extends KinematicBody2D

# Constants
const UP = Vector2(0,-1)
const GRAVITY = 20
const MAXFALLSPEED = 350
const MAXSPEED = 175
const JUMPFORCE = 400
const ACCEL = 15
const DASHSPEED = 175
const DASHDURATION = 0.175

onready var dash = $Dash
onready var health_bar = $HealthBar

export var hitpoints = 100

# Movement/States
var motion = Vector2()
var speed = 0
var gravity_on = true
var facing_right = true
var is_dashing = false

var jump_count = 0
export var extra_jumps = 1

var is_attacking = false
var getting_hit = false
var dead = false
var deathsound = 0

var combo_attack = false
var combo_cooldown = false
var cooldown_active = false

func _ready():
	pass


func _physics_process(delta):
	
	if gravity_on:
		motion.y += GRAVITY
	else:
		motion.y = 0
	
	if motion.y > MAXFALLSPEED:
		motion.y = MAXFALLSPEED
		
	if facing_right == true:
		$AnimatedSprite.scale.x = 1
		$CollisionShape2D.position.x = -4
		get_node("AttackArea").set_scale(Vector2(1,1))
		get_node("Hitbox").set_scale(Vector2(1,1))
	else:
		$AnimatedSprite.scale.x = -1
		$CollisionShape2D.position.x = 4
		get_node("AttackArea").set_scale(Vector2(-1,1))
		get_node("Hitbox").set_scale(Vector2(-1,1))
		
	motion.x = clamp(motion.x,-MAXSPEED,MAXSPEED)
	
	move()
	jump()
	dash(delta)
	combat()
	motion = move_and_slide(motion,UP)

func move():
	# Movement
	if Input.is_action_pressed("right") && is_attacking == false && dead == false: 
		motion.x += ACCEL
		moveSound()
		facing_right = true
		$AnimatedSprite.play("Run")
	elif Input.is_action_pressed("left") && is_attacking == false && dead == false:
		motion.x -= ACCEL
		moveSound()
		facing_right = false
		$AnimatedSprite.play("Run")
	else:
		motion.x = lerp(motion.x,0,0.2)
		if is_attacking == false && dead == false:
			$AnimatedSprite.play("Idle")
			
			
func jump():
	# Double Jump
	if Input.is_action_just_pressed("jump") && jump_count < extra_jumps && dead == false:
		$RandJump.play() #sound
		if is_attacking == true:
			is_attacking = false
			$AnimatedSprite.stop()
			$AttackArea/CollisionShape2D.disabled = true
		motion.y = -JUMPFORCE
		jump_count += 1
		
	if is_on_floor():
		jump_count = 0
			
	if !is_on_floor():
		if motion.y < 0:
			$AnimatedSprite.play("Jump")
		elif motion.y > 0:
			$AnimatedSprite.play("Fall")
			
func dash(delta):
	# Dash
	if dash.is_dashing():
		speed = DASHSPEED
	else:
		is_dashing = false
		gravity_on = true
		set_collision_layer_bit(6, true)
		set_collision_mask_bit(6, true)
		#$Hitbox/CollisionShape2D.disabled = false
	
	if Input.is_action_just_pressed("Dash") && dash.can_dash && !dash.is_dashing():
		dash.start_dash($AnimatedSprite, DASHDURATION)
		$DashSound.play() #sound
		is_dashing = true
		gravity_on = false
		set_collision_layer_bit(6, false)
		set_collision_mask_bit(6, false)
		#$Hitbox/CollisionShape2D.disabled = true
		
	if is_dashing == true && facing_right == true:
		motion.x = motion.x * speed * delta
	elif is_dashing == true && facing_right == false:
		motion.x = motion.x * speed * delta


func combat():
	# Combat
	if is_on_floor():
		if Input.is_action_just_pressed("Attack") && combo_attack == false && cooldown_active == false  && dead == false:
			$AnimatedSprite.play("Attack")
			$HitSound1.play() #sound
			is_attacking = true
			$AttackArea/CollisionShape2D.disabled = false
			
			$ComboTimer.start(1.5)
			combo_attack = true
			
			$ComboCooldownTimer.start(0.4)
			combo_cooldown = true
		elif Input.is_action_just_pressed("Attack") && combo_attack == true && combo_cooldown == false  && dead == false:
			
			$AnimatedSprite.play("Attack2")
			$HitSound2.play() #Sound
			is_attacking = true
			$AttackArea/CollisionShape2D.disabled = false
			
			combo_attack = false
			$ComboTimer.stop()
			
			$CooldownTimer.start(0.4)
			cooldown_active = true


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "Attack":
		$AttackArea/CollisionShape2D.disabled = true
		is_attacking = false
		
	if $AnimatedSprite.animation == "Attack2":
		$AttackArea/CollisionShape2D.disabled = true
		is_attacking = false
	
	if $AnimatedSprite.animation == "Death":
		$DeathTimer.start(3.0)
		#queue_free()


func _on_ComboTimer_timeout():
	combo_attack = false


func _on_CooldownTimer_timeout():
	cooldown_active = false


func _on_ComboCooldownTimer_timeout():
	combo_cooldown = false
	
func _on_DeathTimer_timeout():
	get_tree().reload_current_scene()

# Hit Detection
func _on_Hitbox_area_entered(area):
	if area.is_in_group("Skeleton") && (hitpoints - 10) == 0:
		if dash.is_dashing(): return
		if $Hitbox/CollisionShape2D.disabled == true: return
		# motion.x = 0
		getting_hit = true
		dead = true
		is_attacking = false
		hitpoints = hitpoints - 10
		health_bar._on_health_updated(hitpoints)
		deathsound += 1
		deathmain()
		$AnimatedSprite.play("Death")
		
	elif area.is_in_group("Skeleton") && hitpoints > 0:
		if dash.is_dashing(): return
		if $Hitbox/CollisionShape2D.disabled == true: return
		getting_hit = true
		$HitMain.play() # sound
		$Hithurt.play() #sound
		$Hitbox/CollisionShape2D.disabled = true
		$HitEffect.play("Hit")
		$Blink.play("Blink")
		hitpoints = hitpoints - 10
		health_bar._on_health_updated(hitpoints)
		print_debug("PlayerHealth: " + str(hitpoints))

func _on_Blink_animation_finished(anim_name):
		if anim_name == "Blink":
			getting_hit = false
			$Hitbox/CollisionShape2D.disabled = false

func deathmain():
	if deathsound == 1:
		$DeathSound.play()
	if deathsound > 1:
		$DeathSound.stop()


func moveSound():
	if motion.x != 0 && is_on_floor():
		if !$WalkingRand.playing:
			$WalkingRand.play()
	elif motion.x == 0 && is_on_floor():
		$WalkingRand.stop()
