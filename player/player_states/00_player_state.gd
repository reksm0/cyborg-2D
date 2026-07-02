@icon("res://player/player_states/state.svg")

class_name PlayerState extends Node

var player : Player
var next_state : PlayerState
#region /// state references
 #reference to all other state
#endregion

#to initilise state
func _init() -> void:
	pass
	
#things that might happen when u enter a state
func _enter() -> void:
	pass
	
func _exit() -> void:
	pass
	
func handle_input(_enter: InputEvent) -> void:
	return next_state






# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
