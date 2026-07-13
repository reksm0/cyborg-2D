extends Node2D
@onready var label: Label = $Label
var player_in_range = false
var hacked = false
##signal hacked_successfully
@onready var elevator_menu: CanvasLayer = $"../Elevator Menu"
@onready var access_text: Label = $"access text"
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.visible = false
	access_text.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("interact") and hacked :
		elevator_menu.visible = true
	
	if elevator_menu.visible and Input.is_action_just_pressed("close"):
		elevator_menu.visible = false


	if player_in_range and Input.is_action_just_pressed("interact") and !hacked:
		print ("elevator hacked")
		hacked = true
		label.visible = false
		access_text.visible = true


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		if !hacked: 
			label.visible = true 
		else : 
			access_text.visible = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		label.visible = false
		access_text.visible = false
