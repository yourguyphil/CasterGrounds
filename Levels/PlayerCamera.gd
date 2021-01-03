extends Camera2D

func _auto_set_limits():
	limit_left = 0
	limit_right = 0
	limit_bottom = 0
	
	var tilemaps = get_tree().get_nodes_in_group("tilemap")
	for tilemap in tilemaps:
		if tilemap is TileMap:
			var used = tilemap.get_used_rect()
			limit_left = min(used.position.x * tilemap.cell_size.x, limit_left)
			limit_right = min(used.end.x * tilemap.cell_size.x, limit_right)
			limit_bottom = min(used.end.y * tilemap.cell_size.y, limit_bottom)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
