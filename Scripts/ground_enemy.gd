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
		
	# Apply Gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		
	attack_timer -= delta
	
	# Track player memory
	if player:
		forget_timer = forget_time
		last_seen_position = player.global_position
		
		# Check for Attack Trigger
		var distance = global_position.distance_to(player.global_position)
		if distance < attack_range and attack_timer <= 0 and not is_attacking:
			start_attack()
	else:
		forget_timer -= delta

	# Process movement if not locked in an action animation
	if not is_attacking and animated_sprite_2d.animation != "take_damage":
		if forget_timer > 0:
			chasing = true
			chase_target(last_seen_position)
		else:
			chasing = false
			patrol()
	else:
		# Keep velocity at 0 during attacks or heavy hitstun
		velocity.x = 0

	update_animation()
	move_and_slide()


func patrol() -> void:
	# Wall / Ledge Check
	if not ray_y.is_colliding() or ray_x.is_colliding():
		change_dir()
	velocity.x = speed * direction
	animated_sprite_2d.flip_h = direction > 0


func chase_target(target_pos: Vector2) -> void:
	var dir = int(sign(target_pos.x - global_position.x))
	# Chase Movement
	velocity.x = move_toward(velocity.x, dir * max_speed, acc * get_physics_process_delta_time())
	# Face target
	if dir != 0 and dir != direction:
		direction = dir
		animated_sprite_2d.flip_h = direction > 0
		update_ray_positions()


func change_dir():
	direction *= -1
	animated_sprite_2d.flip_h = direction > 0
	update_ray_positions()


func update_ray_positions():
	ray_y.position.x = -37 if direction == 1 else 37
	ray_x.position.x = -10 if direction == 1 else 10
	ray_x.target_position.x = -30 if direction == 1 else 30


func update_animation():
	if dead or is_attacking or animated_sprite_2d.animation == "take_damage":
		return # Let the action functions handle playing their respective animations
		
	if chasing:
		if animated_sprite_2d.animation != "chase":
			animated_sprite_2d.play("chase")
	else:
		if animated_sprite_2d.animation != "walk":
			animated_sprite_2d.play("walk")


func start_attack():
	is_attacking = true
	attack_timer = attack_cooldown
	velocity.x = 0
	animated_sprite_2d.play("attack")
	
	# Deal damage to player if they are still there
	if player:
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
		
	animated_sprite_2d.play("take_damage")
	await animated_sprite_2d.animation_finished
	
	# Fall back to walk/chase animation smoothly after taking damage
	update_animation()


func die():
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
