extends CharacterBody3D

var speed := 2.6
const GRAVITY := 9.8
var alive := true


func _physics_process(delta: float) -> void:
	if not alive:
		return
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0.0

	var target := get_tree().get_first_node_in_group("player")
	if target == null:
		return

	var dir: Vector3 = target.global_position - global_position
	dir.y = 0
	if dir.length() > 0.1:
		dir = dir.normalized()
		velocity.x = dir.x * speed
		velocity.z = dir.z * speed
		move_and_slide()
		look_at(global_position + dir, Vector3.UP)


func die() -> void:
	alive = false
	set_physics_process(false)
	queue_free()
