extends Node2D

func _ready():
	$Menu/StoryButton.grab_focus() 
	

func _physics_process(delta):
	$AnimationPlayer.play("Idle")
	if $Menu/StoryButton.is_hovered() == true:
		$Menu/StoryButton.grab_focus()
	if $Menu/PracticeButton.is_hovered() == true:
		$Menu/PracticeButton.grab_focus()
	if $Menu/PlayButton.is_hovered() == true:
		$Menu/PlayButton.grab_focus()
	if($AudioStreamPlayer2D.playing == false):
		$AudioStreamPlayer2D.play()
		pass

func _on_StoryButton_pressed():
	get_tree().change_scene("res://Levels/TutorialStage.tscn")

func _on_PracticeButton_pressed():
	get_tree().change_scene("res://Levels/PracticeStage.tscn")

func _on_PlayButton_pressed():
	pass # Replace with function body.

func _on_CreditsButton_pressed():
	get_tree().change_scene("res://Objects/Credits.tscn")
