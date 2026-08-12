extends CanvasLayer

signal hack_success
signal hack_failed

@export var sequence_length: int 
@onready var sequence_container: HBoxContainer = $HackingPanel/PanelContent/SequenceContainer
@onready var arrow_template: TextureRect = $HackingPanel/PanelContent/SequenceContainer/ArrowTemplate
@export var glowing_arrow_sheet: Texture2D
@export var glowing_symbol_sheet: Texture2D
@export var red_arrow_sheet: Texture2D
@export var red_symbol_sheet: Texture2D
@export var time_limit: float = 5.0

@onready var left_panel: AnimatedSprite2D = $HackingPanel/PanelContent/Left
@onready var middle_red: TextureRect = $HackingPanel/PanelContent/MiddleRed
@onready var middle_blue: TextureRect = $HackingPanel/PanelContent/MiddleBlue
@onready var right_panel: AnimatedSprite2D = $HackingPanel/PanelContent/Right
@onready var time_bar: ColorRect = $HackingPanel/PanelContent/TimeBar
@onready var hack_result: Label = $HackingPanel/PanelContent/HackResult
@onready var hacking_panel: PanelContainer = $HackingPanel

var sequence: Array[int] = []
var current_index: int = 0
var hacking: bool = false
var time_left: float = 0.0
var time_bar_width: float

var panel_original_position: Vector2
var shake_time: float = 0.0
var shake_strength: float = 10.0
var shake_horizontal: bool = true
var shake_vertical: bool = false

var collapse_delay: float = 0.1
var collapse_time: float = 0.0
var success_hide_time: float = 0.0

var up_texture: AtlasTexture
var down_texture: AtlasTexture
var left_texture: AtlasTexture
var right_texture: AtlasTexture



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	panel_original_position = hacking_panel.position
	time_bar_width = time_bar.size.x
	reset_hacking_ui()
	
	hacking_panel.visible = false

func _input(event: InputEvent) -> void:
	if not hacking:
		return
	
	if event.is_action_pressed("hack_up"):
		check_input(0)
	elif event.is_action_pressed("hack_down"):
		check_input(1)
	elif event.is_action_pressed("hack_left"):
		check_input(2)
	elif event.is_action_pressed("hack_right"):
		check_input(3)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if hacking:
		time_left -= delta
		time_left = max(time_left, 0.0)
		
		var ratio = time_left / time_limit
		var new_width = time_bar_width * ratio
		
		time_bar.size.x = new_width
		time_bar.position.x = 32.0 + (time_bar_width - new_width) / 2.0
		if time_left <= 0.0:
			fail_hacking()
	
	if shake_time > 0.0:
		shake_time -= delta
		
		#var shake_x = randf_range(-shake_strength, shake_strength)
		var shake_x = sin(shake_time * 80.0) * shake_strength
		var shake_y = 0.0
		
		if shake_vertical:
			shake_y = randf_range(-shake_strength, shake_strength)
		
		hacking_panel.position = panel_original_position + Vector2(shake_x, shake_y)
	else:
		hacking_panel.position = panel_original_position
		
		if collapse_time > 0.0:
			collapse_time -= delta
			
			if collapse_time <= 0.0:
				hacking_panel.visible = false
				Global.playerBody.controls_enabled = true
	
	if success_hide_time > 0.0:
		success_hide_time -= delta
		if success_hide_time <= 0.0:
			hacking_panel.visible = false
			Global.playerBody.controls_enabled = true

func check_input(input_direction: int) -> void:
	if current_index >= sequence.size():
		return
	
	if input_direction == sequence[current_index]:
		var current_arrow = sequence_container.get_child(current_index + 1) as TextureRect
		current_arrow.texture = get_glowing_symbol()
		
		current_index += 1
		
		if current_index < sequence.size():
			var next_arrow = sequence_container.get_child(current_index + 1) as TextureRect
			next_arrow.texture = get_glowing_arrow(sequence[current_index])
		else:
			hacking_success()
	else:
		fail_hacking()

func create_sequence() -> void:
	for i in range(sequence_length):
		var arrow = arrow_template.duplicate()
		arrow.name = "Arrow%d" % (i + 1)
		arrow.visible = true
		
		var direction = randi_range(0, 3)
		sequence.append(direction)
		arrow.texture = get_normal_arrow(direction)
		
		sequence_container.add_child(arrow)
	
	if sequence_container.get_child_count() > 1:
		var first_arrow = sequence_container.get_child(1) as TextureRect
		first_arrow.texture = get_glowing_arrow(sequence[0])

