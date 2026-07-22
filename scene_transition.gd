extends Area2D

@export_file("*.tscn")
var destination_scene: String

@export
var destination_spawn_marker: String


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		TransitionManager.transition_to(
			destination_scene,
			destination_spawn_marker
		)
