extends Node3D

var home := Vector3.ZERO
var target := Vector3.ZERO
var speed := 1.3
var radius := 10.0
var wait_timer := 0.0
var glitchy := false
var glitch_timer := 0.0


func _ready() -> void:
	home = position
	_pick_new_target()
	glitch_timer = randf_range(4.0, 9.0)


func _pick_new_target() -> void:
	var angle := randf() * TAU
	var dist := randf_range(2.0, radius)
	target = home + Vector3(cos(angle) * dist, 0, sin(angle) * dist)
	wait_timer = randf_range(1.0, 3.5)


func _process(delta: float) -> void:
	if glitchy:
		glitch_timer -= delta
		if glitch_timer <= 0.0:
			glitch_timer = randf_range(3.0, 7.0)
			# a little reality hiccup — blink a short distance sideways
			var jump := Vector3(randf_range(-3.0, 3.0), 0, randf_range(-3.0, 3.0))
			global_position += jump

	var dir := target - global_position
	dir.y = 0
	if dir.length() > 0.3:
		dir = dir.normalized()
		global_position += dir * speed * delta
		look_at(global_position + dir, Vector3.UP)
	else:
		wait_timer -= delta
		if wait_timer <= 0.0:
			_pick_new_target()
