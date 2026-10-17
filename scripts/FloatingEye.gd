extends Node3D

var base_y := 0.0
var phase := 0.0
var bob_speed := 0.6
var bob_height := 1.5
var turn_speed := 0.3


func _ready() -> void:
	base_y = position.y
	phase = randf() * TAU
	turn_speed = randf_range(0.15, 0.4)


func _process(delta: float) -> void:
	phase += delta * bob_speed
	position.y = base_y + sin(phase) * bob_height
	rotate_y(turn_speed * delta)
