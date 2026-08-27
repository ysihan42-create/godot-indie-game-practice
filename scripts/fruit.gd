extends Area2D


@export var fruit_type := 0
@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	var col := fruit_type % 3
	var row := int(fruit_type / 3.0)
	sprite.region_rect = Rect2(col * 16, row * 16, 16, 16)
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("apply_fruit_ability"):
		body.apply_fruit_ability(int(fruit_type / 3.0))
		$PickupSound.play()
		queue_free()
