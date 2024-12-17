extends TextureRect

@onready var score_label = %ScoreLabel
# Called when the node enters the scene tree for the first time.
var current_score = 0

func _ready() -> void:
	_on_grid_update_score(current_score)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass


func _on_grid_update_score(amount_to_change) -> void:
	current_score += amount_to_change
	score_label.text  = str(current_score)
