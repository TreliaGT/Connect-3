extends Node2D

# State Machine
enum{wait, move}
var state

#Grid Variables
var width = 8
var height = 10
@export var x_start : int
@export var y_start : int
@export var offset : int
@export var y_offset : int

#obstacle stuff
@export var empty_spaces : PackedVector2Array
@export var ice_spaces : PackedVector2Array
@export var lock_spaces : PackedVector2Array
@export var concrete_spaces : PackedVector2Array
@export var slime_spaces : PackedVector2Array
var damaged_slime = false

#obstacle Signals
signal damage_ice
signal make_ice

signal damage_lock
signal make_lock

signal damage_concrete
signal make_concrete

signal damage_slime
signal make_slime

# The Piece Array
var possible_pieces = [
	preload("res://Scenes/pieces/blue_piece.tscn"),
	preload("res://Scenes/pieces/green_piece.tscn"),
	preload("res://Scenes/pieces/light_green_piece.tscn"),
	preload("res://Scenes/pieces/orange_piece.tscn"),
	preload("res://Scenes/pieces/pink_piece.tscn"),
	preload("res://Scenes/pieces/yellow_piece.tscn")
]

# the current pieces in the scene
var all_pieces = []
var current_matches = []

#swap back var
var piece_one = null
var piece_two = null
var last_place = Vector2(0,0)
var last_direction = Vector2(0,0)
var move_check = false

#touch varicles
var first_touch = Vector2(0,0)
var final_touch = Vector2(0,0)
var controlling = false

#scoring Var
signal update_score
@export var piece_value : int
var streak = 1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state = move
	randomize()
	all_pieces = make_2d_array()
	spawn_pieces()
	spawn_ice()
	spawn_locks()
	spawn_concrete()
	spawn_slime()

#check non movable tiles
func restricted_fill(place) -> bool:
	if is_in_array(empty_spaces , place):
		return true
	if is_in_array(concrete_spaces , place):
		return true
	if is_in_array(slime_spaces , place):
		return true
	return false

func restricted_move(place):
	#lock pieces
	if is_in_array(lock_spaces, place):
		return true
	return false

#checking if item is array
func is_in_array(array, item):
	for i in array.size():
		if array[i] == item:
			return true
	return false
	
func remove_from_array(array,item):
	for i in range(array.size() -1, -1,-1):
		if array[i] == item:
			array.remove_at(i)
			break

#Creates a 2d array for x and y coords
func make_2d_array() -> Array:
	var array = []
	for i in width:
		array.append([]);
		for j in height:
			array[i].append(null)
	return array

#Spawns the pieces on the board
func spawn_pieces() -> void:
	for i in width:
		for j in height:
			if !restricted_fill(Vector2(i,j)):
				#choose random number
				var rand = floor(randf_range(0, possible_pieces.size()))
				#instance that piece from the array
				var piece = possible_pieces[rand].instantiate() 
				var _loops = 0
				while(match_at(i,j , piece.color)):
					rand = floor(randf_range(0, possible_pieces.size()))
					_loops += 1
					piece = possible_pieces[rand].instantiate()
				add_child(piece)
				piece.position = grid_to_pixel(i, j)
				all_pieces[i][j] = piece

#spawn ice
func spawn_ice():
	for i in ice_spaces.size():
		emit_signal("make_ice", ice_spaces[i])

#spawn locks
func spawn_locks():
	for i in lock_spaces.size():
		emit_signal("make_lock", lock_spaces[i])

#spawn concrete
func spawn_concrete():
	for i in concrete_spaces.size():
		emit_signal("make_concrete", concrete_spaces[i])

#spawn slime
func spawn_slime():
	for i in slime_spaces.size():
		emit_signal("make_slime", slime_spaces[i])

# works out where to display each piece
func grid_to_pixel(column , row) -> Vector2:
	var new_x = x_start + offset * column
	var new_y = y_start + -offset * row
	return Vector2(new_x, new_y)
	
func pixel_to_grid(pixel_x, pixel_y) -> Vector2:
	var new_x = round((pixel_x - x_start) / offset)
	var new_y = round((pixel_y - y_start) / -offset)
	return Vector2(new_x, new_y)
	
#Check if there are a match on spawn
func match_at(i, j, color: String) -> bool:
	if i > 1:
		if all_pieces[i-1][j] != null and all_pieces[i-2][j] != null:
			if all_pieces[i-1][j].color == color and all_pieces[i-2][j].color == color:
				return true
	if j > 1:
		if all_pieces[i][j-1] != null and all_pieces[i][j-2] != null:
			if all_pieces[i][j-1].color == color and all_pieces[i][j-2].color == color:
				return true
	return false

