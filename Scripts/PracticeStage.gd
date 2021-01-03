extends Node2D

const ENEMY = preload("res://Objects/Enemy.tscn")
const MANA = preload("res://Objects/ManaRegenCrystal.tscn")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if $StageMusic.playing == false:
		$StageMusic.play()
		pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
		
func _on_BasicTarget_spawn_enemy(value):
	var enemy_instance = ENEMY.instance()
	enemy_instance.position = $SpawnPoint.global_position
	add_child(enemy_instance)



func _on_MPSpawn_spawn_mana(value):
	var mana_instance = MANA.instance()
	mana_instance.position = $SpawnPoint2.global_position
	add_child(mana_instance)
