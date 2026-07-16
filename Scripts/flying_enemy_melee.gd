extends CharacterBody2D

@export var speed := 100.0
@export var chase_speed := 120.0
@export var damage := 1
@export var patrol_radius_x := 120.0
@export var patrol_radius_y := 80.0
@export var patrol_reach_distance := 5.0
@export var patrol_acceleration := 300.0
@export var chase_acceleration := 500.0

const CHASE_TIME := 2.5

var chasing := false
var player_in_range := false
var chase_timer := 0.0

var home := Vector2.ZERO
var target := Vector2.ZERO

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	randomize()
	home = global_position
	pick_new_target()
	animated_sprite_2d.play("fly")


func _physics_process(delta: float) -> void:
	if !is_instance_valid(Global.playerBody):
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var player = Global.playerBody

	# Chase state
	if player_in_range:
		chasing = true
		chase_timer = CHASE_TIME
	elif chasing:
		chase_timer -= delta
		if chase_timer <= 0:
			chasing = false

	# Movement
	if chasing:
		var dir := global_position.direction_to(player.global_position)
		velocity = velocity.move_toward(
			dir * chase_speed,
			chase_acceleration * delta
		)
	else:
		if global_position.distance_to(target) <= patrol_reach_distance:
			pick_new_target()

		var dir := global_position.direction_to(target)
		velocity = velocity.move_toward(
			dir * speed,
			patrol_acceleration * delta
		)

	# Face movement direction
	if chasing:
		animated_sprite_2d.flip_h = player.global_position.x < global_position.x
	elif abs(velocity.x) > 1:
		animated_sprite_2d.flip_h = velocity.x < 0

	move_and_slide()


func pick_new_target() -> void:
	target = home + Vector2(
		randf_range(-patrol_radius_x, patrol_radius_x),
		randf_range(-patrol_radius_y, patrol_radius_y)
	)


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage(damage, global_position)