#checks if grid was selected
func is_in_grid(grid_position) -> bool:
	if grid_position.x >= 0 and grid_position.x < width:
		if grid_position.y >= 0 and grid_position.y < height:
			return true
	return false
			
#swap pieces
func swap_pieces(column,row, direction):
	var first_piece = all_pieces[column][row]
	var other_piece = all_pieces[column + direction.x][row + direction.y]
	if first_piece != null and other_piece != null:
		if !restricted_move(Vector2(column,row)) and !restricted_move(Vector2(column,row) + direction):
			if is_color_bomb(first_piece , other_piece):
				if first_piece.color == "color":
					match_color(other_piece.color)
					match_and_dim(first_piece)
					add_to_array(Vector2(column,row))
				else:
					match_color(first_piece.color)
					match_and_dim(other_piece)
					add_to_array(Vector2(column + direction.x,row + direction.y))
					
			store_info(first_piece ,other_piece , Vector2(column, row) , direction)
			state = wait
			all_pieces[column][row] = other_piece
			all_pieces[column + direction.x][row + direction.y] = first_piece
			first_piece.move(grid_to_pixel(column + direction.x , row + direction.y))
			other_piece.move(grid_to_pixel(column, row))
			if !move_check:
				find_matches()
		
#check colour bomb
func is_color_bomb(piece_1 , piece_2) -> bool:
	if piece_1.color == "color" or piece_2.color == "color":
		return true
	return false
	
#swaps pieces back when no matches
func swap_back():
	if piece_one != null and piece_two != null:
		swap_pieces(last_place.x , last_place.y, last_direction)
	state = move
	move_check = false

#stores last info
func store_info(first_piece , other_piece, place , direction):
	piece_one = first_piece
	piece_two = other_piece
	last_place = place
	last_direction = direction
	
func touch_difference(grid_1, grid_2):
	if grid_1 == null or grid_2 == null:
		print("Invalid Vector2 passed to touch_difference!")
		return  # Early exit if either is null
	var difference = grid_2 - grid_1
	if abs(difference.x) > abs(difference.y):
		if difference.x > 0:
			swap_pieces(grid_1.x , grid_1.y, Vector2(1,0))
		elif difference.x < 0:
			swap_pieces(grid_1.x , grid_1.y, Vector2(-1,0))
	elif abs(difference.y) > abs(difference.x):
		if difference.y > 0:
			swap_pieces(grid_1.x , grid_1.y, Vector2(0,1))
		elif difference.y < 0:
			swap_pieces(grid_1.x , grid_1.y, Vector2(0,-1))

#Input handler
func touch_input():
	var mouse = get_global_mouse_position()
	if Input.is_action_just_pressed("ui_touch"):
		if is_in_grid(pixel_to_grid(mouse.x, mouse.y)):
			controlling = true
			first_touch = pixel_to_grid(mouse.x, mouse.y)
	if Input.is_action_just_released("ui_touch"):
		if is_in_grid(pixel_to_grid(mouse.x, mouse.y)) and controlling:
			final_touch = pixel_to_grid(mouse.x, mouse.y)
			controlling = false
			touch_difference(first_touch ,final_touch)
			

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if state == move:
		touch_input()

#Finds matches after moving a piece
func find_matches():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				var current_color = all_pieces[i][j].color
				if i > 0 and i < width -1:
					if !is_piece_null(i-1,j) and !is_piece_null(i+1,j):
						if all_pieces[i-1][j].color == current_color &&  all_pieces[i + 1][j].color == current_color:
							match_and_dim(all_pieces[i-1][j])
							match_and_dim(all_pieces[i][j])
							match_and_dim(all_pieces[i+1][j])
							add_to_array(Vector2(i,j))
							add_to_array(Vector2(i-1,j))
							add_to_array(Vector2(i+1,j))
				if j > 0 and j < height -1:
					if !is_piece_null(i,j-1) and !is_piece_null(i,j+1):
						if all_pieces[i][j-1].color == current_color &&  all_pieces[i][j+1].color == current_color:
							match_and_dim(all_pieces[i][j-1])
							match_and_dim(all_pieces[i][j])
							match_and_dim(all_pieces[i][j+1])
							add_to_array(Vector2(i,j-1))
							add_to_array(Vector2(i,j))
							add_to_array(Vector2(i,j+1))
	get_bombed_pieces()
	get_parent().get_node("%destory_timer").start()

