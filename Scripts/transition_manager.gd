extends Node


func transition_to(
	scene_path: String,
	spawn_marker: String,
	fade_color: Color = Color.BLACK
) -> void:
	GameState.transition_spawn_marker = spawn_marker
	call_deferred("_change_scene", scene_path, fade_color)


func _change_scene(
	scene_path: String,
	fade_color: Color
) -> void:
	
	# Set transition color
	FadeLayer.set_fade_color(fade_color)
	
	# Fade out
	await FadeLayer.fade_out()
	
	# Change scene
	get_tree().change_scene_to_file(scene_path)
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Special bright transition
	if fade_color == Color.WHITE:
		var current_scene := get_tree().current_scene
		if current_scene != null and current_scene.has_method("play_light_transition"):
			current_scene.play_light_transition()
	
	# Fade in
	await FadeLayer.fade_in()
	
	# Reset to normal black fade
	FadeLayer.set_fade_color(Color.BLACK)


func apply_spawn(
	player: Player,
	camera: Camera2D,
	transition_points: Node2D
) -> void:

	print("Markers available:")

	for child in transition_points.get_children():
		print(child.name)

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
