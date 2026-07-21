extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var label: Label = $CanvasLayer/Label
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var point_light_2d: PointLight2D = $PointLight2D
var player_in_range = false
signal hacked_successfully

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.visible = false
	
	if GameState.awakening_panel_hacked:
		animated_sprite_2d.play("inactive")
		point_light_2d.color = Color(0.0, 0.859, 1.0)
		point_light_2d.energy = 0.5


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_prompt_position()
	if GameState.awakening_panel_hacked:
		return

	if player_in_range and Input.is_action_just_pressed("interact"):
		start_hack()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		if !GameState.awakening_panel_hacked:
			label.visible = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		label.visible = false

func start_hack():
	GameState.awakening_panel_hacked = true
	label.visible = false
	# Start the deactivation animation
	animated_sprite_2d.play("deactivated")

	# Run the complete light sequence
	await start_hacking_light()

	# At this point, both light tweens are finished.
	# If the animation is still running, wait for it.
	if animated_sprite_2d.is_playing():
		await animated_sprite_2d.animation_finished

	# Now both the light sequence and animation are finished
	emit_signal("hacked_successfully")


func start_hacking_light():
	# RED → BRIGHT BLUE
	var color_tween = create_tween()

	color_tween.tween_property(
		point_light_2d,
		"color",
		Color(0.0, 0.859, 1.0),
		0.8
	)
	await color_tween.finished

	# BRIGHT BLUE → FAINT BLUE
	var fade_tween = create_tween()

	fade_tween.tween_property(
		point_light_2d,
		"energy",
		0.5,
		1.2
	)
	await fade_tween.finished

func update_prompt_position() -> void:
	var screen_position = get_viewport().get_canvas_transform() * global_position
	label.global_position = screen_position + Vector2(-60, -180)
