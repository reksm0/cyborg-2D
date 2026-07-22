extends Node2D

@onready var elevator_menu: CanvasLayer = $"Elevator Menu"
@onready var player: Player = $player
@onready var main_elevator: Node2D = $"Main elevator"

@onready var development_marker: Marker2D = $"Elevator Markers/Development Marker"
@onready var assembly_marker: Marker2D = $"Elevator Markers/Assembly Marker"
@onready var testing_marker: Marker2D = $"Elevator Markers/Testing Marker"
@onready var camera_2d: Camera2D = $player/Camera2D

enum Floor {
	DEVELOPMENT,
	ASSEMBLY,
	TESTING,
	GROUND
}

func _ready() -> void:
	
	TransitionManager.apply_spawn(player, $"Transition Points")
	
	elevator_menu.floor_selected.connect(_on_floor_selected)
	
	elevator_menu.current_floor = GameState.elevator_current_floor
	elevator_menu.update_menu()
	
	var spawn_position = get_floor_position(GameState.elevator_current_floor)
	main_elevator.global_position = spawn_position
	

func _process(delta):
	pass

func get_floor_position(floor: int) -> Vector2:
	match floor:
		Floor.DEVELOPMENT:
			return development_marker.global_position

		Floor.ASSEMBLY:
			return assembly_marker.global_position

		Floor.TESTING:
			return testing_marker.global_position
		
		# Uncomment when Ground Marker exists
		# Floor.GROUND:
		# 	return ground_marker.global_position
	
	return development_marker.global_position


func _on_floor_selected(floor):
	
	# Close menu and lock player controls
	player.animated_sprite_2d.play("idle")
	player.controls_enabled = false
	player.velocity = Vector2.ZERO
	elevator_menu.visible = false
	main_elevator.access_text.visible = false
	
	# Open elevator door
	main_elevator.door.play("open")
	await main_elevator.door.animation_finished
	
	# Player enters elevator
	main_elevator.door.z_index = 2
	
	# Close elevator door
	main_elevator.door.play("close")
	await main_elevator.door.animation_finished
	
	camera_2d.position_smoothing_speed = 20.0
	
	# Disable player collision
	player.collision_shape_2d.disabled = true
	
	var target_position = get_floor_position(floor)
	
	main_elevator.room.play("travel")
	
	# Move player and elevator together
	var tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(
		player,
		"global_position",
		target_position,
		1.2
	)
	
	tween.tween_property(
		main_elevator,
		"global_position",
		target_position,
		1.2
	)
	
	await tween.finished
	
	# Save elevator state
	GameState.elevator_current_floor = floor
	
	main_elevator.room.stop()
	main_elevator.room.play("default")
	
	# Update menu
	elevator_menu.current_floor = floor
	elevator_menu.update_menu()

	# Enable player collision
	player.collision_shape_2d.disabled = false
	camera_2d.position_smoothing_speed = 7.0

	# Open elevator door
	main_elevator.door.play("open")
	await main_elevator.door.animation_finished

	# Player exits elevator
	main_elevator.door.z_index = 1
	main_elevator.access_text.visible = true

	# Restore player
	player.velocity = Vector2.ZERO
	player.controls_enabled = true

	# Close elevator door
	main_elevator.door.play("close")
	await main_elevator.door.animation_finished
