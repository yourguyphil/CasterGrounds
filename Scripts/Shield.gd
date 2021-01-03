extends Area2D

const SHIELD_DURATION = 2
var direction = 1

func _ready():
	$ShieldSound.play()
	$ShieldDuration.start(SHIELD_DURATION)
	pass

func set_shield_direction(dir):
	direction = dir
	if dir == -1:
		$AnimatedSprite.flip_h = true

func _process(delta):
	$AnimatedSprite.play("Shield")
	if $ShieldDuration.is_stopped():
		$CollisionShape2D.hide()
		$AnimatedSprite.hide()
		#yield($ShieldSound, "finished")
		queue_free()

func _on_MagicianShield_body_entered(body):
	if "Player" in body.name:
		#Disable the look and colisonbox but ensure sound effect is finished before freeing the object
		$CollisionShape2D.hide()
		$AnimatedSprite.hide()
		#yield($BasicBlastSound, "finished")
		queue_free()
	if "Enemy" in body.name and !"Mana" in body.name and !"Health" in body.name:
		body.colide_with_something()
		#Disable the look and colisonbox but ensure sound effect is finished before freeing the object
		$CollisionShape2D.hide()
		$AnimatedSprite.hide()
		#yield($BasicBlastSound, "finished")
		queue_free()
