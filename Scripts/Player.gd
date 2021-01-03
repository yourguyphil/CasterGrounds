extends KinematicBody2D

signal grounded_updated(is_grounded)

const E_BASICBLAST = preload("res://Objects/MagicianBasicBlast.tscn")
const W_SPINNINGBLAST = preload("res://Objects/MagicianSpinningBlast.tscn")
const R_ULTIMATEBLAST = preload("res://Objects/MagicianUltimateBlast.tscn")
const D_SHIELD = preload("res://Objects/MagicianShield.tscn")

var TYPE = "player"

#State Vars
var states = ["idle", "run", "dash", "fall", "jump", "double_jump", "float", "basicblast", "spinningblast", "ultimateblast", "block", "boost", "fallfast"] #list of all states
var currentState = states[0] #what state's logic is being called every frame
var previousState = null #last state that was being calles

signal health_changed(new_value)
const MAX_HEALTH = 10
export var health = 10 setget _set_health

signal mana_changed(new_value)
const MAX_MANA = 20
export var mana = 20 setget _set_mana

signal magicaian_dash_used(value)
signal magicaian_basic_blast_used(value)
signal magicaian_spinning_blast_used(value)
signal magicaian_ultimate_blast_used(value)
signal block_used(value)
signal show_warning_text(value)

#Nodes & paths
onready var PlayerSprite = $Sprite #path to the player's sprite
onready var Anim = $AnimationPlayer #path to animation player

onready var RightRaycast = $RightRaycast #path to the right raycast
onready var LeftRaycast = $LeftRaycast  #path to the left raycast

#Input Vars
var movementInput = 0 #will be 1, -1, 0 depending on if you are holding right, left, or nothing
var lastDirection = 1 #last direction pressed that is not 0

var isJumpPressed = 0 #will be 1 on the frame that the jump button was pressed
var isJumpReleased #will be 1 on the frame that the jump button was released

var isFloatPressed = 0 #will be 1 on the frame that the jump button was pressed
var isFloatReleased #will be 1 on the frame that the jump button was released

var isFallFastPressed = 0
var isFallFastReleased 

var isQPressed = 0 
var isQReleased 

var isWPressed = 0 
var isWReleased 

var isEPressed = 0 
var isEReleased 

var isRPressed = 0 
var isRReleased 

var isDPressed = 0 
var isDReleased 

var coyoteStartTime = 0 #ticks when you pressed jump button
var elapsedCoyoteTime = 0 #elapsed time since you last clicked jump
var coyoteDuration = 100 #how many miliseconds to remember a jump press

var jumpInput = 0 #jump press with coyote time

var isDashPressed #will be 1 on the frame that the dash button was pressed

#Movement Vars
var velocity = Vector2.ZERO #linear velocity applied to move and slide

var currentSpeed = 0 #how much you add to x velocity when moving horizontally
var maxSpeed = 120 #maximum current speed can reach when moving horizontally
var acceleration = 20 #by how much does current speed approach max speed when moving
var decceleration = 40 #by how much does velocity approach when you stop moving horizontally

var airFriction = 60 #how much you subtract velocity when you start moving horizontally in the air

#dash
var dashSpeed = 60 #how fast you dash
var dashDurration = 160  #how long you dash for (in milisecconds)

var canDash = true #can the character dash
var dashStartTime #how many miliseconds passed when you started dashing 
var elapsedDashTime #how many milisecconds elapsed since you started dashing
var dashDirection = 1 #direction of dash will be 1 or -1 if you are dashing left or right

#fall
var gravity = 700 #how much is added to y velocity constantly

var jumpBufferStartTime  = 0 #ticks when you ran of the platform
var elapsedJumpBuffer = 0 #how many seconds passed in the jump nuffer
var jumpBuffer = 100 #how many miliseconds allowance you give jumps after you run of an edge

