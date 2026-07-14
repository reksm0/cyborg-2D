extends Node2D
@onready var elevator_menu: CanvasLayer = $"Elevator Menu"
@onready var player: Player = $player
@onready var main_elevator: Node2D = $"Main elevator"

@onready var development_marker: Marker2D = $"Elevator Markers/Development Marker"
@onready var assembly_marker: Marker2D = $"Elevator Markers/Assembly Marker"
@onready var testing_marker: Marker2D = $"Elevator Markers/Testing Marker"

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
	elevator_menu.visible = false
	player.controls_enabled = false
	
	# Open elevator door
	main_elevator.animated_sprite_2d.play("open")
	await main_elevator.animated_sprite_2d.animation_finished
	
	# Player enters elevator
	player.animated_sprite_2d.visible = false
	
	# Close elevator door
	main_elevator.animated_sprite_2d.play("close")
	await main_elevator.animated_sprite_2d.animation_finished
	
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
	
	# Update current floor
	elevator_menu.current_floor = floor
	elevator_menu.update_menu()
	
	# Player collision is enabled
	player.collision_shape_2d.disabled = false
	
	# Open elevator door
	main_elevator.animated_sprite_2d.play("open")
	await main_elevator.animated_sprite_2d.animation_finished
	
	# Player exits elevator
	player.animated_sprite_2d.visible = true
	
	# Close elevator door
	main_elevator.animated_sprite_2d.play("close")
	await main_elevator.animated_sprite_2d.animation_finished
	
	# Restore player
	player.controls_enabled = true
	
	
