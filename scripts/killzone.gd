extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("is_invincible_now") and body.is_invincible_now():
		return
	var game_manager := get_node_or_null("%GameManager")
	if game_manager and game_manager.has_method("player_died"):
		game_manager.player_died(body)


func _on_timer_timeout() -> void:
	pass
