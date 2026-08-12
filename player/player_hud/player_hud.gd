#player_hud
extends CanvasLayer
@onready var hp_margin_container: MarginContainer = %HPMarginContainer
@onready var hp_bar: TextureProgressBar = $Control/HPMarginContainer/NinePatchRect/HPBar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player = get_tree().get_first_node_in_group("player")

	if player:
		player.health_changed.connect(update_health_bar)
		update_health_bar(player.health, player.max_health)

func update_health_bar(hp: float, max_hp: float) -> void:
	if max_hp <= 0:
		return

	var value = (hp / max_hp) * 100
	hp_bar.value = value
	#hp_margin_container.size.x = max_hp + 22

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
