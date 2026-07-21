extends Node

enum Floor {
	DEVELOPMENT,
	ASSEMBLY,
	TESTING,
	GROUND
}

# Default Player Data
const DEFAULT_MAX_HEALTH := 5

# Player Data
var player_max_health := DEFAULT_MAX_HEALTH
var player_health := DEFAULT_MAX_HEALTH

#Inventory Key Items
var has_encryption_key := false


# World Progress
var awakening_panel_hacked := false
var main_elevator_hacked := false
var ground_unlocked := false

# Elevator System
var elevator_current_floor := Floor.DEVELOPMENT
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
