extends Node

var score = 0
var is_dying := false

@onready var score_label: Label = $ScoreLabel
@onready var death_screen: Control = %DeathScreen

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
	_show_death_screen()
	await get_tree().create_timer(0.6).timeout
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()


func _show_death_screen() -> void:
	death_screen.visible = true
	death_screen.modulate = Color(1, 1, 1, 1)
	var tween := create_tween()
	tween.tween_property(death_screen, "modulate:a", 0.0, 0.55)
