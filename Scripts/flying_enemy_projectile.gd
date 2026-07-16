extends CharacterBody2D

@export var patrol_speed := 80.0
@export var chase_speed := 140.0
@export var damage := 1

@export var contact_damage := 1
@export var contact_damage_cooldown := 0.6

var can_contact_damage := true

@export var patrol_radius_x := 120.0
@export var patrol_radius_y := 80.0

@export var shoot_range := 220.0
@export var keep_distance := 160.0
@export var attack_cooldown := 1.2

const ENEMY_PROJECTILE = preload("res://Scenes/enemy_projectile.tscn") # Change path if needed

const CHASE_TIME := 2.5

var chasing := false
var player_in_range := false
var can_shoot := true
var is_shooting := false
var chase_timer := 0.0

var home := Vector2.ZERO
var target := Vector2.ZERO

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var gun_pivot: Node2D = $GunPivot
@onready var muzzle: Marker2D = $GunPivot/Muzzle

func _ready():
	randomize()
	home = global_position
	pick_new_target()
	sprite.play("fly")


func _physics_process(delta):
	if !is_instance_valid(Global.playerBody):
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var player = Global.playerBody

	# Detection memory
	if player_in_range:
		chasing = true
		chase_timer = CHASE_TIME
	elif chasing:
		chase_timer -= delta
		if chase_timer <= 0:
			chasing = false

	if chasing:
		handle_chase(player, delta)
	else:
		handle_patrol(delta)

	move_and_slide()

func handle_chase(player, delta):
	update_gun_aim(player, delta)

	var to_player = player.global_position - global_position
	var distance = to_player.length()
	var dir = to_player.normalized()

	# Desired position around the player
	var desired_pos = player.global_position - dir * keep_distance

	# Randomly offset around the player
	var side = dir.orthogonal()
	desired_pos += side * sin(Time.get_ticks_msec() * 0.002) * 70.0

	var move_dir = (desired_pos - global_position).normalized()

	velocity = velocity.move_toward(
		move_dir * chase_speed,
		600 * delta
	)

	if can_shoot and distance <= shoot_range and !is_shooting:
		shoot(player)

func handle_patrol(delta):
	if global_position.distance_to(target) < 5:
		pick_new_target()

	var dir = global_position.direction_to(target)

	velocity = velocity.move_toward(
		dir * patrol_speed,
		300 * delta
	)

	# Face movement direction
	if velocity.x > 1:
		sprite.flip_h = false
	elif velocity.x < -1:
		sprite.flip_h = true

	# Return gun to resting position
	gun_pivot.rotation = lerp_angle(
		gun_pivot.rotation,
		0.0,
		8.0 * delta
	)

func shoot(player):
	is_shooting = true
	can_shoot = false

	sprite.play("attack")

	while sprite.frame < 4:
		await sprite.frame_changed

	spawn_bullet(player)

	await sprite.animation_finished

	sprite.play("fly")

	is_shooting = false

	await get_tree().create_timer(attack_cooldown).timeout

	can_shoot = true


func spawn_bullet(player):
	var bullet = ENEMY_PROJECTILE.instantiate()

	get_tree().current_scene.add_child(bullet)

	bullet.global_position = muzzle.global_position

	# Shoot directly toward the player's current position
	bullet.direction = (
		player.global_position - muzzle.global_position
	).normalized()


func pick_new_target():
	target = home + Vector2(
		randf_range(-patrol_radius_x, patrol_radius_x),
		randf_range(-patrol_radius_y, patrol_radius_y)
	)
	

func take_damage(amount):
	queue_free()


func update_gun_aim(player, delta):
	var dir = player.global_position - gun_pivot.global_position

	# Flip body
	if dir.x >= 0:
		sprite.flip_h = false
	else:
		sprite.flip_h = true

	var angle = dir.angle()

	# If facing left, convert to local angle
	if sprite.flip_h:
		angle += PI

	# Clamp between -45° and 45°
	angle = clamp(angle, deg_to_rad(-45), deg_to_rad(45))

	gun_pivot.rotation = lerp_angle(
		gun_pivot.rotation,
		angle,
		10.0 * delta
	)

func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true


func _on_detection_area_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false


func _on_hitbox_area_entered(area):
	if area.is_in_group("player_attack"):
		take_damage(area.damage)
		
func _on_contact_area_body_entered(body):
	if !body.is_in_group("player"):
		return

	if !can_contact_damage:
		return

	can_contact_damage = false

	body.take_damage(contact_damage, global_position)

	await get_tree().create_timer(contact_damage_cooldown).timeout

	can_contact_damage = true
