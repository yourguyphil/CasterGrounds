extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var collect = false
var mana_restore_value = 7

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("Idle")
	pass # Replace with function body.

func _on_Area2D_body_entered(body):
	if(body.get("TYPE") == "player") && collect == false:
		collect = true
		$AnimationPlayer.play("Collect")
		$PickUpSound.play()
		body._add_mana(mana_restore_value)
	pass # Replace with function body.
