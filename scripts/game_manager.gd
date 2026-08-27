extends Node

var score = 0
var is_dying := false

@onready var score_label: Label = $ScoreLabel

func add_point(amount: int = 1):
	score += amount
	score_label.text = "Score: " + str(score)


func player_died(body: Node2D) -> void:
	if is_dying:
		return
	is_dying = true
	Engine.time_scale = 0.5
	if body.has_node("CollisionShape2D"):
		body.get_node("CollisionShape2D").queue_free()
	await get_tree().create_timer(0.6).timeout
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
