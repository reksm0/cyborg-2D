extends Node2D

@export var hacking_sequence_length: int = 3
@export var hacking_time_limit: float = 5.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var label: Label = $CanvasLayer/Label
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var point_light_2d: PointLight2D = $PointLight2D
@onready var hacking_ui: CanvasLayer = $"../../HackingUI"

var player_in_range: bool = false
var hacking_in_progress: bool = false

signal hacked_successfully


func _ready() -> void:
	label.visible = false
	
	if GameState.awakening_panel_hacked:
		animated_sprite_2d.play("inactive")
		point_light_2d.color = Color(0.0, 0.859, 1.0)
		point_light_2d.energy = 0.5
	
	# Connect HackingUI success signal
	hacking_ui.hack_success.connect(_on_hacking_success)
	# Connect HackingUI failed signal
	hacking_ui.hack_failed.connect(_on_hacking_failed)


func _process(delta: float) -> void:
	update_prompt_position()
	
	if GameState.awakening_panel_hacked:
		return
		
	if player_in_range and Input.is_action_just_pressed("interact"):
		if not hacking_in_progress:
			start_hacking()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		
		if not GameState.awakening_panel_hacked:
			label.visible = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		label.visible = false


func start_hacking() -> void:
	hacking_in_progress = true
	label.visible = false
	
	# Start the hacking minigame.
	hacking_ui.start_hacking(hacking_sequence_length, hacking_time_limit)


func _on_hacking_success() -> void:
	hacking_in_progress = false
	GameState.awakening_panel_hacked = true
	
	# Start the panel's successful deactivation sequence.
	animated_sprite_2d.play("deactivated")
	
	# Run the complete light sequence
	await start_hacking_light()
	
	# Wait for animation if it is still playing
	if animated_sprite_2d.is_playing():
		await animated_sprite_2d.animation_finished

	emit_signal("hacked_successfully")


func _on_hacking_failed() -> void:
	hacking_in_progress = false
	
	# Allow the player to try again if they are still nearby.
	if player_in_range:
		label.visible = true


func start_hacking_light() -> void:
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
