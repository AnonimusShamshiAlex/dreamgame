extends CharacterBody3D

const SPEED := 4.5
const JUMP_VELOCITY := 5.5
const GRAVITY := 12.0
const LOOK_SENSITIVITY := 0.006

var move_vector := Vector2.ZERO
var look_delta := Vector2.ZERO
var camera_pitch := 0.0
var controls_enabled := false

@onready var camera: Camera3D = $Camera3D


func _physics_process(delta: float) -> void:
	if not controls_enabled:
		return

	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	var direction := (transform.basis * Vector3(move_vector.x, 0.0, move_vector.y)).normalized()
	if direction.length() > 0.01:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)
		velocity.z = move_toward(velocity.z, 0.0, SPEED)

	move_and_slide()

	if look_delta.length() > 0.0:
		rotate_y(-look_delta.x * LOOK_SENSITIVITY)
		camera_pitch = clamp(camera_pitch - look_delta.y * LOOK_SENSITIVITY, -1.3, 1.3)
		camera.rotation.x = camera_pitch
		look_delta = Vector2.ZERO


func jump() -> void:
	if controls_enabled and is_on_floor():
		velocity.y = JUMP_VELOCITY


func set_move_vector(v: Vector2) -> void:
	move_vector = v


func add_look_delta(d: Vector2) -> void:
	look_delta += d


func enable_controls() -> void:
	controls_enabled = true
