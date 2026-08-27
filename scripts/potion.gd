extends Area2D


@export_enum("Green", "Yellow", "Blue", "Purple") var potion_type := 0

const REGIONS := [
	Rect2(0, 7 * 16, 16, 16),
	Rect2(1 * 16, 7 * 16, 16, 16),
	Rect2(0, 8 * 16, 16, 16),
	Rect2(1 * 16, 8 * 16, 16, 16),
]

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	sprite.region_rect = REGIONS[potion_type]
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("apply_potion"):
		body.apply_potion(potion_type)
	$PickupSound.play()
	queue_free()
