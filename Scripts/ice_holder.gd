extends Node2D

var ice_pieces = []
var width = 8
var height = 10
var ice = preload("res://Scenes/obstacles/ice.tscn")

func _ready() -> void:
	pass

#Creates a 2d array for x and y coords
func make_2d_array() -> Array:
	var array = []
	for i in width:
		array.append([]);
		for j in height:
			array[i].append(null)
	return array

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
	
func _on_grid_make_ice(board_position) -> void:
	if ice_pieces.size() == 0:
		ice_pieces = make_2d_array()
	var current = ice.instantiate()
	add_child(current)
	current.position = Vector2(board_position.x * 64 + 64, -board_position.y * 64 + 820)
	ice_pieces[board_position.x][board_position.y] = current

func _on_grid_damage_ice(board_position) -> void:
	if ice_pieces.size() != 0:
		if ice_pieces[board_position.x][board_position.y] != null:
			ice_pieces[board_position.x][board_position.y].take_damage(1)
			if ice_pieces[board_position.x][board_position.y].health <= 0:
				ice_pieces[board_position.x][board_position.y].queue_free()
				ice_pieces[board_position.x][board_position.y] = null
