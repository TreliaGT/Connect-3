extends Node2D

@export var color : String
@export var row_texture : Texture
@export var col_texture : Texture
@export var adjacent_texture: Texture
@export var color_bomb : Texture
@onready var sprite = $Sprite2D

var is_row_bomb = false
var is_column_bomb = false
var is_adjacent_bomb = false
var is_rainbow_bomb = false

var matched = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
func move(target):
	var move_tween = create_tween()
	move_tween.tween_property(self, "position", target, 0.3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func make_column_bomb():
	is_column_bomb = true
	sprite.texture = col_texture
	sprite.modulate = Color(1,1,1,1)
	
func make_row_bomb():
	is_row_bomb = true
	sprite.texture = row_texture
	sprite.modulate = Color(1,1,1,1)
	
func make_adjacemt_bombs():
	is_adjacent_bomb = true
	sprite.texture = adjacent_texture
	sprite.modulate = Color(1,1,1,1)
	
func make_color_bomb():
	is_rainbow_bomb = true
	sprite.texture = color_bomb
	sprite.modulate = Color(1,1,1,1)
	color = "color"
	
func dim():
	sprite.modulate = Color(1, 1, 1, 0.5)
