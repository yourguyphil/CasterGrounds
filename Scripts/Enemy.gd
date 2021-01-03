extends KinematicBody2D

const GRAVITY = 10
const FLOOR = Vector2(0, -1)

var velocity = Vector2()

var direction = 1


export var can_jump = true
var is_dead = false
var is_hurt = false
var is_floating = false
var is_jumping = false
var rng = RandomNumberGenerator.new()

var knockback = Vector2(1000 , 0)
const KNOCKBACK_VELOCITY = 25

export(int) var speed = 30

export(int) var hp = 1

export(Vector2) var size = Vector2(1, 1)

var damage_direction = 1

var jump_ray_check_cooldown = 2

func _ready():
	scale = size
	pass

func colide_with_something():
	direction = direction * -1
	$RayCast2D.position.x *= -1

func dead(damage, damage_direction, knockbackfactor):
	if !is_dead :
		$DamgedAudio.play()
		hp = hp - damage
		
		var modifiedknockback = knockback * knockbackfactor
		
		move_and_slide(modifiedknockback * damage_direction)
		
		if hp <= 0:
			collision_layer = 8
			collision_mask = 1
			is_dead = true
			velocity = Vector2(0, 0)    
			$DeathAudio.play()          
			$AnimatedSprite.play("dead")
			$Timer.start()
			#Commented out to allow the enemy to fall to the floor
			#$CollisionShape2D.set_deferred("disabled", true)
			if size.x > 3:
				get_parent().get_node("Screenshake").screen_shake(1, 10, 100)
		else:
			is_hurt = true

func _physics_process(delta):
	
	if is_dead == false:
		
		velocity.x = speed * direction
		
		if is_on_floor():
			is_jumping = false
			$RayCast2D.enabled = true
		
		if is_hurt == false:
			$AnimatedSprite.play("walk")
		else:
			$AnimatedSprite.play("hurt")
		
		if is_jumping == false:
			#Randomly Jump
			rng.randomize()
			var my_random_number = rng.randi_range(1, 100)
			if can_jump and my_random_number == 1:
				#Try to mitigate weird flickering of ray checks after a jump to a corner
				$TimerJumpRayCheck.start(jump_ray_check_cooldown)
				#random the jump velocity
				var random_jump = rng.randi_range(200, 300)
				var jumpvelocity = velocity
				jumpvelocity.y += -random_jump
				velocity = move_and_slide(jumpvelocity, Vector2.UP)
				$AnimatedSprite.play("jump")
				is_jumping = true
			if direction == 1:
				$AnimatedSprite.flip_h = false
			else:
				$AnimatedSprite.flip_h = true

		velocity.y += GRAVITY
		
		velocity = move_and_slide(velocity, Vector2.UP)
	else:
		#Force the Enemy to fall to the ground
		velocity.x = 0
		velocity.y += GRAVITY
		velocity = move_and_slide(velocity, Vector2.DOWN)
	

	if is_on_wall():
		direction = direction * -1
		$RayCast2D.position.x *= -1
		
	if $RayCast2D.is_colliding() == false and is_jumping == false and $TimerJumpRayCheck.is_stopped():
		direction = direction * -1
		$RayCast2D.position.x *= -1
	
	if get_slide_count() > 0:
		for i in range (get_slide_count()):
			if "Player" in get_slide_collision(i).collider.name:
					var knockbackdirection 
					var positionslime = $EnemyPosition.global_position.x
					var positionplayer = get_slide_collision(i).get_position().x
					
					if positionplayer > positionslime:
						knockbackdirection = 1
					else:
						knockbackdirection = -1
					
					get_slide_collision(i).collider.damage(1, knockbackdirection)
					

func _on_Timer_timeout():
	queue_free()

func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation != 'walk' && $AnimatedSprite.animation != 'dead' :
		$AnimatedSprite.play('walk')
		is_hurt = false

func _on_DetectPlayer_body_entered(body):
	#Aggro to the Playert
	pass # Replace with function body.