#jump
var jumpHeight = 64  #How high the peak of the jump is in pixels
var jumpVelocity #how much to apply to velocity.y to reach jump height

#float
var isfloating = false

#fall fast
var isfallingfast = false

#attack
var isattacking = false

#grounded 
var is_grounded

#double jump
var doubleJumpHeight = 64 #How high the peak of the double jump is in pixels
var doubleJumpVelocity #how much to apply to velocity.y to reach double jump height

var isDoubleJumped = false #if you have double jumped

#wall slide
var wallSlideSpeed = 50 #how fast you slide on a wll

#wall jump
var wallJumpHeight = 128 #how high you want the peak of your wall jump to be in pixels
var wallJumpVelocity #how much to apply to velocity.y to reach wall jump height

var is_damaged = false

var dash_manacost = 2
var basicblast_manacost = 2
var spinningblast_manacost = 5
var ultimateblast_manacost = 7
var block_manacost = 3

export var mana_regen_time = 1.5
onready var manaregen_timer = mana_regen_time

export var e_cooldown = .5
onready var e_cooldown_timer = e_cooldown

export var w_cooldown = 4
onready var w_cooldown_timer = e_cooldown

export var r_cooldown = 6
onready var r_cooldown_timer = e_cooldown

export var d_cooldown = 3
onready var d_cooldown_timer = e_cooldown

export var e_animation_duration = .4
onready var e_animation_timer = e_animation_duration

var playerknockback = 50

#functions
func _ready():
	#use kin functions to set jump velocites
	jumpVelocity = -sqrt(2 * gravity * jumpHeight) 
	doubleJumpVelocity = -sqrt(2 * gravity * doubleJumpHeight)
	wallJumpVelocity = -sqrt(2 * gravity * jumpHeight)
	
	var parent = get_parent()
	#Camera Settings #TODO FIX THIS
	var tilemap_rect = get_parent().get_node("TileMap").get_used_rect()
	var tilemap_cell_size = 16
	$PlayerCamera.limit_left = tilemap_rect.position.x * tilemap_cell_size
	$PlayerCamera.limit_right = tilemap_rect.end.x * tilemap_cell_size
	$PlayerCamera.limit_top = tilemap_rect.position.y * tilemap_cell_size
	$PlayerCamera.limit_bottom = tilemap_rect.end.y * tilemap_cell_size
	pass
	
func _physics_process(delta):
	if is_damaged == false:
		get_input()
		#TODO: maybe put this in a better place?
		if is_on_floor():
			isfloating = false
			isfallingfast = false
		
		# check y > 0 to work around infinate float super jump bug
		if isfloating == true and velocity.y > 0:
			print("Applying float gravity")
			apply_gravity(delta/6)
		elif isfallingfast == true:
			print("Applying fall fast gravity")
			apply_gravity(delta*2)
		else:
			apply_gravity(delta)
			
		call(currentState + "_logic", delta) #call the current states main method
		
		if awaitingOnAnimations():
			var awaitVelocity = Vector2.ZERO
			awaitVelocity.y = velocity.y
			move_and_slide(awaitVelocity, Vector2.UP) #aply velocity to movement
		else:
			velocity = move_and_slide(velocity, Vector2.UP) #aply velocity to movement
		
		#camera check
		var was_grounded = is_grounded
		is_grounded = is_on_floor()
		
		if was_grounded == null || is_grounded != was_grounded:
			emit_signal("grounded_updated", is_grounded)
		
		PlayerSprite.flip_h = lastDirection - 1 #flip sprite depending on which direction you last moved in
		
		#regen mana
		if $ManaRegen_Timer.is_stopped() and mana < 20:
			$ManaRegen_Timer.start(mana_regen_time)
			mana += 1
			_set_mana(mana)
		
		if get_slide_count() > 0:
			for i in range(get_slide_count()):
				if "Enemy" in get_slide_collision(i).collider.name and not get_slide_collision(i).collider.is_dead:
					var knockbackdirection 
					var positionplayer = $PlayerPosition.global_position.x
					var positionEnemy = get_slide_collision(i).get_position().x
					
					if positionplayer > positionEnemy:
						knockbackdirection = 1
					else:
						knockbackdirection = -1
					
					damage(1, knockbackdirection)
					break 
		pass
	
