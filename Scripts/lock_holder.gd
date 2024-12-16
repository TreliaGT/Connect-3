extends Node2D

var lock_pieces = []
var width = 8
var height = 10
var lock = preload("res://Scenes/obstacles/locks.tscn")

signal remove_lock
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

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


func _on_grid_make_lock(board_position) -> void:
	if lock_pieces.size() == 0:
		lock_pieces = make_2d_array()
	var current = lock.instantiate()
	add_child(current)
	current.position = Vector2(board_position.x * 64 + 64, -board_position.y * 64 + 820)
	lock_pieces[board_position.x][board_position.y] = current


func _on_grid_damage_lock(board_position) -> void:
	if lock_pieces[board_position.x][board_position.y] != null:
		lock_pieces[board_position.x][board_position.y].take_damage(1)
		if lock_pieces[board_position.x][board_position.y].health <= 0:
			lock_pieces[board_position.x][board_position.y].queue_free()
			lock_pieces[board_position.x][board_position.y] = null
			emit_signal("remove_lock" , board_position)
