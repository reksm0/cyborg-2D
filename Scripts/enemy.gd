extends CharacterBody2D

const gravity = 600
const speed = 100

var acc := 600.0
var max_speed := 150.0
var direction = 1

var player: Node2D = null
var chasing := false

var is_attacking := false

var forget_time := 1.5
var forget_timer := 0.0
var last_seen_position: Vector2

@export var health: int = 5

var attack_range := 50.0
var attack_cooldown := 1.0
var attack_timer := 0.0

var dead := false

@onready var ray_y: RayCast2D = $RayY
@onready var ray_x: RayCast2D = $RayX
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	add_to_group("enemy")


func _physics_process(delta: float) -> void:
	if dead:
		return
	if not is_on_floor():
		velocity.y += gravity * delta
	attack_timer -= delta
	if player:
		var distance = global_position.distance_to(player.global_position)
		forget_timer = forget_time
		last_seen_position = player.global_position
		if distance < attack_range and attack_timer <= 0:
			start_attack()
			move_and_slide()
			update_animation()
			return
	else:
		forget_timer -= delta
		
	if forget_timer > 0:
		chasing = true
		chase_target(last_seen_position)
	else:
		chasing = false
		patrol()

	update_animation()
	move_and_slide()


func patrol() -> void:
	if not ray_y.is_colliding() or ray_x.is_colliding():
		change_dir()
	velocity.x = speed * direction
	animated_sprite_2d.flip_h = direction < 0


func chase_target(target_pos: Vector2) -> void:
	var dir = sign(target_pos.x - global_position.x)

	velocity.x = move_toward(velocity.x,dir * max_speed,acc * get_physics_process_delta_time())
	if dir != 0:
		animated_sprite_2d.flip_h = dir < 0


func change_dir():
	direction *= -1
	animated_sprite_2d.flip_h = direction < 0
	ray_y.position.x = 37 if direction == 1 else -37
	ray_x.position.x = 10 if direction == 1 else -10
	ray_x.target_position.x = 30 if direction == 1 else -30


func update_animation():
	if dead:
		if animated_sprite_2d.animation != "death":
			animated_sprite_2d.play("death")
		return

	if is_attacking:
		if animated_sprite_2d.animation != "attack":
			animated_sprite_2d.play("attack")
		return

	if animated_sprite_2d.animation == "hurt":
		return

	if chasing:
		if animated_sprite_2d.animation != "chase":
			animated_sprite_2d.play("chase")
	else:
		if animated_sprite_2d.animation != "walk":
			animated_sprite_2d.play("walk")


func start_attack():
	if is_attacking or dead:
		return
	is_attacking = true
	attack_timer = attack_cooldown
	velocity.x = 0
	animated_sprite_2d.play("attack")
	if player and player.has_method("take_damage"):
		player.take_damage(1, global_position)
	await animated_sprite_2d.animation_finished
	is_attacking = false


func take_damage(amount):
	if dead:
		return
	health -= amount
	if health <= 0:
		die()
		return
	animated_sprite_2d.play("hurt")
	await animated_sprite_2d.animation_finished


func die():
	if dead:
		return
	dead = true
	velocity = Vector2.ZERO
	animated_sprite_2d.play("death")


func _on_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		forget_timer = forget_time


func _on_range_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
