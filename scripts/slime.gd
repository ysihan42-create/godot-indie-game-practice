extends Node2D


const SPEED = 60
var direction = 1
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	add_to_group("enemies")
	$Hurtbox.add_to_group("enemy_hurtbox")


func _process(delta: float) -> void:
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	if ray_cast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = false
	position.x += direction * SPEED * delta


func hit() -> void:
	var game_manager := get_node_or_null("%GameManager")
	if game_manager and game_manager.has_method("add_point"):
		game_manager.add_point()
	queue_free()
