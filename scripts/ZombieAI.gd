extends CharacterBody3D

var speed := 2.6
const AGGRO_RANGE := 38.0
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
	# Zombies only wake up when the player is close; otherwise they stand in
	# their zone instead of marching across the whole world to the hub.
	if dir.length() > AGGRO_RANGE:
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		return
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
