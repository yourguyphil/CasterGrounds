extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Menu/QuitButton.grab_focus() 
	pass # Replace with function body.

func _physics_process(delta):
	if($CreditsMusic.playing == false):
		$CreditsMusic.play()
		pass

func _on_QuitButton_pressed():
	get_tree().change_scene("res://Levels/TitleScreen.tscn")
	get_tree().paused = false
	pass # Replace with function body.
