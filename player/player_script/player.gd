class_name Player extends CharacterBody2D

const SPEED = 170.0
const JUMP_VELOCITY = -500.0

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite_2d = $AnimatedSprite2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var health := 5
var is_attacking := false
var controls_enabled := true

func _ready():
	add_to_group("player")
	Global.playerBody = self
	
func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Knockback
	velocity += knockback
	knockback = knockback.move_toward(Vector2.ZERO, 12000 * delta)
	
	# Disable player controls (used for elevators, cutscenes, dialogue, etc.)
	if !controls_enabled:
		velocity.x = 0
		move_and_slide()
		return
	
	# Attack
	if Input.is_action_just_pressed("attack") and !is_attacking:
		start_attack()

	# Prevent movement while attacking
	if is_attacking:
		move_and_slide()
		return

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movement
	var input_axis := Input.get_axis("left", "right")

	if input_axis:
		velocity.x = input_axis * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	update_animations(input_axis)
	


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
	velocity = Vector2(dir * 450, -300)
	if health <= 0:
		die()


func die() -> void:
	queue_free()