#get bombed
func get_bombed_pieces():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if all_pieces[i][j].matched:
					if all_pieces[i][j].is_column_bomb:
						match_all_in_column(i)
					elif all_pieces[i][j].is_row_bomb:
						match_all_in_row(j)
					elif all_pieces[i][j].is_adjacent_bomb:
						find_adjacent_pieces(i,j)
					
	
#adds to current matches
func add_to_array(value, array_to_add = current_matches):
	if !array_to_add.has(value):
		array_to_add.append(value)
	
#checks is piece is null
func is_piece_null(column, row):
	if all_pieces[column][row] == null:
		return true
	
#changes piece to dim once matched
func match_and_dim(item):
	item.matched = true
	item.dim()

#creates the bomb
func make_bomb(bomb_type , color):
	for i in current_matches.size():
		var current_column = current_matches[i].x
		var current_row = current_matches[i].y
		if all_pieces[current_column][current_row] == piece_one and piece_one.color == color:
			piece_one.matched = false
			change_bomb(bomb_type , piece_one)
		if all_pieces[current_column][current_row] == piece_two and piece_two.color == color:
			piece_two.matched = false
			change_bomb(bomb_type , piece_two)
			
func change_bomb(bomb_type , piece):
	if bomb_type == 0:
		piece.make_adjacemt_bombs()
	elif bomb_type == 1:
		piece.make_column_bomb()
	elif bomb_type == 2:
		piece.make_row_bomb()
	elif bomb_type == 3:
		piece.make_color_bomb()

#finds if bomb should be summoned
func find_bombs():
	for i in current_matches.size():
		var current_column = current_matches[i].x
		var current_row = current_matches[i].y
		var current_color = all_pieces[current_column][current_row].color
		var col_matched = 0
		var row_matched = 0
		#check for column, row , color
		for j in current_matches.size():
			var this_column = current_matches[j].x
			var this_row = current_matches[j].y
			var this_color = all_pieces[this_column][this_row].color
			if this_column == current_column and this_color == current_color:
				col_matched += 1
			if this_row == current_row and this_color == current_color:
				row_matched += 1
		
		#0 is adj bomb, 1 is a col bomb, 2 is a row bomb , 3 is a rainbow bomb
		if col_matched == 5 or row_matched == 5:
			make_bomb(3, current_color)
			return
		elif col_matched >= 3 and row_matched >= 3:
			make_bomb(0, current_color)
			return
		elif row_matched == 4:
			make_bomb(2, current_color)
			return
		elif col_matched == 4:
			make_bomb(1, current_color)
			return
	
		


#destory the matched pieces
func destory_matched():
	find_bombs()
	var was_matched = false
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if all_pieces[i][j].matched:
					damage_special(i,j)
					was_matched = true
					all_pieces[i][j].queue_free()
					all_pieces[i][j] = null
					emit_signal("update_score", piece_value * streak)
	move_check = true
	if was_matched:
		get_parent().get_node("%collapse_timer").start()
	else:
		swap_back()
	current_matches.clear()

func check_concrete(column,row):
	#check right
	if column < width -1:
		emit_signal("damage_concrete", Vector2(column+1,row))
	#check left
	if column > 0:
		emit_signal("damage_concrete", Vector2(column-1,row))
	#check up
	if row < height -1:
		emit_signal("damage_concrete", Vector2(column,row+1))
	#check down
	if row > 0:
		emit_signal("damage_concrete", Vector2(column,row-1))
	
func check_slime(column,row):
	#check right
	if column < width -1:
		emit_signal("damage_slime", Vector2(column+1,row))
	#check left
	if column > 0:
		emit_signal("damage_slime", Vector2(column-1,row))
	#check up
	if row < height -1:
		emit_signal("damage_slime", Vector2(column,row+1))
	#check down
	if row > 0:
		emit_signal("damage_slime", Vector2(column,row-1))

func damage_special(column,row):
	emit_signal("damage_ice" , Vector2(column,row))
	emit_signal("damage_lock", Vector2(column,row))
	check_concrete(column,row)
	check_slime(column,row)

#matches the color
func match_color(color):
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if all_pieces[i][j].color == color:
					all_pieces[i][j].matched = true
					match_and_dim(all_pieces[i][j])
					add_to_array(Vector2(i,j))
					
#clear board
func clear_board():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				all_pieces[i][j].matched = true
				match_and_dim(all_pieces[i][j])
				add_to_array(Vector2(i,j))
	
#moving the pieces down
func collapse_columns():
	for i in range(width):
		for j in range(height):
			if all_pieces[i][j] == null and !restricted_fill(Vector2(i,j)):
				for k in range(j + 1 , height):
					if all_pieces[i][k] != null:
						all_pieces[i][k].move(grid_to_pixel(i,j))
						all_pieces[i][j] = all_pieces[i][k]
						all_pieces[i][k] = null
						break
	get_parent().get_node("%refill_timer").start()
	
