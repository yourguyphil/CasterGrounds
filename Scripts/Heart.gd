extends KinematicBody2D

const GRAVITY = 10
var velocity = Vector2()
const FLOOR = Vector2(0, -1)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var collect = false
var health_restore_value = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("Idle")
	pass # Replace with function body.
	
func _physics_process(delta):
		
		velocity.y += GRAVITY
		
		velocity = move_and_slide(velocity, FLOOR)

func _on_Area2D_body_entered(body):
	if(body.get("TYPE") == "player") && collect == false:
		collect = true
		$AnimationPlayer.play("Collect")
		$PickUpSound.play()
		body._add_health(health_restore_value)
		yield($AnimationPlayer, "animation_finished")
		queue_free()
	pass # Replace with function body.
