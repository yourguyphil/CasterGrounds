extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

var is_disabled = false

func _on_Q_pressed():
	Input.action_press("dash")
	pass # Replace with function body.


func _on_Q_released():
	Input.action_release("dash")
	pass # Replace with function body.


func _on_W_pressed():
	Input.action_press("w")
	pass # Replace with function body.


func _on_W_released():
	Input.action_release("w")
	pass # Replace with function body.


func _on_E_pressed():
	Input.action_press("e")
	pass # Replace with function body.


func _on_E_released():
	Input.action_release("e")
	pass # Replace with function body.


func _on_Space_pressed():
	Input.action_press("jump")
	pass # Replace with function body.


func _on_Space_released():
	Input.action_release("jump")
	pass # Replace with function body.


func _on_D_pressed():
	Input.action_press("d")
	pass # Replace with function body.


func _on_D_released():
	Input.action_release("d")
	pass # Replace with function body.


func _on_R_pressed():
	Input.action_press("r")
	pass # Replace with function body.


func _on_R_released():
	Input.action_release("r")
	pass # Replace with function body.


func _on_Up_pressed():
	Input.action_press("up")
	pass # Replace with function body.


func _on_Up_released():
	Input.action_release("up")
	pass # Replace with function body.


func _on_Right_pressed():
	Input.action_press("right")
	pass # Replace with function body.


func _on_Right_released():
	Input.action_release("right")
	pass # Replace with function body.


func _on_Down_pressed():
	Input.action_press("down")
	pass # Replace with function body.


func _on_Down_released():
	Input.action_release("down")
	pass # Replace with function body.


func _on_Left_pressed():
	Input.action_press("left")
	pass # Replace with function body.


func _on_Left_released():
	Input.action_release("left")
	pass # Replace with function body.


func _on_Controls_pressed():
	
	if is_disabled != true:
		$Q.hide()
		$W.hide()
		$E.hide()
		$D.hide()
		$R.hide()
		$Space.hide()
		$Up.hide()
		$Down.hide()
		$Left.hide()
		$Right.hide()
		is_disabled = true
	else:
		$Q.show()
		$W.show()
		$E.show()
		$D.show()
		$R.show()
		$Space.show()
		$Up.show()
		$Down.show()
		$Left.show()
		$Right.show()
		is_disabled = false
	pass # Replace with function body.


func _on_Controls_released():
	
	pass # Replace with function body.
