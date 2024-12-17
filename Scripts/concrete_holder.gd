extends Node2D

var concrete_pieces = []
var width = 8
var height = 10
var concrete = preload("res://Scenes/obstacles/concrete.tscn")

signal remove_concrete

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


func _on_grid_damage_concrete(board_position) -> void:
	if concrete_pieces.size() != 0:
		if concrete_pieces[board_position.x][board_position.y] != null:
			concrete_pieces[board_position.x][board_position.y].take_damage(1)
			if concrete_pieces[board_position.x][board_position.y].health <= 0:
				concrete_pieces[board_position.x][board_position.y].queue_free()
				concrete_pieces[board_position.x][board_position.y] = null
				emit_signal("remove_concrete" , board_position)


func _on_grid_make_concrete(board_position) -> void:
	if concrete_pieces.size() == 0:
		concrete_pieces = make_2d_array()
	var current = concrete.instantiate()
	add_child(current)
	current.position = Vector2(board_position.x * 64 + 64, -board_position.y * 64 + 820)
	concrete_pieces[board_position.x][board_position.y] = current
