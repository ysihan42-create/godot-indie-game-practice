extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const ATTACK_DURATION = 0.16
const ATTACK_COOLDOWN = 0.4

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_visual: Polygon2D = $AttackArea/AttackVisual
@onready var attack_timer: Timer = $AttackTimer
@onready var camera = get_node_or_null("Camera2D")

var has_double_jump := false
var jumps_left := 0
var has_attack := false
var is_invincible := false
var invincible_time := 0.0
var big_time := 0.0
var attack_cooldown_time := 0.0
var base_sprite_scale := Vector2.ONE
var base_collision_scale := Vector2.ONE
var is_big := false
var speed_multiplier := 1.0
var jump_multiplier := 1.0
var attack_multiplier := 1.0
var speed_boost_time := 0.0
var jump_boost_time := 0.0
var attack_boost_time := 0.0
var facing := 1
var base_attack_visual_scale := Vector2.ONE
var base_attack_visual_rotation := 0.0


func _ready() -> void:
	add_to_group("player")
	base_sprite_scale = animated_sprite.scale
	base_collision_scale = collision_shape.scale
	base_attack_visual_scale = attack_visual.scale
	base_attack_visual_rotation = attack_visual.rotation
	attack_area.monitoring = false
	attack_visual.visible = false
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	attack_area.area_entered.connect(_on_attack_area_area_entered)


func _physics_process(delta: float) -> void:
	if invincible_time > 0.0:
		invincible_time -= delta
		if invincible_time <= 0.0:
			invincible_time = 0.0
			is_invincible = false

	if big_time > 0.0:
		big_time -= delta
		if big_time <= 0.0:
			big_time = 0.0
			_set_big(false)

	if speed_boost_time > 0.0:
		speed_boost_time -= delta
		if speed_boost_time <= 0.0:
			speed_boost_time = 0.0
			speed_multiplier = 1.0

	if jump_boost_time > 0.0:
		jump_boost_time -= delta
		if jump_boost_time <= 0.0:
			jump_boost_time = 0.0
			jump_multiplier = 1.0

	if attack_boost_time > 0.0:
		attack_boost_time -= delta
		if attack_boost_time <= 0.0:
			attack_boost_time = 0.0
			attack_multiplier = 1.0

	attack_cooldown_time = maxf(0.0, attack_cooldown_time - delta)

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		jumps_left = 1 if has_double_jump else 0

	# Handle jump and double jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY * jump_multiplier
		elif has_double_jump and jumps_left > 0:
			velocity.y = JUMP_VELOCITY * 0.92 * jump_multiplier
			jumps_left -= 1

	# Get the input direction: -1, 0, 1
	var direction := Input.get_axis("move_left", "move_right")

	# Flip the Sprite and attack hitbox.
	if direction > 0:
		animated_sprite.flip_h = false
		facing = 1
	elif direction < 0:
		animated_sprite.flip_h = true
		facing = -1
	var size_factor := 1.6 if is_big else 1.0
	attack_area.scale = Vector2(facing * attack_multiplier * size_factor, attack_multiplier * size_factor)

	# Attack.
	if Input.is_action_just_pressed("attack") and has_attack and attack_cooldown_time <= 0.0:
		_do_attack()

	# Play animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")

	# Apply movement
	if direction:
		velocity.x = direction * SPEED * speed_multiplier
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * speed_multiplier)

	move_and_slide()


func apply_potion(potion_type: int) -> void:
	match potion_type:
		0:
			has_double_jump = true
			jumps_left = 1
		1:
			set_invincible(6.0)
		2:
			_set_big(true)
			big_time = 8.0
		3:
			has_attack = true


func apply_fruit_ability(fruit_color: int) -> void:
	# fruit_color: 0=绿色，1=橘色，2=粉色，3=红色
	match fruit_color:
		0:
			jump_multiplier = 1.45
			jump_boost_time = 5.0
		1:
			set_invincible(3.0)
		2:
			speed_multiplier = 1.55
			speed_boost_time = 5.0
		3:
			attack_multiplier = 1.6
			attack_boost_time = 5.0


func set_invincible(duration: float) -> void:
	is_invincible = true
	invincible_time = maxf(invincible_time, duration)


func is_invincible_now() -> bool:
	return is_invincible


func _set_big(enabled: bool) -> void:
	is_big = enabled
	if enabled:
		animated_sprite.scale = Vector2(1.6, 1.6)
		collision_shape.scale = Vector2(1.6, 1.6)
	else:
		animated_sprite.scale = base_sprite_scale
		collision_shape.scale = base_collision_scale


func _do_attack() -> void:
	attack_cooldown_time = ATTACK_COOLDOWN
	attack_area.monitoring = true
	attack_visual.visible = true
	attack_visual.modulate = Color(1, 1, 1, 0.95)
	attack_visual.scale = base_attack_visual_scale * 0.6
	attack_visual.rotation = base_attack_visual_rotation - 0.28 * facing
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(attack_visual, "scale", base_attack_visual_scale * 1.25, ATTACK_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(attack_visual, "rotation", base_attack_visual_rotation + 0.38 * facing, ATTACK_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(attack_visual, "modulate:a", 0.0, ATTACK_DURATION)
	attack_timer.start()
	_shake_camera(2.0, 0.08)


func _on_attack_timer_timeout() -> void:
	attack_area.monitoring = false
	attack_visual.visible = false
	attack_visual.modulate = Color(1, 1, 1, 0.95)
	attack_visual.scale = base_attack_visual_scale
	attack_visual.rotation = base_attack_visual_rotation


func _on_attack_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_hurtbox") and area.get_parent().has_method("hit"):
		_shake_camera(4.0, 0.12)
		area.get_parent().hit()


func _shake_camera(strength: float, duration: float) -> void:
	if camera == null:
		return
	var tween := create_tween()
	tween.tween_property(camera, "offset", Vector2(strength, 0), duration * 0.25).set_trans(Tween.TRANS_SINE)
	tween.tween_property(camera, "offset", Vector2(-strength, 0), duration * 0.25).set_trans(Tween.TRANS_SINE)
	tween.tween_property(camera, "offset", Vector2.ZERO, duration * 0.5).set_trans(Tween.TRANS_SINE)
