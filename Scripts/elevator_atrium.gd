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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	elevator_menu.floor_selected.connect(_on_floor_selected)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

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
	main_elevator.door.z_index=2

	# Close elevator door
	main_elevator.door.play("close")
	await main_elevator.door.animation_finished
	
	camera_2d.position_smoothing_speed = 20.0 
	
	# Player collision is disbled
	player.collision_shape_2d.disabled = true
	
	# Find destination
	var target_position: Vector2
	
	match floor:
		Floor.DEVELOPMENT:
			target_position = development_marker.global_position
		
		Floor.ASSEMBLY:
			target_position = assembly_marker.global_position
		
		Floor.TESTING:
			target_position = testing_marker.global_position
	
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
	main_elevator.room.stop()
	main_elevator.room.play("default")
	# Update current floor
	elevator_menu.current_floor = floor
	elevator_menu.update_menu()
	
	# Player collision is enabled
	player.collision_shape_2d.disabled = false
	camera_2d.position_smoothing_speed = 7.0 
	
	# Open elevator door
	main_elevator.door.play("open")
	await main_elevator.door.animation_finished
	
	# Player exits elevator
	main_elevator.door.z_index=1
	main_elevator.access_text.visible = true
	
	# Restore player
	player.velocity = Vector2.ZERO
	player.controls_enabled = true
	
	# Close elevator door
	main_elevator.door.play("close")
	await main_elevator.door.animation_finished
	
	
	
	