func get_input():
	#set input vars
	movementInput = Input.get_action_strength("right") - Input.get_action_strength("left") #set movement input to 1,-1, or 0
	if movementInput != 0:
		lastDirection = movementInput #set last direction if movement input isnt 0

	isJumpPressed = Input.is_action_just_pressed("jump") 
	isJumpReleased = Input.is_action_just_released("jump")
	
	isFloatPressed = Input.is_action_just_pressed("up") 
	isFloatReleased = Input.is_action_just_released("up")
	
	isFallFastPressed = Input.is_action_just_pressed("down") 
	isFallFastReleased = Input.is_action_just_released("down")
	
	isEPressed = Input.is_action_just_pressed("e") 
	isEReleased = Input.is_action_just_released("e")
	
	isWPressed = Input.is_action_just_pressed("w") 
	isWReleased = Input.is_action_just_released("w")
	
	isQPressed = Input.is_action_just_pressed("q") 
	isQReleased = Input.is_action_just_released("q")
	
	isRPressed = Input.is_action_just_pressed("r") 
	isRReleased = Input.is_action_just_released("r")
	
	isDPressed = Input.is_action_just_pressed("d") 
	isDReleased = Input.is_action_just_released("d")
	
	#set coyote jump time (remember jump presses to make the jump more forgiving)
	if jumpInput == 0 && isJumpPressed:
		#if you press jump and your not already in coyote time
		jumpInput = int(isJumpPressed) #set jump to 1
		coyoteStartTime = OS.get_ticks_msec() #start timer
	
	elapsedCoyoteTime = OS.get_ticks_msec() - coyoteStartTime

	if jumpInput != 0 && elapsedCoyoteTime > coyoteDuration:
		#if timer expires and your in coyote time
		jumpInput = 0 #reset jump input
		coyoteStartTime = 0 #reset timer
	
	isDashPressed = Input.is_action_just_pressed("dash")


func apply_gravity(delta):
	#apply gravity in every state except dash
	if currentState != "dash":
		velocity.y += gravity * delta


func set_state(new_state : String):
	#update state values
	previousState = currentState
	currentState = new_state
	
	#call enter/exit methods
	if previousState != null:
		call(previousState + "_exit_logic")
	if currentState != null:
		call(currentState + "_enter_logic")

#Functions used across multiple states

func move_horizontally(subtractor):
	currentSpeed = move_toward(currentSpeed, maxSpeed, acceleration) #accelerate current speed
	
	velocity.x = currentSpeed * movementInput #apply curent speed to velocity and multiply by direction

	if movementInput == -1:
		if sign($FireballShootPosition.position.x) == 1:
			$FireballShootPosition.position.x *= -1
	elif movementInput == 1:
		if sign($FireballShootPosition.position.x) == -1:
			$FireballShootPosition.position.x *= -1

func squash_stretch(squash, stretch):
	#set Sprite scale to squash and stretch
	PlayerSprite.scale.x = squash
	PlayerSprite.scale.y = stretch
	
func boostjump(jumpVelocity):
	velocity.y = 0 #reset velocity
	velocity.y = jumpVelocity #apply velocity

func jump(jumpVelocity):
	velocity.y = 0 #reset velocity
	velocity.y = jumpVelocity #apply velocity
	canDash = true #allow the player to dash when they jump

func set_float_physics():
	velocity.y = 0 #reset velocity
	isfloating = true
	canDash = true #allow the player to dash when they jump

func set_fallfast_physics():
	isfloating = false
	isfallingfast = true
	
#State Functions

