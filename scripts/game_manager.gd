extends Node

var score = 0

@onready var score_label: Label = $ScoreLabel

func add_point(amount: int = 1):
	score += amount
	score_label.text = "Score: " + str(score)
