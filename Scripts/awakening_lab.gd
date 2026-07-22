extends Node2D
@onready var player: Player = $player


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	TransitionManager.apply_spawn(player, $"Transition Points")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