func idle_enter_logic():
	if previousState == "basicblast" or previousState == "spinningblast" or previousState == "ultimateblast" or previousState == "dash" or previousState == "block":
		yield( Anim, "animation_finished")
	Anim.play("Idle") #play the idle animation
	print("Idling")

func idle_logic(delta):
	if jumpInput:
		#jump if you press button
		jump(jumpVelocity)
		set_state("jump")
	
	if isDashPressed:
		#dash if you press button
		set_state("dash")
	
	check_for_attack()
	
	if movementInput != 0:
		#start running if you press a movement button
		set_state("run")
	velocity.x = move_toward(velocity.x, 0, decceleration) #deccelerate

func check_for_attack():
	if isEPressed and $E_Cooldown_Timer.is_stopped() and mana >= basicblast_manacost:
		#e if you press button
		set_state("basicblast")
	
	if isWPressed and $W_Cooldown_Timer.is_stopped() and mana >= spinningblast_manacost:
		#e if you press button
		set_state("spinningblast")
	
	if isRPressed and $R_Cooldown_Timer.is_stopped() and mana >= ultimateblast_manacost:
		#e if you press button
		set_state("ultimateblast")
		
	if isQPressed and $E_Cooldown_Timer.is_stopped() and mana >= dash_manacost:
		#e if you press button
		set_state("dash")
		
	if isDPressed and $D_Cooldown_Timer.is_stopped() and mana >= block_manacost:
		#e if you press button
		set_state("block")

func idle_exit_logic():
	currentSpeed = 0 #reset current speed (we do this here to keep momentum on run jumps)
	
func run_enter_logic():
	if previousState == "basicblast" or previousState == "spinningblast" or previousState == "ultimateblast":
		yield( Anim, "animation_finished")
	Anim.play("Run") #play the run animation
	print("Running")

func run_logic(delta):
	if jumpInput:
		#jump if you press the jump button
		jump(jumpVelocity)
		set_state("jump")
		
	if isDashPressed:
		#dash if you press the dash button
		set_state("dash")
	
	check_for_attack()
	
	#Commented out for ramps
	
	#if !is_on_floor():
	#	#if your not on a floor, start falling and set jumpbuffer start time
	#	jumpBufferStartTime = OS.get_ticks_msec()
	#	jumpBufferStartTime = OS.get_ticks_msec()
	#	set_state("fall")
		
	if movementInput == 0:
		#if your not pressing a move button go idle
		set_state("idle")
	else:
		#if pressing move button start moving
		move_horizontally(0)
	
func run_exit_logic():
	pass
	
func fall_enter_logic():
	if previousState == "basicblast" or previousState == "spinningblast" or previousState == "ultimateblast":
		yield( Anim, "animation_finished")
	Anim.play("Fall") #play the fall animation
	print("Falling")

func fall_logic(delta):
	move_horizontally(airFriction) #move horizontally
	elapsedJumpBuffer = OS.get_ticks_msec() - jumpBufferStartTime #set elapsed time for jump buffer
	
	if isJumpPressed:
		#if you press jump
		if !isDoubleJumped && elapsedJumpBuffer > jumpBuffer:
			#and jump is pressed outside the jump buffer window, and this is your first double jump
			jump(doubleJumpVelocity) #apply double jump velocity
			set_state("double_jump") #set state to double jump
		
		if elapsedJumpBuffer < jumpBuffer:
			#if your in the jump buffer window
			if previousState == "run":
				#and your previpus state is run
				jump(jumpVelocity) #jump with ground velocity
				set_state("jump") #set state to jump
			if previousState == "wall_slide":
				#and your previous state is wall slide
				jump(wallJumpVelocity) #jump with wall jump velocity
				set_state("wall_jump") #set state to wall jump
				
	if isFloatPressed:
		set_float_physics() 
		set_state("float")
	
	if isFallFastPressed:
		set_fallfast_physics() 
		set_state("fallfast")
		
	check_for_attack()
		
	if isDashPressed && canDash:
		#dash if you press dash button
		set_state("dash")
	
	if is_on_floor():
		#if player is on a floor
		set_state("run") #set state to run (we set to run to keep momentum)
		isDoubleJumped = false #reset is double jumped
		
	if LeftRaycast.is_colliding() && movementInput == -1 || RightRaycast.is_colliding() && movementInput == 1:
		#if your raycast is coliding and you are trying to move in that direction
		set_state("wall_slide")
	

