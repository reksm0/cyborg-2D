extends CanvasLayer

@onready var fade_rect: ColorRect = $ColorRect
const FADE_TIME := 0.35

func fade_out() -> void:
	var tween = create_tween()
	tween.tween_property(
		fade_rect,
		"modulate:a",
		1.0,
		FADE_TIME
	)
	await tween.finished


func fade_in() -> void:
	var tween = create_tween()
	tween.tween_property(
		fade_rect,
		"modulate:a",
		0.0,
		FADE_TIME
	)
	await tween.finished


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