func hacking_success() -> void:
	hacking = false
	time_left = 0.0
	success_hide_time = 0.5
	
	time_bar.visible = false
	hack_result.visible = true
	hack_result.text = "HACKING SUCCESSFUL"
	hack_result.modulate = Color("bcc9f8ff")
	
	hack_success.emit()

func fail_hacking() -> void:
	hacking = false
	shake_panel()
	
	time_bar.visible = false
	hack_result.visible = true
	hack_result.text = "HACKING FAILED"
	hack_result.modulate = Color("ff3f30ff")
	
	left_panel.play("red")
	right_panel.play("red")
	
	middle_blue.visible = false
	middle_red.visible = true
	
	for i in range(sequence.size()):
		var arrow = sequence_container.get_child(i + 1) as TextureRect
		
		if i < current_index:
			arrow.texture = get_red_symbol()
		else:
			arrow.texture = get_red_arrow(sequence[i])
	
		hack_failed.emit()

func shake_panel() -> void:
	shake_time = 0.3
	collapse_time = shake_time + collapse_delay

func get_normal_arrow(direction: int) -> AtlasTexture:
	var texture := arrow_template.texture.duplicate() as AtlasTexture
	match direction:
		0: # UP
			texture.region = Rect2(64, 0, 32, 32)
		1: # DOWN
			texture.region = Rect2(0, 64, 32, 32)
		2: # LEFT
			texture.region = Rect2(64, 64, 32, 32)
		3: # RIGHT
			texture.region = Rect2(0, 0, 32, 32)
	return texture

func get_glowing_arrow(direction: int) -> AtlasTexture:
	var texture := AtlasTexture.new()
	texture.atlas = glowing_arrow_sheet
	match direction:
		0: # UP
			texture.region = Rect2(64, 0, 32, 32)
		1: # DOWN
			texture.region = Rect2(0, 64, 32, 32)
		2: # LEFT
			texture.region = Rect2(0, 0, 32, 32)
		3: # RIGHT
			texture.region = Rect2(64, 64, 32, 32)
	return texture

func get_glowing_symbol() -> AtlasTexture:
	var texture := AtlasTexture.new()
	texture.atlas = glowing_symbol_sheet
	texture.region = Rect2(0, 0, 32, 32)
	return texture

func get_red_arrow(direction: int) -> AtlasTexture:
	var texture := AtlasTexture.new()
	texture.atlas = red_arrow_sheet
	match direction:
		0: # UP
			texture.region = Rect2(64, 0, 32, 32)
		1: # DOWN
			texture.region = Rect2(0, 64, 32, 32)
		2: # LEFT
			texture.region = Rect2(64, 64, 32, 32)
		3: # RIGHT
			texture.region = Rect2(0, 0, 32, 32)
	return texture

func get_red_symbol() -> AtlasTexture:
	var texture := AtlasTexture.new()
	texture.atlas = red_symbol_sheet
	texture.region = Rect2(0, 0, 32, 32)
	return texture

func reset_hacking_ui() -> void:
	sequence.clear()
	current_index = 0
	for child in sequence_container.get_children():
		if child != arrow_template:
			child.free()
	
	time_left = 0.0
	
	hacking_panel.visible = true
	time_bar.visible = true
	hack_result.visible = false
	
	left_panel.play("blue")
	right_panel.play("blue")
	
	middle_blue.visible = true
	middle_red.visible = false
	
	hacking_panel.position = panel_original_position
	
	shake_time = 0.0
	collapse_time = 0.0
	success_hide_time = 0.0
	
	time_bar.size.x = time_bar_width
	time_bar.position.x = 32.0

func start_hacking(new_sequence_length: int, new_time_limit: float) -> void:
	reset_hacking_ui()
	
	sequence_length = new_sequence_length
	time_limit = new_time_limit
	
	time_bar_width = time_bar.size.x
	time_left = time_limit
	hacking = true
	Global.playerBody.controls_enabled = false
	hacking_panel.visible = true
	
	create_sequence()
	hack_result.visible = false
	time_bar.visible = true
