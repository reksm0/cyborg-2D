extends CharacterBody2D

@onready var ground_enemy: CharacterBody2D = $"."
@onready var timer: Timer = $Timer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_2d: RayCast2D = $AnimatedSprite2D/RayCast2D
@onready var player: Node2D = $"."


const SPEED = 50.0
const CHASE_SPEED = 100
const ACCELARATION = 200
const JUMP_VELOCITY = -400.0

var direction: Vector2
var left_bound: Vector2
var right_bound: Vector2

const WANDER = 0
const CHASE = 1
var current_state = WANDER

func _ready() -> void:
	left_bound = self.position + Vector2(-64,0)
	right_bound = self.position + Vector2(64,0)
	
func _physics_process(delta: float) -> void:
	# Handles all processes in the bg
	handle_gravity(delta)
	handle_movement(delta)
	change_direction()
	look_for_player()
	
func look_for_player():
	# Checks if the enemy is in range of the player 
	if ray_cast_2d.is_colliding():
		var collider = ray_cast_2d.get_collider()
		if collider == player:
			chase_player()
		elif current_state == CHASE:
			stop_chase()
	elif current_state == CHASE:
		stop_chase()

func chase_player():
	timer.stop()
	current_state = CHASE
	
func stop_chase():
	if timer.time_left == 0:
		timer.start()
		
func handle_movement(delta: float):
	if current_state == WANDER:
		velocity = velocity.move_toward(direction * SPEED,ACCELARATION * delta)
	else:
		velocity = velocity.move_toward(direction * CHASE_SPEED,ACCELARATION * delta)
	move_and_slide()

func change_direction():
	if current_state == WANDER:
		if animated_sprite_2d.flip_h:
			# Moves left
			if self.position.x <= left_bound.x:
				direction = Vector2(-1,0)
			else:
				# Flip to move right
				animated_sprite_2d.flip_h = false
				ray_cast_2d.target_position = Vector2(64,0)
		else:
			# Moves right
			if self.position.x <= right_bound.x:
				direction = Vector2(1,0)
			else:
				# Flip to move left
				animated_sprite_2d.flip_h = true
				ray_cast_2d.target_position = Vector2(-64,0)
	else:
		# CHASE STATE
		direction = (player.position - self.position).normalized()
		direction = sign(direction)
		if direction.x > 0:
			# Flip to move rightm
			animated_sprite_2d.flip_h = false
			ray_cast_2d.target_position = Vector2(64,0)
		else:
			# Flip to move left
			animated_sprite_2d.flip_h = true
			ray_cast_2d.target_position = Vector2(-64,0)
			
func handle_gravity(delta: float):
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
		
func _on_timer_timeout() -> void:
	current_state = WANDER
