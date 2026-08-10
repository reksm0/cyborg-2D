extends Area2D

@export_file("*.tscn")
var destination_scene: String

@export
var destination_spawn_marker: String

@export
var fade_color: Color = Color.BLACK


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		TransitionManager.transition_to(
			destination_scene,
			destination_spawn_marker,
			fade_color
		)
