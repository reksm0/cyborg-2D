extends CanvasLayer
enum Floor {
	DEVELOPMENT,
	ASSEMBLY,
	TESTING,
	GROUND,
	UNKNOWN
}
var current_floor = Floor.DEVELOPMENT

var ground_unlocked := false
var has_encryption_key = false

@onready var development_button: Button = $"Floor List/Development Wing"
@onready var assembly_button: Button = $"Floor List/Assembly Wing"
@onready var testing_button: Button = $"Floor List/Testing Wing"
@onready var ground_button: Button = $"Floor List/Ground Exit"
@onready var unknown_button: Button = $"Floor List/Unknown Area"

const ICON_BLUE = preload("uid://gvmksfa2tsw2")
const ICON_GREEN = preload("uid://bjxdjytv2m62j")
const ICON_PURPLE = preload("uid://yro3owqidxxd")
const ICON_RED = preload("uid://hf0kwp20bkvm")

signal floor_selected(floor)

#Helper function
func set_button( button: Button, icon: Texture2D, enabled: bool):
	button.icon = icon
	button.disabled = !enabled

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_menu()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_menu():
	# Development
	if current_floor == Floor.DEVELOPMENT:
		set_button(development_button,ICON_BLUE,false)
	else:
		set_button(development_button,ICON_GREEN,true)
	
	# Assembly
	if current_floor == Floor.ASSEMBLY:
		set_button(assembly_button,ICON_BLUE,false)
	else:
		set_button(assembly_button,ICON_GREEN,true)
	
	# Testing
	if current_floor == Floor.TESTING:
		set_button(testing_button,ICON_BLUE,false)
	else:
		set_button(testing_button,ICON_GREEN,true)
	
	# Ground Exit
	if ground_unlocked:
		set_button(ground_button, ICON_GREEN, true)
	else:
		set_button(ground_button, ICON_RED, true)
	
	# Unknown Area
	set_button(unknown_button,ICON_PURPLE,false)

func _on_development_wing_pressed() -> void:
	emit_signal("floor_selected", Floor.DEVELOPMENT)

func _on_assembly_wing_pressed() -> void:
	emit_signal("floor_selected", Floor.ASSEMBLY)

func _on_testing_wing_pressed() -> void:
	emit_signal("floor_selected", Floor.TESTING)

func _on_ground_exit_pressed() -> void:
	# Already unlocked
	if ground_unlocked:
		emit_signal("floor_selected", Floor.GROUND)
		return
	
	# Player doesn't have the Encryption Key
	if !has_encryption_key:
		print("Encryption Key Required")
		return
	
	# Player has the key
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	print("   ENCRYPTION KEY ACCEPTED")
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	
	ground_unlocked = true
	update_menu()
	
	await get_tree().create_timer(0.5).timeout
	
	emit_signal("floor_selected", Floor.GROUND)
