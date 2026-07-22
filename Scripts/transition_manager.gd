extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func transition_to(scene_path: String, spawn_marker: String) -> void:
	GameState.transition_spawn_marker = spawn_marker
	get_tree().change_scene_to_file(scene_path)

func apply_spawn(player: Player, transition_points: Node2D) -> void:
	if GameState.transition_spawn_marker.is_empty():
		return

	var marker := transition_points.get_node_or_null(
		GameState.transition_spawn_marker
	) as Marker2D

	if marker:
		player.global_position = marker.global_position
	else:
		push_warning(
			"Spawn marker '%s' not found." %
			GameState.transition_spawn_marker
		)

	GameState.transition_spawn_marker = ""
