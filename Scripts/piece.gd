extends Node2D

@export var color : String
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

func dim():
	var sprite = get_node("Sprite2D")
	sprite.modulate = Color(1, 1, 1, 0.5)
