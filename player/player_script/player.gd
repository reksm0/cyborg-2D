class_name Player extends CharacterBody2D

const SPEED = 170.0
const JUMP_VELOCITY = -450.0

@onready var animated_sprite_2d = $AnimatedSprite2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var health := 5
var knockback := Vector2.ZERO
var is_attacking := false

func _ready():
	add_to_group("player")
	
func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Knockback
	velocity += knockback
	knockback = knockback.move_toward(Vector2.ZERO, 12000 * delta)

	# Attack
	if Input.is_action_just_pressed("attack") and !is_attacking:
		start_attack()

	# Prevent movement while attacking
	if is_attacking:
		move_and_slide()
		return

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movement
	var input_axis := Input.get_axis("ui_left", "ui_right")

	if input_axis:
		velocity.x = input_axis * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	update_animations(input_axis)
	reset_player_position()


func start_attack():
	is_attacking = true
	velocity.x = 0

	animated_sprite_2d.play("attack")

	await animated_sprite_2d.animation_finished

	is_attacking = false


func update_animations(input_axis: float) -> void:
	if is_attacking:
		return

	if input_axis > 0:
		animated_sprite_2d.flip_h = false
	elif input_axis < 0:
		animated_sprite_2d.flip_h = true

	if is_on_floor():
		if input_axis != 0:
			animated_sprite_2d.play("run")
		else:
			animated_sprite_2d.play("idle")
	else:
		if velocity.y > 0:
			animated_sprite_2d.play("fall")
		else:
			animated_sprite_2d.play("jump")


func take_damage(amount: int, attacker_pos: Vector2) -> void:
	health -= amount

	var dir = sign(global_position.x - attacker_pos.x)

	# Knockback
	knockback = Vector2(dir * 450, -300)

	if health <= 0:
		die()


func die() -> void:
	queue_free()


func reset_player_position() -> void:
	if global_position.y > 500:
		global_position = Vector2(100, 100)
