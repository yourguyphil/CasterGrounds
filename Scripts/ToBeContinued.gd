extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Menu/QuitButton.grab_focus() 
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $Menu/QuitButton.is_hovered() == true:
		$Menu/QuitButton.grab_focus()
	pass

func _on_QuitButton_pressed():
	get_tree().change_scene("res://Levels/TitleScreen.tscn")
	pass # Replace with function body.
