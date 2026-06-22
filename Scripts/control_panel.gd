extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var label: Label = $Label
var player_in_range = false
var hacked = false
signal hacked_successfully

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if hacked:
		return

	if player_in_range and Input.is_action_just_pressed("interact"):
		start_hack()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		if !hacked:
			label.visible = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		label.visible = false

func start_hack():
	hacked = true
	label.visible = false
	animated_sprite_2d.play("deactivated")
	emit_signal("hacked_successfully")
