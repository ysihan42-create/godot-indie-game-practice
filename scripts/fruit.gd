extends Area2D


# fruit.png 布局：
# 列 0=苹果，1=梨，2=葡萄；行 0=绿色，1=橘色，2=粉色，3=红色。
# fruit_type 0-2 绿，3-5 橘，6-8 粉，9-11 红。
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
