extends Node3D

var home := Vector3.ZERO
var target := Vector3.ZERO
var ground_speed := 1.1
var fly_speed := 2.2
var wander_radius := 9.0

var flying := false
var state_timer := 0.0
var bob_phase := 0.0


func _ready() -> void:
	home = position
	state_timer = randf_range(5.0, 10.0)
	_pick_ground_target()


func _pick_ground_target() -> void:
	var angle := randf() * TAU
	var dist := randf_range(2.0, wander_radius)
	target = home + Vector3(cos(angle) * dist, 0, sin(angle) * dist)


func _pick_fly_target() -> void:
	var angle := randf() * TAU
	var dist := randf_range(2.0, wander_radius * 1.4)
	var h := randf_range(3.5, 7.0)
	target = home + Vector3(cos(angle) * dist, h, sin(angle) * dist)


func _process(delta: float) -> void:
	state_timer -= delta
	if state_timer <= 0.0:
		flying = not flying
		state_timer = randf_range(6.0, 12.0) if flying else randf_range(5.0, 10.0)
		if flying:
			_pick_fly_target()
		else:
			_pick_ground_target()

	bob_phase += delta

	var dir := target - position
	var dist_to_target := dir.length()
	var speed := fly_speed if flying else ground_speed

	if dist_to_target > 0.4:
		var step: Vector3 = dir.normalized() * speed * delta
		if step.length() > dist_to_target:
			position = target
		else:
			position += step
		var flat_dir := dir
		flat_dir.y = 0
		if flat_dir.length() > 0.1:
			look_at(position + flat_dir, Vector3.UP)
	else:
		if flying:
			# gentle hover bob while "deciding" where to go next
			position.y = target.y + sin(bob_phase * 2.0) * 0.3
		if state_timer < 0.5:
			if flying:
				_pick_fly_target()
			else:
				_pick_ground_target()
