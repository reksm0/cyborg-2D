extends CanvasLayer


func _ready():
	PlayerHud.hide()
func _input(event):
	if event.is_action_pressed("close"):
		get_tree().change_scene_to_file("res://Scenes/title_screen.tscn")
