extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func transition_to(scene_path: String, spawn_marker: String) -> void:
	GameState.transition_spawn_marker = spawn_marker
	call_deferred("_change_scene", scene_path)


func _change_scene(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)

func apply_spawn(player: Player, transition_points: Node2D) -> void:
	print("--------------------------------")
	print("Spawn marker =", GameState.transition_spawn_marker)

	print("Markers available:")

	for child in transition_points.get_children():
		print(child.name)

	if GameState.transition_spawn_marker.is_empty():
		print("EMPTY")
		return

	var marker = transition_points.get_node_or_null(
		GameState.transition_spawn_marker
	)

	if marker == null:
		print("NOT FOUND")
	else:
		print("FOUND:", marker.name)
		player.global_position = marker.global_position

	GameState.transition_spawn_marker = ""