func fall_exit_logic():
	jumpBufferStartTime = 0 #reset jump buffer start time

func float_enter_logic():
	if previousState == "basicblast" or previousState == "spinningblast" or previousState == "ultimateblast":
		yield( Anim, "animation_finished")
	Anim.play("Float") #play the fall animation
	print("Floating")

func float_logic(delta):
	move_horizontally(airFriction) #move horizontally
	elapsedJumpBuffer = OS.get_ticks_msec() - jumpBufferStartTime #set elapsed time for jump buffer
	
	if isDashPressed && canDash:
		#dash if you press dash button
		set_state("dash")
	
	if isFallFastPressed:
		set_fallfast_physics() 
		set_state("fallfast")
		
	check_for_attack()
	if is_on_floor():
		#if player is on a floor
		set_state("run") #set state to run (we set to run to keep momentum)
		isDoubleJumped = false #reset is double jumped
		
	if LeftRaycast.is_colliding() && movementInput == -1 || RightRaycast.is_colliding() && movementInput == 1:
		#if your raycast is coliding and you are trying to move in that direction
		set_state("wall_slide")

func float_exit_logic():
	jumpBufferStartTime = 0 #reset jump buffer start time

func fallfast_enter_logic():
	if previousState == "basicblast" or previousState == "spinningblast" or previousState == "ultimateblast":
		yield( Anim, "animation_finished")
	Anim.play("Fall") #play the fall animation
	print("Falling Fast")
	
func fallfast_logic(delta):
	move_horizontally(airFriction) #move horizontally
	elapsedJumpBuffer = OS.get_ticks_msec() - jumpBufferStartTime #set elapsed time for jump buffer
	
	if isJumpPressed:
		#if you press jump
		if !isDoubleJumped && elapsedJumpBuffer > jumpBuffer:
			#and jump is pressed outside the jump buffer window, and this is your first double jump
			jump(doubleJumpVelocity) #apply double jump velocity
			set_state("double_jump") #set state to double jump
		
		if elapsedJumpBuffer < jumpBuffer:
			#if your in the jump buffer window
			if previousState == "run":
				#and your previpus state is run
				jump(jumpVelocity) #jump with ground velocity
				set_state("jump") #set state to jump
			if previousState == "wall_slide":
				#and your previous state is wall slide
				jump(wallJumpVelocity) #jump with wall jump velocity
				set_state("wall_jump") #set state to wall jump
	
	if isDashPressed && canDash:
		#dash if you press dash button
		set_state("dash")
	
	if is_on_floor():
		#if player is on a floor
		set_state("run") #set state to run (we set to run to keep momentum)
		isDoubleJumped = false #reset is double jumped
		
	if LeftRaycast.is_colliding() && movementInput == -1 || RightRaycast.is_colliding() && movementInput == 1:
		#if your raycast is coliding and you are trying to move in that direction
		set_state("wall_slide")

func fallfast_exit_logic():
	jumpBufferStartTime = 0 #reset jump buffer start time

func basicblast_enter_logic():
	if isattacking == false:
		emit_signal("magicaian_basic_blast_used", 1)
		Anim.play("Attack") #play the fall animation	
		print("Attacking")
		#Toggle isattacking, to stop this state's logic to be called on the next few physic tiks while waiting for the animation
		isattacking = true
	
