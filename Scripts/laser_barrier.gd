extends StaticBody2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var point_light_2d: PointLight2D = $PointLight2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GameState.awakening_panel_hacked:
		animated_sprite_2d.play("inactive")
		collision_shape_2d.set_deferred("disabled", true)
		point_light_2d.energy = 0.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func deactivate():
	print("Laser Disabled")
	animated_sprite_2d.play("deactivated")
	var tween = create_tween()
	tween.tween_property(
		point_light_2d,
		"energy",
		0.0,
		2.3
	)
	collision_shape_2d.set_deferred("disabled", true)


func _on_control_panel_hacked_successfully() -> void:
	deactivate()
