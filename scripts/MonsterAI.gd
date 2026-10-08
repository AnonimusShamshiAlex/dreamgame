extends Node3D

@export var speed := 8.5
@export var catch_distance := 1.6

var target: Node3D = null
var chasing := false


func _process(delta: float) -> void:
	if not chasing or target == null:
		return

	var dir := target.global_position - global_position
	dir.y = 0.0
	if dir.length() > 0.05:
		dir = dir.normalized()
		global_position += dir * speed * delta
		look_at(global_position + dir, Vector3.UP)


func start_chase(t: Node3D) -> void:
	target = t
	chasing = true
	visible = true


func stop_chase() -> void:
	chasing = false
	visible = false


func distance_to_target() -> float:
	if target == null:
		return INF
	return global_position.distance_to(target.global_position)