func basicblast_logic(delta):
	mana -= basicblast_manacost
	_set_mana(mana)
	$E_Cooldown_Timer.start(e_cooldown)
	$E_Animation_Timer.start(e_animation_duration)
	apply_attack_physics()
	isattacking = false
	isEPressed = false
	#Wait for the attack animation to finish before anything else
	var basicBlast = E_BASICBLAST.instance()
	if $FireballShootPosition.position.x > $PlayerPosition.position.x :
		basicBlast.set_fireball_direction(1)
	else:
		basicBlast.set_fireball_direction(-1)
	get_parent().add_child(basicBlast)
	basicBlast.position = $FireballShootPosition.global_position
	set_state(previousState)
	
	
func basicblast_exit_logic():
	pass
	
func spinningblast_enter_logic():
	if isattacking == false:
		emit_signal("magicaian_spinning_blast_used", 1)
		Anim.play("Attack") #play the fall animation	
		print("Attacking")
		#Toggle isattacking, to stop this state's logic to be called on the next few physic tiks while waiting for the animation
		isattacking = true
	
func spinningblast_logic(delta):
	mana -= spinningblast_manacost
	_set_mana(mana)
	$W_Cooldown_Timer.start(w_cooldown)
	$E_Animation_Timer.start(e_animation_duration)
	apply_attack_physics()
	isattacking = false
	isWPressed = false
	#Wait for the attack animation to finish before anything else
	var spinningBlast = W_SPINNINGBLAST.instance()
	if $FireballShootPosition.position.x > $PlayerPosition.position.x :
		spinningBlast.set_fireball_direction(1)
	else:
		spinningBlast.set_fireball_direction(-1)
	get_parent().add_child(spinningBlast)
	spinningBlast.position = $FireballShootPosition.global_position
	set_state(previousState)	
	
func spinningblast_exit_logic():
	pass

func ultimateblast_enter_logic():
	if isattacking == false:
		emit_signal("magicaian_ultimate_blast_used", 1)
		Anim.play("Attack") #play the fall animation	
		print("Attacking")
		#Toggle isattacking, to stop this state's logic to be called on the next few physic tiks while waiting for the animation
		isattacking = true
	
func ultimateblast_logic(delta):
	mana -= ultimateblast_manacost
	_set_mana(mana)
	$R_Cooldown_Timer.start(r_cooldown)
	$E_Animation_Timer.start(e_animation_duration)
	apply_attack_physics()
	isattacking = false
	isRPressed = false
	#Wait for the attack animation to finish before anything else
	var ultimateBlast = R_ULTIMATEBLAST.instance()
	if $FireballShootPosition.position.x > $PlayerPosition.position.x :
		ultimateBlast.set_fireball_direction(1)
	else:
		ultimateBlast.set_fireball_direction(-1)
	get_parent().add_child(ultimateBlast)
	ultimateBlast.position = $FireballShootPosition.global_position
	set_state(previousState)	
	
func ultimateblast_exit_logic():
	pass

func block_enter_logic():
	if isattacking == false:
		emit_signal("block_used", 1)
		Anim.play("Shield") #play the fall animation	
		print("Blocking")
		#Toggle isattacking, to stop this state's logic to be called on the next few physic tiks while waiting for the animation
		isattacking = true
	
func block_logic(delta):
	mana -= block_manacost
	_set_mana(mana)
	$D_Cooldown_Timer.start(d_cooldown)
	$E_Animation_Timer.start(e_animation_duration)
	apply_attack_physics()
	isattacking = false
	isDPressed = false
	#Wait for the attack animation to finish before anything else
	var shield = D_SHIELD.instance()
	if $FireballShootPosition.position.x > $PlayerPosition.position.x :
		shield.set_shield_direction(1)
	else:
		shield.set_shield_direction(-1)
	get_parent().add_child(shield)
	shield.position = $FireballShootPosition.global_position
	set_state(previousState)	
	
func block_exit_logic():
	pass
	
