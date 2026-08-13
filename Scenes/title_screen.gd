extends CanvasLayer

@onready var button_new_game = $Control/mainmenu/Button1
@onready var button_continue = $Control/mainmenu/Button2
@onready var button_credits = $Control/mainmenu/Button3
@onready var button_exit = $Control/mainmenu/Button4

const GAME_SCENE_PATH = "res://Scenes/rooms/awakening_lab.tscn"
const CREDITS_SCENE_PATH = "res://Scenes/credits.tscn"


func _ready():
	button_new_game.pressed.connect(_on_new_game_pressed)
	button_continue.pressed.connect(_on_continue_pressed)
	button_credits.pressed.connect(_on_credits_pressed)
	button_exit.pressed.connect(_on_exit_pressed)

	button_continue.disabled = not FileAccess.file_exists("user://savegame.save")


func _on_new_game_pressed():
	get_tree().change_scene_to_file(GAME_SCENE_PATH)


func _on_continue_pressed():
	if FileAccess.file_exists("user://savegame.save"):
		get_tree().change_scene_to_file(GAME_SCENE_PATH)


func _on_credits_pressed():
	get_tree().change_scene_to_file(CREDITS_SCENE_PATH)


func _on_exit_pressed():
	get_tree().quit()
