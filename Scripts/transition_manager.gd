extends Node


func transition_to(scene_path: String, spawn_marker: String) -> void:
	GameState.transition_spawn_marker = spawn_marker
	call_deferred("_change_scene", scene_path)


func _change_scene(scene_path: String) -> void:
	await FadeLayer.fade_out()

	get_tree().change_scene_to_file(scene_path)

	await get_tree().process_frame

	await FadeLayer.fade_in()


func apply_spawn(
	player: Player,
	camera: Camera2D,
	transition_points: Node2D
) -> void:

	if GameState.transition_spawn_marker.is_empty():
		return

	var marker := transition_points.get_node_or_null(
		GameState.transition_spawn_marker
	) as Marker2D

	if marker:
		player.global_position = marker.global_position
		camera.reset_smoothing()
	else:
		push_warning(
			"Spawn marker '%s' not found." %
			GameState.transition_spawn_marker
		)

	GameState.transition_spawn_marker = ""
