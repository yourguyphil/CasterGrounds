extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Menu/ResumeButton.grab_focus() 
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $Menu/ResumeButton.is_hovered() == true:
		$Menu/ResumeButton.grab_focus()
	if $Menu/QuitButton.is_hovered() == true:
		$Menu/QuitButton.grab_focus()
	pass

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		reenable_game()

func reenable_game():
	$Menu/ResumeButton.grab_focus()
	get_tree().paused = not get_tree().paused
	visible = not visible

func _on_ResumeButton_pressed():
	reenable_game()
	pass # Replace with function body.

func _on_QuitButton_pressed():
	get_tree().change_scene("res://Levels/TitleScreen.tscn")
	get_tree().paused = false
	pass # Replace with function body.