# refill the columns 
func refill_columns():
	streak += 1
	for i in width:
		for j in height:
			if all_pieces[i][j] == null && !restricted_fill(Vector2(i,j)):
				#choose random number
				var rand = floor(randf_range(0, possible_pieces.size()))
				#instance that piece from the array
				var piece = possible_pieces[rand].instantiate() 
				var _loops = 0
				while(match_at(i,j , piece.color)):
					rand = floor(randf_range(0, possible_pieces.size()))
					_loops += 1
					piece = possible_pieces[rand].instantiate()
				add_child(piece)
				piece.position = grid_to_pixel(i, j + y_offset)
				piece.move(grid_to_pixel(i, j));
				all_pieces[i][j] = piece
	after_refill()

#double checks the board for matches
func after_refill():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if match_at(i,j,all_pieces[i][j].color):
					find_matches()
					get_parent().get_node("%destory_timer").start()
					return
	if !damaged_slime:
		generate_slime()
	state = move
	streak = 1
	move_check = false
	damaged_slime = false

#checks if neighbour tile is normal tile
func find_normal_neighbour(column , row):
	#check right
	if is_in_grid(Vector2(column + 1 , row)):
		if all_pieces[column + 1] [row] !=null:
			return Vector2(column + 1 , row);
	#check left
	if is_in_grid(Vector2(column - 1 , row)):
		if all_pieces[column - 1] [row] !=null:
			return Vector2(column - 1 , row);
	#check up
	if is_in_grid(Vector2(column , row + 1)):
		if all_pieces[column] [row + 1] !=null:
			return Vector2(column , row + 1);
	#check down
	if is_in_grid(Vector2(column , row - 1)):
		if all_pieces[column] [row - 1] !=null:
			return Vector2(column , row - 1);
	return null

#generate new slime
func generate_slime():
	#check if slime are on the board
	if slime_spaces.size() > 0:
		var slime_made = false
		var tracker = 0
		while !slime_made && tracker < 100:
			#check a random slime
			var random_num = floor(randf_range(0, slime_spaces.size()))
			var curr_position = slime_spaces[random_num]
			var neighbour = find_normal_neighbour(curr_position.x , curr_position.y)
			#create slime on neighter
			if neighbour != null:
				all_pieces[neighbour.x][neighbour.y].queue_free()
				all_pieces[neighbour.x][neighbour.y] = null
				slime_spaces.append(Vector2(neighbour.x , neighbour.y))
				emit_signal("make_slime", Vector2(neighbour.x , neighbour.y))
				slime_made = true
			tracker += 1

#remove all pieces in column
func match_all_in_column(column):
	for i in height:
		if all_pieces[column][i] != null:
			if all_pieces[column][i].is_row_bomb:
				match_all_in_row(i)
			if all_pieces[column][i].is_adjacent_bomb:
				find_adjacent_pieces(column , i)
			all_pieces[column][i].matched = true

#remove all pieces in row
func match_all_in_row(row):
	for i in width:
		if all_pieces[i][row] != null:
			if all_pieces[i][row].is_column_bomb:
				match_all_in_column(i)
			if all_pieces[i][row].is_adjacent_bomb:
				find_adjacent_pieces(i , row)
			all_pieces[i][row].matched = true

#find adjacted pieces
func find_adjacent_pieces(column, row):
	for i in range(-1 , 2):
		for j in range(-1,2):
			if is_in_grid(Vector2(column + i , row + j)):
				if all_pieces[column + i][row + j] != null:
					if all_pieces[column + i][row + j].is_column_bomb:
						match_all_in_column(column + i)
					if all_pieces[column + i][row + j].is_row_bomb:
						match_all_in_row(row + j)
					all_pieces[column + i][row + j].matched = true

#Destory timer
func _on_destory_timer_timeout() -> void:
	destory_matched()

#collapse timer
func _on_collapse_timer_timeout() -> void:
	collapse_columns()

#replaces empty tiles
func _on_refill_timer_timeout() -> void:
	refill_columns()


func _on_lock_holder_remove_lock(place: Vector2) -> void:
	remove_from_array(lock_spaces , place)

func _on_concrete_holder_remove_concrete(place : Vector2) -> void:
	remove_from_array(concrete_spaces , place)


func _on_slime_holder_remove_slime(place):
	damaged_slime = true
	remove_from_array(slime_spaces , place)
