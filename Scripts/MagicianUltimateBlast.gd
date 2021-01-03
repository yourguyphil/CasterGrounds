extends Area2D

const SPEED = 300
var velocity = Vector2()
var direction = 1
var is_shot = false
var damage = 3
var list_of_enemies_hit = []

func _ready():
	$UltimateBlastSound.play()
	#TBH might have problems with this, trying to delay the fireball
	var t = Timer.new()
	t.set_wait_time(.3)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	t.queue_free()
	

func set_fireball_direction(dir):
	direction = dir
	if dir == -1:
		$AnimatedSprite.flip_h = true

func _physics_process(delta):
	velocity.x = SPEED * delta * direction
	translate(velocity)
		
	if is_shot == false:
		$AnimatedSprite.play("initialshot")
		is_shot = true
	else:
		$AnimatedSprite.play("shoot")


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_Fireball_body_entered(body):
	if "Enemy" in body.name and !body.name in list_of_enemies_hit:
		list_of_enemies_hit.append(body.name)
		body.dead(damage, direction, 2)
