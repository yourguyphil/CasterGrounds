extends Area2D

const SPEED = 150
var velocity = Vector2()
var direction = 1

func _ready():
	$BasicBlastSound.play()
	pass

func set_fireball_direction(dir):
	direction = dir
	if dir == -1:
		$AnimatedSprite.flip_h = true

func _physics_process(delta):
	velocity.x = SPEED * delta * direction
	translate(velocity)
	$AnimatedSprite.play("shoot")


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _on_MagicianBasicBlast_body_entered(body):
	if "Enemy" in body.name:
		body.dead(1, direction, 1)
		queue_free()
	if !"Player" in body.name:
		#Disable the look and colisonbox but ensure sound effect is finished before freeing the object
		$CollisionShape2D.hide()
		$AnimatedSprite.hide()
		yield($BasicBlastSound, "finished")
		queue_free()
	
