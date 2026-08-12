extends CanvasLayer


# Node references — adjust path if your tree differs
@onready var button_new_game = $Control/mainmenu/Button1
@onready var button_continue = $Control/mainmenu/Button2
@onready var button_credits  = $Control/mainmenu/Button3
@onready var button_exit     = $Control/mainmenu/Button4

# Scene paths — change these to match your actual file locations
const GAME_SCENE_PATH = "res://Scenes/rooms/awake.tscn"
const CREDITS_SCENE_PATH = "res://Scenes/UI/credits.tscn"

func _ready():
	# Connect all button signals via code (no need to click in editor)
	button_new_game.pressed.connect(_on_new_game_pressed)
	button_continue.pressed.connect(_on_continue_pressed)
	button_credits.pressed.connect(_on_credits_pressed)
	button_exit.pressed.connect(_on_exit_pressed)
	#func _on_button1_pressed():
	#get_tree().change_scene_to_file("res://Scenes/rooms/awakening_lab.tscn".tscn")

	# Disable Continue button if no save file exists
	button_continue.disabled = not FileAccess.file_exists("user://savegame.save")


func _on_new_game_pressed():
	# Optional: clear old save data here if you want a fresh start
	get_tree().change_scene_to_file(GAME_SCENE_PATH)


func _on_continue_pressed():
	# Load save data (implement your own save/load logic)
	if FileAccess.file_exists("user://savegame.save"):
		get_tree().change_scene_to_file(GAME_SCENE_PATH)
		# TODO: call your load_game() function after scene loads


func _on_credits_pressed():
	get_tree().change_scene_to_file(CREDITS_SCENE_PATH)
	# Alternative: if credits is just a popup/panel instead of new scene:
	# $Control/mainmenu/CreditsPanel.visible = true


func _on_exit_pressed():
	get_tree().quit()