func apply_attack_physics():
	#do not allow the person to move left or right while attacking
	velocity.x = 0

func dash_enter_logic():
	$DashSound.play()
	emit_signal("magicaian_dash_used", 1)
	mana -= dash_manacost
	_set_mana(mana)
	dashDirection = lastDirection #set dash direction (we use lastDirection to make sure we dash even when idle)
	dashStartTime = OS.get_ticks_msec() #set dash start time to total ticks since the game started
	
	velocity = Vector2.ZERO #set velocity to zero
	Anim.play("Dash") #play the idle animation (I also use it for the dash)

func dash_logic(delta):
	elapsedDashTime = OS.get_ticks_msec() - dashStartTime #set elapsed dash time
	
	velocity.x += dashSpeed * dashDirection #add dash speed to velocity and multiply by dash direction
	
	if elapsedDashTime > dashDurration: 
		#if elapsed dash time is greater then the dash durration
		set_state(previousState) #go back to the previous state

func dash_exit_logic():
	velocity = Vector2.ZERO  #reset velocity to zero
	if !is_on_floor():
		canDash = false #limit the amount of air dashes someone can do
	
	PlayerSprite.modulate = Color.white #untint the sprite

func jump_enter_logic():
	if previousState == "basicblast" or previousState == "spinningblast" or previousState == "ultimateblast":
		yield( Anim, "animation_finished")
	Anim.play("Jump") #play jump animation
	print("Jumping")

func jump_logic(delta):
	move_horizontally(airFriction) #move horizontally and subtract airfriction from max speed
	
	if velocity.y < 0:
		#if you are rising
		if isJumpReleased:
			#and you release jump button
			#and you release jump button
			velocity.y /= 2 #lower velocity
			
		if isJumpPressed && !isDoubleJumped:
			#if its your first time double jumping and you press the jump button
			jump(doubleJumpVelocity)  #apply double jump velocity
			set_state("double_jump") #set state to double jump
		
		if isDashPressed && canDash:
			#if you can dash and you press the dash button
			set_state("dash") #set state to dash
		
		if isFloatPressed && !isfloating:
			set_float_physics() #jump with ground velocity
			set_state("float")

		check_for_attack()
		
		if isFallFastPressed:
			set_fallfast_physics() 
			set_state("fallfast")
			 
		if is_on_ceiling():
			#if you hit a ceiling
			set_state("fall") #start falling
	else:
		#if you are no longer rising
		set_state("fall") #fall
	
func jump_exit_logic():
	pass

func double_jump_enter_logic():
	if previousState == "basicblast" or previousState == "spinningblast" or previousState == "ultimateblast":
		yield( Anim, "animation_finished")
	isDoubleJumped = true #make sure you can only double jump once
	Anim.play("Double Jump") #play double jump animation

func double_jump_logic(delta):
	move_horizontally(airFriction) #move horizontally and subtract airfriction from max speed
	
	if velocity.y < 0:
		#if you are rising
		if isJumpReleased:
			#and you release jump button lower velocity
			velocity.y /= 2
		
		if isFloatPressed:
			set_float_physics() #jump with ground velocity
			set_float_physics() #jump with ground velocity
			set_state("float")
		
		if isDashPressed && canDash:
			#and you press dash button and you can dash
			set_state("dash") #dash
		
		if isEPressed and $E_Cooldown_Timer.is_stopped():
			#e if you press button
			set_state("basicblast")
		
		if is_on_ceiling():
			#and you hit a ceiling 
			set_state("fall") #fall
	else:
		#if you are no longer rising
		set_state("fall") #fall

func double_jump_exit_logic():
	pass

func wall_slide_enter_logic():
	velocity = Vector2.ZERO #reset velocity to stop all momentum
	Anim.play("Wall Slide") #play wall slide animation
	print("Wall Sliding")

