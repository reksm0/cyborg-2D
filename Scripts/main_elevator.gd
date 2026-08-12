extends Node2D

@export var hacking_sequence_length: int = 4
@export var hacking_time_limit: float = 5.0

@onready var label: Label = $Label
@onready var elevator_menu: CanvasLayer = $"../Elevator Menu"
@onready var access_text: Label = $"access text"
@onready var room: AnimatedSprite2D = $room
@onready var door: AnimatedSprite2D = $door
@onready var player: Player = $"../player"
@onready var hacking_ui: CanvasLayer = $"../HackingUI"

var player_in_range: bool = false
var hacking_in_progress: bool = false


func _ready() -> void:
	label.visible = false
	access_text.visible = false

	if GameState.main_elevator_hacked:
		door.play("default")

	hacking_ui.hack_success.connect(_on_hacking_success)
	hacking_ui.hack_failed.connect(_on_hacking_failed)


func _process(delta: float) -> void:
	# Elevator is already hacked → normal elevator interaction
	if GameState.main_elevator_hacked:
		if player_in_range and Input.is_action_just_pressed("interact"):
			elevator_menu.visible = true
			player.controls_enabled = false

		if elevator_menu.visible and Input.is_action_just_pressed("close"):
			elevator_menu.visible = false
			player.controls_enabled = true

		return

	# Elevator has not been hacked yet → start hacking
	if player_in_range and Input.is_action_just_pressed("interact"):
		if not hacking_in_progress:
			start_hacking()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true

		if not GameState.main_elevator_hacked:
			label.visible = true
		else:
			access_text.visible = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		label.visible = false
		access_text.visible = false


func start_hacking() -> void:
	hacking_in_progress = true
	label.visible = false

	hacking_ui.start_hacking(
		hacking_sequence_length,
		hacking_time_limit
	)


func _on_hacking_success() -> void:
	hacking_in_progress = false
	GameState.main_elevator_hacked = true

	# Make the elevator accessible
	door.play("default")

	# Show elevator access text if player is still nearby
	if player_in_range:
		access_text.visible = true


func _on_hacking_failed() -> void:
	hacking_in_progress = false

	# Allow another attempt
	if player_in_range:
		label.visible = true
