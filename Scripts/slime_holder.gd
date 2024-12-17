extends Node2D

var slime_pieces = []
var width = 8
var height = 10
var slime = preload("res://Scenes/obstacles/slime.tscn")

signal remove_slime


#Creates a 2d array for x and y coords
func make_2d_array() -> Array:
	var array = []
	for i in width:
		array.append([]);
		for j in height:
			array[i].append(null)
	return array
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_grid_damage_slime(board_position):
	if slime_pieces.size() != 0:
		if slime_pieces[board_position.x][board_position.y] != null:
			slime_pieces[board_position.x][board_position.y].take_damage(1)
			if slime_pieces[board_position.x][board_position.y].health <= 0:
				slime_pieces[board_position.x][board_position.y].queue_free()
				slime_pieces[board_position.x][board_position.y] = null
				emit_signal("remove_slime" , board_position)


func _on_grid_make_slime(board_position):
	if slime_pieces.size() == 0:
		slime_pieces = make_2d_array()
	var current = slime.instantiate()
	add_child(current)
	current.position = Vector2(board_position.x * 64 + 64, -board_position.y * 64 + 820)
	slime_pieces[board_position.x][board_position.y] = current
