extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var health = 5
var knockback_x = 0
var knockback_y = 0

func _ready() -> void:
	add_to_group("player")
	
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if knockback_x != 0 or knockback_y != 0:
		velocity.x = knockback_x
		velocity.y = knockback_y
		
		knockback_x = move_toward(knockback_x, 0, 800 * delta)
		knockback_y = move_toward(knockback_y, 0, 800 * delta)
	else:
		var direction := Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		
	move_and_slide()


func take_damage(amount):
	health -= amount
	knockback_x = -350
	knockback_y = -200

	if health <= 0:
		die()
		
func die():
	print("Player died")
	queue_free()
