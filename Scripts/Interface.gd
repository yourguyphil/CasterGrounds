extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var healthbar = get_node("UIBars/HealthBar") 
onready var healthlabel = get_node("UIBars/HealthLabel") 
onready var manabar = get_node("UIBars/ManaBar") 
onready var manalabel = get_node("UIBars/ManaLabel") 


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Player_health_changed(new_value):
	healthbar.value = new_value
	healthlabel.text = str(new_value)
	pass # Replace with function body.


func _on_Player_mana_changed(new_value):
	manabar.value = new_value
	manalabel.text = str(new_value)
	pass # Replace with function body.


func _on_Player_magicaian_basic_blast_used(value):
	$AbilityButtonE.disabled = true
	$AbilityButtonE.set_process(true)
	$AbilityButtonE/Timer.start()
	$AbilityButtonE/Counter/Value.show()
	pass # Replace with function body.


func _on_Player_magicaian_spinning_blast_used(value):
	$AbilityButtonW.disabled = true
	$AbilityButtonW.set_process(true)
	$AbilityButtonW/Timer.start()
	$AbilityButtonW/Counter/Value.show()
	pass # Replace with function body.


func _on_Player_magicaian_ultimate_blast_used(value):
	$AbilityButtonR.disabled = true
	$AbilityButtonR.set_process(true)
	$AbilityButtonR/Timer.start()
	$AbilityButtonR/Counter/Value.show()
	pass # Replace with function body.


func _on_Player_magicaian_dash_used(value):
	$AbilityButtonQ.disabled = true
	$AbilityButtonQ.set_process(true)
	$AbilityButtonQ/Timer.start()
	$AbilityButtonQ/Counter/Value.show()
	pass # Replace with function body.


func _on_Player_block_used(value):
	$AbilityButtonD.disabled = true
	$AbilityButtonD.set_process(true)
	$AbilityButtonD/Timer.start()
	$AbilityButtonD/Counter/Value.show()
	pass # Replace with function body.