func wall_slide_logic(delta):
	velocity.y = wallSlideSpeed #override apply_gravity and apply a constant slide speed
	
	if LeftRaycast.is_colliding() && movementInput != -1 || RightRaycast.is_colliding() && movementInput != 1:
		#if your raycast is coliding and you are trying to move in that direction
		jumpBufferStartTime = OS.get_ticks_msec() #start jump buffer timer
		set_state("fall") #set state to fall
	#this could be done in one long if statement but I split it up to make it easiar to read
	if !LeftRaycast.is_colliding() && movementInput == -1 || !RightRaycast.is_colliding() && movementInput == 1:
		#if you are holding in a direction but no longer coliding with a wall in that direction
		set_state("fall")
	
	if is_on_floor():
		#if you hit the floor set state to idle
		jumpBufferStartTime = OS.get_ticks_msec() #start jump buffer timer
		set_state("idle")
		
	if isDashPressed:
		#dash if you press dash button
		set_state("dash")
	
	if isJumpPressed:
		jump(wallJumpVelocity) #jump with walljump y velocity
		set_state("wall_jump")

func wall_slide_exit_logic():
	isDoubleJumped = false #allow you to double jump again when you wall jump 


func wall_jump_enter_logic():
	currentSpeed = 0 #erase momentum form run
	Anim.play("Jump") #play jump animation
	print("Wall Jumping")

func wall_jump_logic(delta):
	move_horizontally(airFriction) #move horizontally
	
	#if you want to add a wall jump thrust you can do so by:
	#deifining a wallJumpThrust variable
	#and putting velocity.x += wallJumpThrust * lastDirection here
	
	if velocity.y < 0:
		#if you are rising
		if isJumpReleased:
			#and you release jump button lower velocity
			velocity.y /= 2
			
		if isJumpPressed && !isDoubleJumped:
			#doublejump if you press button and its your first timme double jumping
			#we use isJumpPressed here instead of jumpInput so we dont imeadiatly double jump when we originaly jump
			jump(doubleJumpVelocity) 
			set_state("double_jump")
		
		if isDashPressed:
			set_state("dash")
		
		if isEPressed and $E_Cooldown_Timer.is_stopped():
			#e if you press button
			set_state("basicblast")
			
		if is_on_ceiling():
			#and you hit a ceiling fall
			set_state("fall")
	else:
		#if your not rising
		set_state("fall")

func wall_jump_exit_logic():
	canDash = true #allow the players to dash again if they wall jump

func damage(damagetaken, knockbackdirection):
	$SlimeDamagePlayer.play()
	#reset modulate just in case
	modulate = Color(1, 1, 1)
	Anim.play("Damage")
	health = health - damagetaken
	var knockbackvelocity = Vector2.ZERO
	knockbackvelocity.x = 400 * knockbackdirection
	velocity = move_and_slide(knockbackvelocity, Vector2.UP)
	#Kill the Player
	if health == 0:
		is_damaged = true
		#Figure out which way to get hurt
		velocity = Vector2(0, 0)
		$CollisionShape2D.disabled = true
		$Timer.start(.5)
	_set_health(health)
	yield( Anim, "animation_finished")
	Anim.play("Idle")

func _set_health(sethealth):
	emit_signal("health_changed", sethealth)

func _set_mana(setmana):
	emit_signal("mana_changed", setmana)
	
func _add_mana(mana_to_add):
	mana += mana_to_add
	if mana > MAX_MANA:
		mana = MAX_MANA
	emit_signal("mana_changed", mana)

func _add_health(health_to_add):
	health += health_to_add
	if health > MAX_HEALTH:
		health = MAX_HEALTH
	emit_signal("health_changed", health)

func awaitingOnAnimations():
	if $E_Animation_Timer.is_stopped():
		return false
	else:
		return true

func _on_Timer_timeout():
	get_tree().change_scene("res://Objects/YouAreDead.tscn")


func _on_Player_magicaian_basic_blast_used(value):
	pass # Replace with function body.
