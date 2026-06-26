extends CharacterBody2D


const speed = 100
var dir: Vector2
var is_chase: bool

@onready var timer: Timer = $Timer

func _ready() -> void:
	is_chase = false
	
func _process(delta: float) -> void:
	move(delta)
	
func move(delta):
	if !is_chase:
		velocity += speed * dir * delta
	move_and_slide()
	


func _on_timer_timeout() -> void:
	timer.wait_time = choose([1.0,1.5,2.0])
	
	if !is_chase:
		dir = choose([Vector2.LEFT,Vector2.RIGHT,Vector2.UP,Vector2.DOWN])
		print(dir)
		
func choose(arr):
	arr.shuffle()
	return arr.front()
