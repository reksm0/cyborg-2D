extends CharacterBody2D

const gravity = 600
const speed = 100
var direction = 1

@onready var ray_y: RayCast2D = $RayY
@onready var ray_x: RayCast2D = $RayX
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta 
		
	if not ray_y.is_colliding() or ray_x.is_colliding():
		change_dir()
	
	velocity.x = speed * direction
	move_and_slide()
	
func change_dir():
	direction *= -1
	animated_sprite_2d.flip_h = direction == -1
	ray_y.position.x = 37 if direction == 1 else -37
	ray_x.position.x = 10 if direction == 1 else -10
	ray_x.target_position.x = 30 if direction == 1 else -30
	
func _on_range_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_range_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
