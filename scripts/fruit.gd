extends Area2D


@onready var game_manager: Node = %GameManager


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		game_manager.add_point(5)
		$PickupSound.play()
		queue_free()
