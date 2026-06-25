extends StaticBody2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func deactivate():
	print("Laser Disabled")
	animated_sprite_2d.play("deactivated")
	collision_shape_2d.set_deferred("disabled", true)


func _on_control_panel_hacked_successfully() -> void:
	deactivate()
