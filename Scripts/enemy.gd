extends CharacterBody2D

const gravity = 600
const speed = 100

var acc := 600.0
var max_speed := 150.0
var direction = 1

var player: Node2D = null
var chasing := false

var forget_time := 1.5
var forget_timer := 0.0
var last_seen_position: Vector2

@export var health: int = 5

var attack_range := 140.0
var attack_cooldown := 1.0
var attack_timer := 0.0

@onready var ray_y: RayCast2D = $RayY
@onready var ray_x: RayCast2D = $RayX
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("enemy")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	attack_timer -= delta

	if player:
		var distance = global_position.distance_to(player.global_position)
		if distance < attack_range and attack_timer <= 0:
			attack_player(1)
			attack_timer = attack_cooldown

	# Update memory timer
	if player:
		forget_timer = forget_time
		last_seen_position = player.global_position
	else:
		forget_timer -= delta

	# Chase
	if forget_timer > 0:
		chasing = true
		chase_target(last_seen_position)
		move_and_slide()
		return
	else:
		chasing = false

	# Patrol
	if not ray_y.is_colliding() or ray_x.is_colliding():
		change_dir()

	velocity.x = speed * direction
	move_and_slide()


func chase_target(target_pos: Vector2) -> void:
	var dir = sign(target_pos.x - global_position.x)
	velocity.x = move_toward(velocity.x,dir * max_speed,acc * get_physics_process_delta_time())
	animated_sprite_2d.flip_h = dir < 0


func change_dir():
	direction *= -1
	animated_sprite_2d.flip_h = direction == -1
	ray_y.position.x = 37 if direction == 1 else -37
	ray_x.position.x = 10 if direction == 1 else -10
	ray_x.target_position.x = 30 if direction == 1 else -30


# Detection
func _on_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		forget_timer = forget_time
		print("Player detected")


func _on_range_body_exited(body: Node2D) -> void:
	if body == player:
		player = null


func take_damage(amount):
	health -= amount
	if health <= 0:
		die()


func die():
	queue_free()


# Attack player
func attack_player(amount):
	if player:
		print("Enemy attacked")
		player.take_damage(amount)
