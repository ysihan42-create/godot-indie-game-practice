extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const ATTACK_DURATION = 0.16
const ATTACK_COOLDOWN = 0.4

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_visual: Polygon2D = $AttackArea/AttackVisual
@onready var attack_timer: Timer = $AttackTimer

var has_double_jump := false
var jumps_left := 0
var has_attack := false
var is_invincible := false
var invincible_time := 0.0
var big_time := 0.0
var attack_cooldown_time := 0.0
var base_sprite_scale := Vector2.ONE


func _ready() -> void:
	add_to_group("player")
	base_sprite_scale = animated_sprite.scale
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

	attack_cooldown_time = maxf(0.0, attack_cooldown_time - delta)

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		jumps_left = 1 if has_double_jump else 0

	# Handle jump and double jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif has_double_jump and jumps_left > 0:
			velocity.y = JUMP_VELOCITY * 0.92
			jumps_left -= 1

	# Get the input direction: -1, 0, 1
	var direction := Input.get_axis("move_left", "move_right")

	# Flip the Sprite and attack hitbox.
	if direction > 0:
		animated_sprite.flip_h = false
		attack_area.scale.x = 1.0
	elif direction < 0:
		animated_sprite.flip_h = true
		attack_area.scale.x = -1.0

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
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func apply_potion(potion_type: int) -> void:
	match potion_type:
		0:
			has_double_jump = true
		1:
			set_invincible(6.0)
		2:
			_set_big(true)
			big_time = 8.0
		3:
			has_attack = true


func set_invincible(duration: float) -> void:
	is_invincible = true
	invincible_time = maxf(invincible_time, duration)


func is_invincible_now() -> bool:
	return is_invincible


func _set_big(enabled: bool) -> void:
	if enabled:
		animated_sprite.scale = Vector2(1.6, 1.6)
	else:
		animated_sprite.scale = base_sprite_scale


func _do_attack() -> void:
	attack_cooldown_time = ATTACK_COOLDOWN
	attack_area.monitoring = true
	attack_visual.visible = true
	attack_timer.start()


func _on_attack_timer_timeout() -> void:
	attack_area.monitoring = false
	attack_visual.visible = false


func _on_attack_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_hurtbox") and area.get_parent().has_method("hit"):
		area.get_parent().hit()
