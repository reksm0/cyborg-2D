extends Area2D

@export var speed := 400.0
@export var damage := 1

var direction: Vector2 = Vector2.ZERO
var exploded := false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	sprite.play("fly")


func _physics_process(delta: float) -> void:
	if exploded:
		return

	global_position += direction * speed * delta

	rotation = direction.angle()


func _on_body_entered(body: Node2D) -> void:
	if exploded:
		return
		
	elif body is TileMapLayer:
		explode()

	if body.is_in_group("player"):
		body.take_damage(damage, global_position)
		explode()


func explode() -> void:
	if exploded:
		return

	exploded = true
	speed = 0

	monitoring = false
	monitorable = false
	$CollisionShape2D.set_deferred("disabled", true)

	sprite.play("explode")

	# If there is no explode animation, delete immediately.
	if sprite.sprite_frames.has_animation("explode"):
		await sprite.animation_finished

	queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
