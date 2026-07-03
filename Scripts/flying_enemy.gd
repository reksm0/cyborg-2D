extends CharacterBody2D

@export var speed := 100.0
@export var chase_speed := 120.0
@export var damage := 1

# State
var chasing := false
var player_in_range := false

var chase_timer := 0.0
const CHASE_TIME := 2.5

# Patrol
var home := Vector2.ZERO
var target := Vector2.ZERO

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _ready():
	home = global_position
	pick_new_target()
	animated_sprite_2d.play("fly")


func _physics_process(delta):
	if Global.playerBody == null:
		return
	var player = Global.playerBody
	
	# CHASE LOGIC
	if player_in_range:
		chasing = true
		chase_timer = CHASE_TIME  # resets while player is inside
	elif chasing:
		chase_timer -= delta
		if chase_timer <= 0:
			chasing = false

	# MOVEMENT
	if chasing:
		var dir = global_position.direction_to(player.global_position)
		velocity = dir * chase_speed
	else:
		var dir = global_position.direction_to(target)
		velocity = dir * speed * 0.5
		if global_position.distance_to(target) < 10:
			pick_new_target()
			
	if velocity.x != 0:
		animated_sprite_2d.flip_h = velocity.x < 0
	move_and_slide()

# DETECTION AREA
func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true


func _on_detection_area_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false


# PATROL POINTS
func pick_new_target():
	target = home + Vector2(
		randf_range(-120, 120),
		randf_range(-80, 80)
	)

# DAMAGE PLAYER ON CONTACT
func _on_hitbox_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(damage, global_position)
