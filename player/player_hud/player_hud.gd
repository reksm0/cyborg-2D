#player_hud
extends CanvasLayer
@onready var hp_margin_container: MarginContainer = %HPMarginContainer
@onready var hp_bar: TextureProgressBar = $Control/HPMarginContainer/NinePatchRect/HPBar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#connect to message bus of player state 
	pass # Replace with function body.

func update_health_bar( hp:float, max_hp:float ) -> void:
	var value : float=(hp/max_hp)*100
	hp_bar.value=value
	hp_margin_container.size.x = max_hp + 22
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
