extends CanvasLayer

@onready var fade_rect: ColorRect = $ColorRect

const FADE_TIME := 0.35

func set_fade_color(color: Color) -> void:
	fade_rect.color = color


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


func _ready() -> void:
	pass
