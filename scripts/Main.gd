extends Node3D

var player: CharacterBody3D
var monster: Node3D
var chase_zone_center := Vector3(0, 0, -95)
var chase_zone_radius := 20.0
var chase_triggered := false
var player_caught := false
var caught_overlay: ColorRect
var caught_label: Label
var puzzle_message_label: Label
var circus_sequence := ["КРАСНЫЙ", "ЖЁЛТЫЙ", "СИНИЙ", "ЗЕЛЁНЫЙ"]
var circus_progress := 0
var circus_solved := false
var shells_collected := 0
const TOTAL_SHELLS := 5
var joystick_active := false
var joystick_touch_index := -1
var joystick_center := Vector2.ZERO
var joystick_knob: Control
var joystick_base: Control
const JOYSTICK_RADIUS := 70.0

var look_touch_index := -1

var jump_button_rect: Rect2

var intro_lines := [
	"Ты в странном сне...",
	"Вдали — ПЛЯЖ, там солнце никогда не садится.",
	"Справа — ЦИРК, там всё сплошная загадка.",
	"На юге — КРАСНЫЙ ГОРОД, его улицы красные и тихие.",
	"На западе — КОРПОРАТИВНАЯ БАШНЯ, тысячи окон и ни души.",
	"На северо-востоке — СТРАННЫЙ МИР, лабиринт, в котором легко заблудиться.",
	"Иди, почувствуй этот мир. Нажми на экран и начни.",
]
var intro_index := 0
var intro_active := true
var dialogue_panel: Control
var dialogue_label: Label

@onready var canvas: CanvasLayer

var sky_environment: Environment
var sun_light: DirectionalLight3D
var rain_particles: GPUParticles3D
var is_raining := false
var weather_timer := 0.0
var cloud_roots: Array = []
var player_camera: Camera3D
const ZOMBIE_ZONE_CENTER := Vector3(110, 0, -165)
const ZOMBIE_ZONE_RADIUS := 45.0
const MAX_ZOMBIES := 10
var zombies: Array = []
var zombie_spawn_timer := 0.0
var gun_in_zone := false
var gun_button_rect: Rect2
var shoot_cooldown := 0.0
const SHOOT_COOLDOWN_TIME := 0.25
var gun_button_node: Control
var gun_label_node: Label

const LAVASH_POS := Vector3(-14, 0, -2)
var lavash_state := "empty"
var lavash_timer := 4.0
var lavash_customer_node: Node3D
var lavash_customer_type: Dictionary = {}
const ROPE_ORIGIN := Vector3(300, 60, 300)
const ROPE_LENGTH := 70.0
var in_rope_challenge := false
var rope_environment: Environment
var flashlight: SpotLight3D
const FALLEN_CHAMBER_ORIGIN := Vector3(300, 10, 400)
var fallen_chamber_active := false
var fallen_riddle_answer := 0
var fallen_lever_labels: Array = []
var fallen_lever_values: Array = []

var lavash_customer_types := [
	{"color": Color(0.85, 0.65, 0.4), "arrive": "Здравствуйте! Один лаваш, пожалуйста.", "served": "Спасибо, пахнет отлично!"},
	{"color": Color(0.05, 0.05, 0.08), "arrive": "...лаваш... дайте... лаваш...", "served": "Тень молча растворяется в темноте."},
	{"color": Color(0.35, 0.45, 0.3), "arrive": "Ммм... лааваааш...", "served": "Зомби доволен. На удивление."},
]
var train: Node3D
var train_waypoints: Array = []
var train_target_index := 1
const TRAIN_SPEED := 10.0
const TRAIN_STATION_INDEX := 0
const TRAIN_STOP_DURATION := 8.0
var train_stopped := false
var train_stop_timer := 0.0
var in_train := false
var showman: Node3D
var showman_riddle_cooldown := 0.0
var showman_riddles := [
	"Что всегда впереди тебя, но ты никогда его не догонишь?",
	"В цирке есть вход, в городе — выход. А где вход в тебя самого?",
	"Чем дальше идёшь — тем ближе становится Странный мир...",
	"Сосед с лопатой не любит гостей. Беги, если услышишь шаги.",
	"Собери ракушки на пляже — море любит отдавать подарки.",
	"Наверху, в офисе без людей, кто-то забыл погасить мониторы...",
	"Радуга тут не обманывает — под ней правда можно пройти.",
	"В лесу ты не один. Просто остальные прячутся лучше.",
]


func _ready() -> void:
	_setup_environment()
	_setup_lighting()
	_setup_ground()
	_setup_ambient_music()
	_setup_landmarks()
	_setup_showman()
	_setup_sky_eyes()
	_setup_rainbow_arch()
	_setup_pink_door()
	_setup_pink_house()
	_setup_photo_murals()
	_setup_clouds()
	_setup_rain()
	_setup_npcs()
	_setup_forest()
	_setup_zombie_zone()
	_setup_lavash_shop()
	_setup_rope_challenge()
	_setup_train()
	_setup_roads()
	_setup_neighborhood()
	_setup_player()
	_setup_monster()
	_setup_ui()
	_show_intro_line()


# ---------------- WORLD ----------------

func _setup_environment() -> void:
	var world_env := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY

	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.25, 0.55, 0.95)
	sky_material.sky_horizon_color = Color(0.75, 0.88, 0.98)
	sky_material.ground_bottom_color = Color(0.45, 0.65, 0.35)
	sky_material.ground_horizon_color = Color(0.75, 0.88, 0.98)
	sky_material.sun_angle_max = 22.0

	var sky := Sky.new()
	sky.sky_material = sky_material
	env.sky = sky

	env.fog_enabled = true
	env.fog_light_color = Color(0.85, 0.92, 1.0)
	env.fog_density = 0.0035
	env.fog_sun_scatter = 0.1

	env.glow_enabled = true
	env.glow_intensity = 0.35
	env.glow_bloom = 0.04
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC

	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.7

	env.adjustment_enabled = true
	env.adjustment_brightness = 1.0
	env.adjustment_contrast = 1.2
	env.adjustment_saturation = 1.35

	world_env.environment = env
	add_child(world_env)
	sky_environment = env


func _setup_ambient_music() -> void:
	var music := AudioStreamPlayer.new()
	music.set_script(load("res://scripts/AmbientMusic.gd"))
	add_child(music)


func _setup_lighting() -> void:
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-35, -25, 0)
	sun.light_color = Color(1.0, 0.9, 0.75)
	sun.light_energy = 1.3
	sun.shadow_enabled = true
	sun.light_cull_mask = 1  # layer 1 = the normal, lit world
	add_child(sun)
	sun_light = sun


const GROUND_RADIUS := 520.0


func _setup_ground() -> void:
	var ground := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = GROUND_RADIUS
	mesh.bottom_radius = GROUND_RADIUS
	mesh.height = 1.0
	mesh.radial_segments = 64
	ground.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.35, 0.62, 0.28)
	mat.albedo_texture = _make_checker_texture(Color(0.33, 0.6, 0.26), Color(0.4, 0.68, 0.32))
	mat.uv1_scale = Vector3(90, 90, 1)
	mat.roughness = 0.95
	ground.material_override = mat
	ground.position = Vector3(0, -0.5, 0)
	add_child(ground)

	var body := StaticBody3D.new()
	var col := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = GROUND_RADIUS
	shape.height = 1.0
	col.shape = shape
	col.position = Vector3(0, -0.5, 0)
	body.add_child(col)
	add_child(body)


func _make_label(text: String, pos: Vector3, color: Color = Color.WHITE) -> void:
	var label := Label3D.new()
	label.text = text
	label.position = pos
	label.font_size = 72
	label.outline_size = 14
	label.modulate = color
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(label)


func _make_checker_texture(color_a: Color, color_b: Color) -> ImageTexture:
	var img := Image.create(64, 64, false, Image.FORMAT_RGB8)
	img.fill_rect(Rect2i(0, 0, 32, 32), color_a)
	img.fill_rect(Rect2i(32, 0, 32, 32), color_b)
	img.fill_rect(Rect2i(0, 32, 32, 32), color_b)
	img.fill_rect(Rect2i(32, 32, 32, 32), color_a)
	return ImageTexture.create_from_image(img)


func _make_mural(path: String, pos: Vector3, size: Vector2, rot_y_deg: float) -> void:
	var mural := MeshInstance3D.new()
	var mesh := PlaneMesh.new()
	mesh.size = size
	mesh.orientation = PlaneMesh.FACE_Z
	mural.mesh = mesh
	var tex: Texture2D = load(path)
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = tex
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.emission_enabled = true
	mat.emission_texture = tex
	mat.emission_energy_multiplier = 0.35
	mural.material_override = mat
	mural.position = pos
	mural.rotation_degrees = Vector3(0, rot_y_deg, 0)
	add_child(mural)

	# thin frame behind it so it reads like a sign/poster, not a floating cutout
	var frame := MeshInstance3D.new()
	var frame_mesh := BoxMesh.new()
	frame_mesh.size = Vector3(size.x + 0.4, size.y + 0.4, 0.15)
	frame.mesh = frame_mesh
	var frame_mat := StandardMaterial3D.new()
	frame_mat.albedo_color = Color(0.1, 0.08, 0.12)
	frame.material_override = frame_mat
	frame.position = pos + Vector3(0, 0, -0.1).rotated(Vector3.UP, deg_to_rad(rot_y_deg))
	frame.rotation_degrees = Vector3(0, rot_y_deg, 0)
	add_child(frame)


var _brick_tex: ImageTexture = null


func _get_brick_texture() -> ImageTexture:
	if _brick_tex != null:
		return _brick_tex
	var img := Image.create(32, 32, false, Image.FORMAT_RGB8)
	img.fill(Color(1, 1, 1))
	for y in range(32):
		for x in range(32):
			var on_line: bool = (x % 16 == 0) or (y % 8 == 0) or ((y / 8) % 2 == 1 and x % 16 == 8)
			if on_line:
				img.set_pixel(x, y, Color(0.72, 0.72, 0.72))
	_brick_tex = ImageTexture.create_from_image(img)
	return _brick_tex


func _box(size: Vector3, pos: Vector3, color: Color, solid: bool = true) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.albedo_texture = _get_brick_texture()
	mat.uv1_scale = Vector3(max(size.x, size.z) / 2.5, size.y / 2.5, 1)
	mat.roughness = 0.85
	mi.material_override = mat
	mi.position = pos
	add_child(mi)

	if solid:
		var body := StaticBody3D.new()
		var col := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		col.shape = shape
		body.position = pos
		body.add_child(col)
		add_child(body)

	return mi


func _setup_landmarks() -> void:
	# ---- BEACH (north) ----
	var sun_mi := MeshInstance3D.new()
	var sun_mesh := SphereMesh.new()
	sun_mesh.radius = 8.0
	sun_mesh.height = 16.0
	sun_mi.mesh = sun_mesh
	var sun_mat := StandardMaterial3D.new()
	sun_mat.albedo_color = Color(1.0, 0.8, 0.4)
	sun_mat.emission_enabled = true
	sun_mat.emission = Color(1.0, 0.7, 0.3)
	sun_mat.emission_energy_multiplier = 2.0
	sun_mi.material_override = sun_mat
	sun_mi.position = Vector3(0, 25, -140)
	add_child(sun_mi)

	var water := MeshInstance3D.new()
	var water_mesh := PlaneMesh.new()
	water_mesh.size = Vector2(60, 40)
	water.mesh = water_mesh
	var water_mat := StandardMaterial3D.new()
	water_mat.albedo_color = Color(0.3, 0.75, 0.8, 0.85)
	water_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	water.material_override = water_mat
	water.position = Vector3(0, 0.05, -100)
	add_child(water)

	_box(Vector3(0.6, 6, 0.6), Vector3(-8, 3, -90), Color(1, 1, 1))
	var umbrella := MeshInstance3D.new()
	var um_mesh := CylinderMesh.new()
	um_mesh.top_radius = 6.0
	um_mesh.bottom_radius = 6.0
	um_mesh.height = 0.5
	umbrella.mesh = um_mesh
	var um_mat := StandardMaterial3D.new()
	um_mat.albedo_color = Color(1.0, 0.3, 0.4)
	umbrella.material_override = um_mat
	umbrella.position = Vector3(-8, 6, -90)
	add_child(umbrella)
	_make_label("ПЛЯЖ", Vector3(-8, 10, -90), Color(1, 0.9, 0.6))
	_setup_beach_details()

	# ---- CIRCUS (east) ----
	var tent_body := MeshInstance3D.new()
	var tent_mesh := CylinderMesh.new()
	tent_mesh.top_radius = 14.0
	tent_mesh.bottom_radius = 14.0
	tent_mesh.height = 10.0
	tent_body.mesh = tent_mesh
	var tent_mat := StandardMaterial3D.new()
	tent_mat.albedo_color = Color(0.95, 0.9, 0.85)
	tent_body.material_override = tent_mat
	tent_body.position = Vector3(140, 5, 0)
	add_child(tent_body)

	var tent_roof := MeshInstance3D.new()
	var roof_mesh := CylinderMesh.new()
	roof_mesh.top_radius = 0.5
	roof_mesh.bottom_radius = 15.0
	roof_mesh.height = 10.0
	tent_roof.mesh = roof_mesh
	var roof_mat := StandardMaterial3D.new()
	roof_mat.albedo_color = Color(0.85, 0.15, 0.25)
	tent_roof.material_override = roof_mat
	tent_roof.position = Vector3(140, 15, 0)
	add_child(tent_roof)
	_make_label("ЦИРК", Vector3(140, 25, 0), Color(1, 0.8, 0.85))
	_setup_circus_puzzle()

	# ---- RED CITY (south) — denser, varied palette ----
	var city_colors := [
		Color(0.55, 0.12, 0.15), Color(0.6, 0.2, 0.1), Color(0.5, 0.15, 0.3),
		Color(0.65, 0.3, 0.12), Color(0.45, 0.1, 0.2), Color(0.7, 0.25, 0.2),
	]
	var city_rng := RandomNumberGenerator.new()
	city_rng.seed = 42
	for row in range(2):
		for i in range(10):
			var h: float = city_rng.randf_range(10, 36)
			var xpos: float = -34 + i * 7.0
			var zpos: float = 112 + row * 16.0
			var col: Color = city_colors[(i + row * 3) % city_colors.size()]
			_box(Vector3(6, h, 6), Vector3(xpos, h / 2.0, zpos), col)
	_make_label("КРАСНЫЙ ГОРОД", Vector3(0, 40, 120), Color(1, 0.6, 0.6))
	_setup_parkour_course()

	# ---- CORPORATE SKYSCRAPER (west) ----
	var tower := _box(Vector3(14, 70, 14), Vector3(-140, 35, 0), Color(0.05, 0.08, 0.12))
	var tower_mat := StandardMaterial3D.new()
	tower_mat.albedo_color = Color(0.05, 0.08, 0.12)
	tower_mat.emission_enabled = true
	tower_mat.emission = Color(1.0, 0.85, 0.3)
	tower_mat.emission_energy_multiplier = 0.35
	tower.material_override = tower_mat
	_make_label("КОРПОРАТИВНАЯ БАШНЯ", Vector3(-140, 75, 0), Color(0.8, 0.9, 1))
	_setup_corporate_interior()
	_setup_distant_skyline()
	_setup_labyrinth()


const CIRCUS_CENTER := Vector3(140, 0, 0)


func _make_umbrella(pos: Vector3, color: Color) -> void:
	_box(Vector3(0.5, 5, 0.5), pos + Vector3(0, 2.5, 0), Color(1, 1, 1), false)
	var top := MeshInstance3D.new()
	var top_mesh := CylinderMesh.new()
	top_mesh.top_radius = 4.5
	top_mesh.bottom_radius = 4.5
	top_mesh.height = 0.4
	top.mesh = top_mesh
	var top_mat := StandardMaterial3D.new()
	top_mat.albedo_color = color
	top.material_override = top_mat
	top.position = pos + Vector3(0, 5, 0)
	add_child(top)


func _make_palm(pos: Vector3) -> void:
	var trunk := MeshInstance3D.new()
	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.25
	trunk_mesh.bottom_radius = 0.4
	trunk_mesh.height = 6.0
	trunk.mesh = trunk_mesh
	var trunk_mat := StandardMaterial3D.new()
	trunk_mat.albedo_color = Color(0.4, 0.28, 0.18)
	trunk.material_override = trunk_mat
	trunk.position = pos + Vector3(0, 3, 0)
	trunk.rotation_degrees = Vector3(0, 0, randf_range(-6, 6))
	add_child(trunk)

	var leaf_mat := StandardMaterial3D.new()
	leaf_mat.albedo_color = Color(0.25, 0.6, 0.3)
	for a in range(6):
		var leaf := MeshInstance3D.new()
		var leaf_mesh := BoxMesh.new()
		leaf_mesh.size = Vector3(3.2, 0.15, 0.7)
		leaf.mesh = leaf_mesh
		leaf.material_override = leaf_mat
		leaf.position = pos + Vector3(0, 6.2, 0)
		leaf.rotation_degrees = Vector3(20, a * 60, 0)
		add_child(leaf)


func _setup_distant_skyline() -> void:
	# A broad ring of varied-height, varied-colored buildings surrounding
	# the whole world at a distance — pure background silhouette, no
	# collision, so it never gets in the way of actual gameplay.
	var palette := [
		Color(0.5, 0.15, 0.2), Color(0.15, 0.35, 0.5), Color(0.55, 0.35, 0.12),
		Color(0.3, 0.2, 0.5), Color(0.15, 0.45, 0.4), Color(0.6, 0.25, 0.45),
		Color(0.45, 0.45, 0.15), Color(0.2, 0.2, 0.25), Color(0.6, 0.4, 0.2),
		Color(0.25, 0.5, 0.3),
	]

	var rng := RandomNumberGenerator.new()
	rng.seed = 7

	# near ring — denser now
	var count := 70
	var radius := 215.0
	for i in range(count):
		var angle: float = (float(i) / count) * TAU + rng.randf_range(-0.04, 0.04)
		var r: float = radius + rng.randf_range(-15.0, 25.0)
		var x: float = cos(angle) * r
		var z: float = sin(angle) * r
		var h: float = rng.randf_range(16.0, 55.0)
		var w: float = rng.randf_range(5.0, 11.0)
		var color: Color = palette[rng.randi_range(0, palette.size() - 1)]
		_box(Vector3(w, h, w), Vector3(x, h / 2.0, z), color, false)

	# far ring — fills the expanded, "endless" part of the world with a
	# hazy second skyline, taller and sparser for sense of depth
	var far_count := 55
	var far_radius := 400.0
	for i in range(far_count):
		var angle2: float = (float(i) / far_count) * TAU + rng.randf_range(-0.05, 0.05)
		var r2: float = far_radius + rng.randf_range(-40.0, 60.0)
		var x2: float = cos(angle2) * r2
		var z2: float = sin(angle2) * r2
		var h2: float = rng.randf_range(25.0, 80.0)
		var w2: float = rng.randf_range(7.0, 16.0)
		var color2: Color = palette[rng.randi_range(0, palette.size() - 1)]
		_box(Vector3(w2, h2, w2), Vector3(x2, h2 / 2.0, z2), color2, false)


func _setup_beach_details() -> void:
	# sandy patch distinct from the grass, covering the walk-up area
	var sand := MeshInstance3D.new()
	var sand_mesh := PlaneMesh.new()
	sand_mesh.size = Vector2(70, 60)
	sand.mesh = sand_mesh
	var sand_mat := StandardMaterial3D.new()
	sand_mat.albedo_color = Color(0.93, 0.85, 0.65)
	sand.material_override = sand_mat
	sand.position = Vector3(0, 0.03, -85)
	add_child(sand)

	_make_umbrella(Vector3(10, 0, -80), Color(0.3, 0.6, 0.9))
	_make_umbrella(Vector3(-20, 0, -75), Color(1.0, 0.85, 0.2))
	_make_palm(Vector3(20, 0, -70))
	_make_palm(Vector3(-25, 0, -95))
	_make_palm(Vector3(4, 0, -65))

	# collectible glowing shells scattered on the sand
	var shell_positions := [
		Vector3(2, 0.3, -75), Vector3(-12, 0.3, -68), Vector3(14, 0.3, -95),
		Vector3(-4, 0.3, -105), Vector3(22, 0.3, -85),
	]
	var shell_colors := [
		Color(1.0, 0.8, 0.9), Color(0.8, 0.9, 1.0), Color(1.0, 0.95, 0.7),
		Color(0.85, 1.0, 0.85), Color(0.95, 0.8, 1.0),
	]
	for i in range(shell_positions.size()):
		_make_shell(shell_positions[i], shell_colors[i])


func _make_shell(pos: Vector3, color: Color) -> void:
	var shell := MeshInstance3D.new()
	var shell_mesh := SphereMesh.new()
	shell_mesh.radius = 0.35
	shell_mesh.height = 0.5
	shell.mesh = shell_mesh
	var shell_mat := StandardMaterial3D.new()
	shell_mat.albedo_color = color
	shell_mat.emission_enabled = true
	shell_mat.emission = color
	shell_mat.emission_energy_multiplier = 1.5
	shell.material_override = shell_mat
	shell.position = pos
	add_child(shell)

	var trigger := Area3D.new()
	var trigger_col := CollisionShape3D.new()
	var trigger_shape := SphereShape3D.new()
	trigger_shape.radius = 1.0
	trigger_col.shape = trigger_shape
	trigger.add_child(trigger_col)
	trigger.position = pos
	trigger.body_entered.connect(_on_shell_entered.bind(shell, trigger))
	add_child(trigger)


func _on_shell_entered(body: Node3D, shell: MeshInstance3D, trigger: Area3D) -> void:
	if body != player or not is_instance_valid(shell):
		return
	shell.queue_free()
	trigger.queue_free()
	shells_collected += 1
	if shells_collected >= TOTAL_SHELLS:
		_show_puzzle_message("Все ракушки найдены!", Color(1, 0.9, 0.6))
	else:
		_show_puzzle_message("Ракушка собрана (%d/%d)" % [shells_collected, TOTAL_SHELLS], Color(0.8, 0.95, 1.0))


func _setup_circus_puzzle() -> void:
	# entrance arch on the side facing the hub
	var arch_pos := CIRCUS_CENTER + Vector3(-13, 0, 0)
	_box(Vector3(0.6, 5, 0.6), arch_pos + Vector3(0, 2.5, -3), Color(0.85, 0.15, 0.25), false)
	_box(Vector3(0.6, 5, 0.6), arch_pos + Vector3(0, 2.5, 3), Color(0.85, 0.15, 0.25), false)
	_make_label("ПОРЯДОК:\nКРАСНЫЙ - ЖЁЛТЫЙ - СИНИЙ - ЗЕЛЁНЫЙ", arch_pos + Vector3(0, 6, 0), Color(1, 1, 0.9))

	var colors := {
		"КРАСНЫЙ": Color(0.9, 0.15, 0.15),
		"ЖЁЛТЫЙ": Color(0.95, 0.85, 0.15),
		"СИНИЙ": Color(0.2, 0.4, 0.95),
		"ЗЕЛЁНЫЙ": Color(0.2, 0.75, 0.3),
	}
	var offsets := [Vector3(-6, 0, -4.5), Vector3(-2, 0, -4.5), Vector3(2, 0, -4.5), Vector3(6, 0, -4.5)]
	var names := ["КРАСНЫЙ", "ЖЁЛТЫЙ", "СИНИЙ", "ЗЕЛЁНЫЙ"]

	for i in range(names.size()):
		var pname: String = names[i]
		var pos: Vector3 = CIRCUS_CENTER + offsets[i]

		var pedestal := MeshInstance3D.new()
		var ped_mesh := CylinderMesh.new()
		ped_mesh.top_radius = 1.1
		ped_mesh.bottom_radius = 1.1
		ped_mesh.height = 1.0
		pedestal.mesh = ped_mesh
		var ped_mat := StandardMaterial3D.new()
		ped_mat.albedo_color = colors[pname]
		ped_mat.emission_enabled = true
		ped_mat.emission = colors[pname]
		ped_mat.emission_energy_multiplier = 0.5
		pedestal.material_override = ped_mat
		pedestal.position = pos + Vector3(0, 0.5, 0)
		add_child(pedestal)

		var trigger := Area3D.new()
		var trigger_col := CollisionShape3D.new()
		var trigger_shape := CylinderShape3D.new()
		trigger_shape.radius = 1.1
		trigger_shape.height = 2.0
		trigger_col.shape = trigger_shape
		trigger.add_child(trigger_col)
		trigger.position = pos + Vector3(0, 1.2, 0)
		trigger.body_entered.connect(_on_circus_pedestal_entered.bind(pname))
		add_child(trigger)

	# central altar that will glow once solved
	var altar := MeshInstance3D.new()
	var altar_mesh := CylinderMesh.new()
	altar_mesh.top_radius = 1.6
	altar_mesh.bottom_radius = 1.8
	altar_mesh.height = 1.2
	altar.mesh = altar_mesh
	var altar_mat := StandardMaterial3D.new()
	altar_mat.albedo_color = Color(0.3, 0.28, 0.3)
	altar.material_override = altar_mat
	altar.position = CIRCUS_CENTER + Vector3(0, 0.6, 3)
	altar.name = "CircusAltar"
	add_child(altar)


func _on_circus_pedestal_entered(body: Node3D, color_name: String) -> void:
	if body != player or circus_solved:
		return

	if circus_sequence[circus_progress] == color_name:
		circus_progress += 1
		if circus_progress >= circus_sequence.size():
			_circus_solved()
		else:
			_show_puzzle_message("Верно! (%d/%d)" % [circus_progress, circus_sequence.size()], Color(0.5, 1, 0.6))
	else:
		circus_progress = 0
		_show_puzzle_message("Неверно, начни сначала", Color(1, 0.4, 0.4))


func _circus_solved() -> void:
	circus_solved = true
	_show_puzzle_message("Загадка цирка пройдена!", Color(1, 0.9, 0.5))

	var altar := get_node_or_null("CircusAltar") as MeshInstance3D
	var glow_pos: Vector3 = CIRCUS_CENTER + Vector3(0, 1.6, 3)
	if altar != null:
		var altar_mat := altar.material_override as StandardMaterial3D
		altar_mat.emission_enabled = true
		altar_mat.emission = Color(1, 0.85, 0.4)
		altar_mat.emission_energy_multiplier = 2.0

	var prize := MeshInstance3D.new()
	var prize_mesh := SphereMesh.new()
	prize_mesh.radius = 0.5
	prize_mesh.height = 1.0
	prize.mesh = prize_mesh
	var prize_mat := StandardMaterial3D.new()
	prize_mat.albedo_color = Color(1, 0.9, 0.5)
	prize_mat.emission_enabled = true
	prize_mat.emission = Color(1, 0.85, 0.3)
	prize_mat.emission_energy_multiplier = 3.0
	prize.material_override = prize_mat
	prize.position = glow_pos
	add_child(prize)


func _show_puzzle_message(text: String, color: Color) -> void:
	puzzle_message_label.text = text
	puzzle_message_label.modulate = Color(color.r, color.g, color.b, 1.0)
	var tween := create_tween()
	tween.tween_interval(1.6)
	tween.tween_property(puzzle_message_label, "modulate:a", 0.0, 0.6)


func _setup_parkour_course() -> void:
	# A jump-the-rooftops climb near the Red City, culminating in a prize
	# at the top. Each step is a small height gain (~1.1) so it's jumpable.
	var base := Vector3(-60, 0, 105)
	var steps := 8
	var color := Color(0.6, 0.15, 0.18)

	_make_label("ПАРКУР", base + Vector3(-2, 3, 3), Color(1, 0.8, 0.6))

	for i in range(steps):
		var height: float = 1.0 + i * 1.15
		var lateral: float = sin(i * 1.3) * 2.0
		var pos: Vector3 = base + Vector3(i * 3.0, height, lateral)
		_box(Vector3(2.6, 0.5, 2.6), pos, color)

	var top_height: float = 1.0 + (steps - 1) * 1.15 + 0.8
	var top_pos: Vector3 = base + Vector3((steps - 1) * 3.0, top_height, sin((steps - 1) * 1.3) * 2.0)

	var prize := MeshInstance3D.new()
	var prize_mesh := SphereMesh.new()
	prize_mesh.radius = 0.5
	prize_mesh.height = 1.0
	prize.mesh = prize_mesh
	var prize_mat := StandardMaterial3D.new()
	prize_mat.albedo_color = Color(0.6, 0.9, 1.0)
	prize_mat.emission_enabled = true
	prize_mat.emission = Color(0.5, 0.85, 1.0)
	prize_mat.emission_energy_multiplier = 3.0
	prize.material_override = prize_mat
	prize.position = top_pos
	add_child(prize)
	_make_label("ВЕРШИНА", top_pos + Vector3(0, 1.5, 0), Color(0.7, 0.9, 1.0))


const MAZE_SIZE := 6
const MAZE_CELL := 8.0
var maze_origin := Vector3(70, 0, -70)
var maze_wall_right: Array = []
var maze_wall_down: Array = []
var neighbor: Node3D
var neighbor_active := false
const NEIGHBOR_SPEED := 4.0
const NEIGHBOR_CATCH_DISTANCE := 1.7


const INTERIOR_ORIGIN := Vector3(-140, 0, 260)
const TOWER_DOOR_POS := Vector3(-133, 0, 0)


func _setup_corporate_interior() -> void:
	# --- entrance door on the tower's east face (facing the hub) ---
	_box(Vector3(0.3, 4.5, 2.2), TOWER_DOOR_POS + Vector3(0, 2.25, -1.2), Color(0.15, 0.2, 0.3), false)
	_box(Vector3(0.3, 4.5, 2.2), TOWER_DOOR_POS + Vector3(0, 2.25, 1.2), Color(0.15, 0.2, 0.3), false)

	var slab := MeshInstance3D.new()
	var slab_mesh := BoxMesh.new()
	slab_mesh.size = Vector3(0.15, 4.0, 2.0)
	slab.mesh = slab_mesh
	var slab_mat := StandardMaterial3D.new()
	slab_mat.albedo_color = Color(0.2, 0.5, 0.6, 0.5)
	slab_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	slab_mat.emission_enabled = true
	slab_mat.emission = Color(0.3, 0.7, 0.8)
	slab_mat.emission_energy_multiplier = 0.6
	slab.material_override = slab_mat
	slab.position = TOWER_DOOR_POS + Vector3(0, 2.1, 0)
	add_child(slab)
	_make_label("ВХОД", TOWER_DOOR_POS + Vector3(0, 4.8, 0), Color(0.8, 0.95, 1))

	var enter_trigger := Area3D.new()
	var enter_col := CollisionShape3D.new()
	var enter_shape := SphereShape3D.new()
	enter_shape.radius = 2.0
	enter_col.shape = enter_shape
	enter_trigger.add_child(enter_col)
	enter_trigger.position = TOWER_DOOR_POS
	enter_trigger.body_entered.connect(_on_tower_enter)
	add_child(enter_trigger)

	# --- interior office room (its own floor, far away in world space) ---
	var room_w := 34.0
	var room_d := 46.0
	var room_h := 5.0

	var floor_mi := MeshInstance3D.new()
	var floor_mesh := PlaneMesh.new()
	floor_mesh.size = Vector2(room_w, room_d)
	floor_mi.mesh = floor_mesh
	var floor_mat := StandardMaterial3D.new()
	floor_mat.albedo_color = Color(0.55, 0.55, 0.58)
	floor_mi.material_override = floor_mat
	floor_mi.position = INTERIOR_ORIGIN
	add_child(floor_mi)

	var floor_body := StaticBody3D.new()
	var floor_col := CollisionShape3D.new()
	var floor_shape := BoxShape3D.new()
	floor_shape.size = Vector3(room_w, 0.2, room_d)
	floor_col.shape = floor_shape
	floor_body.position = INTERIOR_ORIGIN
	floor_body.add_child(floor_col)
	add_child(floor_body)

	var ceil_mi := MeshInstance3D.new()
	var ceil_mesh := PlaneMesh.new()
	ceil_mesh.size = Vector2(room_w, room_d)
	ceil_mi.mesh = ceil_mesh
	var ceil_mat := StandardMaterial3D.new()
	ceil_mat.albedo_color = Color(0.85, 0.85, 0.82)
	ceil_mi.material_override = ceil_mat
	ceil_mi.position = INTERIOR_ORIGIN + Vector3(0, room_h, 0)
	ceil_mi.rotate_x(PI)
	add_child(ceil_mi)

	# fluorescent light strips on the ceiling
	for row in range(5):
		var strip_mat := StandardMaterial3D.new()
		strip_mat.albedo_color = Color(1, 1, 0.97)
		strip_mat.emission_enabled = true
		strip_mat.emission = Color(1, 1, 0.95)
		strip_mat.emission_energy_multiplier = 1.6
		var strip := MeshInstance3D.new()
		var strip_mesh := BoxMesh.new()
		strip_mesh.size = Vector3(room_w - 4.0, 0.1, 0.5)
		strip.mesh = strip_mesh
		strip.material_override = strip_mat
		strip.position = INTERIOR_ORIGIN + Vector3(0, room_h - 0.1, -room_d / 2.0 + 4.0 + row * (room_d - 8.0) / 4.0)
		add_child(strip)

	# perimeter walls (solid)
	var wall_color := Color(0.72, 0.72, 0.75)
	_box(Vector3(room_w, room_h, 0.4), INTERIOR_ORIGIN + Vector3(0, room_h / 2.0, -room_d / 2.0), wall_color)
	_box(Vector3(0.4, room_h, room_d), INTERIOR_ORIGIN + Vector3(-room_w / 2.0, room_h / 2.0, 0), wall_color)
	_box(Vector3(0.4, room_h, room_d), INTERIOR_ORIGIN + Vector3(room_w / 2.0, room_h / 2.0, 0), wall_color)
	# front wall has a gap in the middle for the entrance/exit doorway
	_box(Vector3((room_w - 4.0) / 2.0, room_h, 0.4), INTERIOR_ORIGIN + Vector3(-(room_w + 4.0) / 4.0, room_h / 2.0, room_d / 2.0), wall_color)
	_box(Vector3((room_w - 4.0) / 2.0, room_h, 0.4), INTERIOR_ORIGIN + Vector3((room_w + 4.0) / 4.0, room_h / 2.0, room_d / 2.0), wall_color)

	_make_label("КОРПОРАЦИЯ // ВНУТРИ", INTERIOR_ORIGIN + Vector3(0, room_h - 1.0, -room_d / 2.0 + 2.0), Color(0.6, 0.8, 0.9))

	# rows of empty cubicle desks with glowing monitors — no people anywhere
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var glitch_row := rng.randi_range(0, 3)
	var glitch_col := rng.randi_range(0, 4)

	for row in range(4):
		for col in range(5):
			var desk_pos: Vector3 = INTERIOR_ORIGIN + Vector3(-12.0 + col * 6.0, 0, -14.0 + row * 9.0)
			_make_cubicle(desk_pos, row == glitch_row and col == glitch_col)

	# exit door near the entrance gap, teleports back outside the tower
	var exit_pos: Vector3 = INTERIOR_ORIGIN + Vector3(0, 0, room_d / 2.0 - 1.0)
	var exit_trigger := Area3D.new()
	var exit_col := CollisionShape3D.new()
	var exit_shape := SphereShape3D.new()
	exit_shape.radius = 2.0
	exit_col.shape = exit_shape
	exit_trigger.add_child(exit_col)
	exit_trigger.position = exit_pos
	exit_trigger.body_entered.connect(_on_tower_exit)
	add_child(exit_trigger)


func _make_cubicle(pos: Vector3, glitchy: bool) -> void:
	var desk := MeshInstance3D.new()
	var desk_mesh := BoxMesh.new()
	desk_mesh.size = Vector3(2.4, 0.9, 1.1)
	desk.mesh = desk_mesh
	var desk_mat := StandardMaterial3D.new()
	desk_mat.albedo_color = Color(0.5, 0.42, 0.35)
	desk.material_override = desk_mat
	desk.position = pos + Vector3(0, 0.45, 0)
	add_child(desk)

	var monitor := MeshInstance3D.new()
	var monitor_mesh := BoxMesh.new()
	monitor_mesh.size = Vector3(1.0, 0.7, 0.08)
	monitor.mesh = monitor_mesh
	var monitor_mat := StandardMaterial3D.new()
	monitor_mat.albedo_color = Color(0.05, 0.05, 0.07)
	monitor_mat.emission_enabled = true
	monitor_mat.emission = Color(0.3, 0.7, 0.9) if not glitchy else Color(0.9, 0.2, 0.3)
	monitor_mat.emission_energy_multiplier = 1.2
	monitor.material_override = monitor_mat
	monitor.position = pos + Vector3(0, 1.15, -0.4)
	add_child(monitor)

	var chair := MeshInstance3D.new()
	var chair_mesh := BoxMesh.new()
	chair_mesh.size = Vector3(0.7, 0.9, 0.7)
	chair.mesh = chair_mesh
	var chair_mat := StandardMaterial3D.new()
	chair_mat.albedo_color = Color(0.15, 0.15, 0.18)
	chair.material_override = chair_mat
	chair.position = pos + Vector3(0, 0.45, 1.0)
	add_child(chair)

	if glitchy:
		_make_label("ты нашёл нас", pos + Vector3(0, 1.7, -0.4), Color(1, 0.3, 0.3))


func _on_tower_enter(body: Node3D) -> void:
	if body == player and not player_caught:
		player.global_position = INTERIOR_ORIGIN + Vector3(0, 2, -20)
		player.rotation = Vector3.ZERO
		player.rotate_y(PI)
		player.velocity = Vector3.ZERO


func _on_tower_exit(body: Node3D) -> void:
	if body == player and not player_caught:
		player.global_position = TOWER_DOOR_POS + Vector3(6, 2, 0)
		player.velocity = Vector3.ZERO


func _setup_labyrinth() -> void:
	# floor for the maze area, tinted differently ("strange world")
	var floor_mi := MeshInstance3D.new()
	var floor_size := MAZE_SIZE * MAZE_CELL + 6.0
	var floor_mesh := PlaneMesh.new()
	floor_mesh.size = Vector2(floor_size, floor_size)
	floor_mi.mesh = floor_mesh
	var floor_mat := StandardMaterial3D.new()
	floor_mat.albedo_color = Color(0.35, 0.28, 0.42)
	floor_mi.material_override = floor_mat
	floor_mi.position = maze_origin + Vector3(floor_size / 2.0 - MAZE_CELL / 2.0, 0.02, floor_size / 2.0 - MAZE_CELL / 2.0)
	add_child(floor_mi)

	_make_label("СТРАННЫЙ МИР", maze_origin + Vector3(0, 12, -6), Color(0.85, 0.7, 1.0))

	# --- generate a real solvable maze (recursive backtracker) ---
	var visited := []
	for x in range(MAZE_SIZE):
		var row := []
		for z in range(MAZE_SIZE):
			row.append(false)
		visited.append(row)

	# walls[x][z] = {right: bool, down: bool}  (true = wall present)
	maze_wall_right = []
	maze_wall_down = []
	for x in range(MAZE_SIZE):
		var rr := []
		var rd := []
		for z in range(MAZE_SIZE):
			rr.append(true)
			rd.append(true)
		maze_wall_right.append(rr)
		maze_wall_down.append(rd)

	var stack := [Vector2i(0, 0)]
	visited[0][0] = true
	var rng := RandomNumberGenerator.new()
	rng.randomize()

	while stack.size() > 0:
		var current: Vector2i = stack[stack.size() - 1]
		var neighbors := []
		if current.x > 0 and not visited[current.x - 1][current.y]:
			neighbors.append(Vector2i(current.x - 1, current.y))
		if current.x < MAZE_SIZE - 1 and not visited[current.x + 1][current.y]:
			neighbors.append(Vector2i(current.x + 1, current.y))
		if current.y > 0 and not visited[current.x][current.y - 1]:
			neighbors.append(Vector2i(current.x, current.y - 1))
		if current.y < MAZE_SIZE - 1 and not visited[current.x][current.y + 1]:
			neighbors.append(Vector2i(current.x, current.y + 1))

		if neighbors.size() == 0:
			stack.pop_back()
			continue

		var next: Vector2i = neighbors[rng.randi_range(0, neighbors.size() - 1)]
		if next.x == current.x + 1:
			maze_wall_right[current.x][current.y] = false
		elif next.x == current.x - 1:
			maze_wall_right[next.x][next.y] = false
		elif next.y == current.y + 1:
			maze_wall_down[current.x][current.y] = false
		elif next.y == current.y - 1:
			maze_wall_down[next.x][next.y] = false

		visited[next.x][next.y] = true
		stack.append(next)

	# --- build wall meshes from the carved maze ---
	var wall_h := 4.0
	var wall_color := Color(0.45, 0.3, 0.55)
	for x in range(MAZE_SIZE):
		for z in range(MAZE_SIZE):
			var cell_pos := maze_origin + Vector3(x * MAZE_CELL, 0, z * MAZE_CELL)
			if maze_wall_right[x][z] and x < MAZE_SIZE - 1:
				_box(Vector3(0.6, wall_h, MAZE_CELL), cell_pos + Vector3(MAZE_CELL / 2.0, wall_h / 2.0, 0), wall_color)
			if maze_wall_down[x][z] and z < MAZE_SIZE - 1:
				_box(Vector3(MAZE_CELL, wall_h, 0.6), cell_pos + Vector3(0, wall_h / 2.0, MAZE_CELL / 2.0), wall_color)

	# outer border walls
	_box(Vector3(0.6, wall_h, MAZE_SIZE * MAZE_CELL), maze_origin + Vector3(-MAZE_CELL / 2.0, wall_h / 2.0, (MAZE_SIZE - 1) * MAZE_CELL / 2.0), wall_color)
	_box(Vector3(0.6, wall_h, MAZE_SIZE * MAZE_CELL), maze_origin + Vector3((MAZE_SIZE - 1) * MAZE_CELL + MAZE_CELL / 2.0, wall_h / 2.0, (MAZE_SIZE - 1) * MAZE_CELL / 2.0), wall_color)
	_box(Vector3(MAZE_SIZE * MAZE_CELL, wall_h, 0.6), maze_origin + Vector3((MAZE_SIZE - 1) * MAZE_CELL / 2.0, wall_h / 2.0, -MAZE_CELL / 2.0), wall_color)
	_box(Vector3(MAZE_SIZE * MAZE_CELL, wall_h, 0.6), maze_origin + Vector3((MAZE_SIZE - 1) * MAZE_CELL / 2.0, wall_h / 2.0, (MAZE_SIZE - 1) * MAZE_CELL + MAZE_CELL / 2.0), wall_color)

	# glowing marker at the maze exit/goal (far corner)
	var goal := MeshInstance3D.new()
	var goal_mesh := SphereMesh.new()
	goal_mesh.radius = 1.2
	goal_mesh.height = 2.4
	goal.mesh = goal_mesh
	var goal_mat := StandardMaterial3D.new()
	goal_mat.albedo_color = Color(1, 0.9, 1)
	goal_mat.emission_enabled = true
	goal_mat.emission = Color(1, 0.7, 1)
	goal_mat.emission_energy_multiplier = 3.0
	goal.material_override = goal_mat
	goal.position = maze_origin + Vector3((MAZE_SIZE - 1) * MAZE_CELL, 1.5, (MAZE_SIZE - 1) * MAZE_CELL)
	add_child(goal)

	_make_label("ВЫХОД", goal.position + Vector3(0, 2.2, 0), Color(1, 0.9, 1))

	var exit_trigger := Area3D.new()
	var exit_col := CollisionShape3D.new()
	var exit_shape := SphereShape3D.new()
	exit_shape.radius = 1.6
	exit_col.shape = exit_shape
	exit_trigger.add_child(exit_col)
	exit_trigger.position = goal.position
	exit_trigger.body_entered.connect(_on_maze_exit)
	add_child(exit_trigger)

	_setup_neighbor()


func _on_maze_exit(body: Node3D) -> void:
	if body == player and not player_caught:
		neighbor_active = false
		neighbor.visible = false
		player.global_position = Vector3(0, 2, 3)
		player.rotation = Vector3.ZERO
		player.rotate_y(deg_to_rad(180))
		player.velocity = Vector3.ZERO


func _setup_neighbor() -> void:
	# An original "creepy suburban neighbor with a shovel" character —
	# inspired by that archetype, not a copy of any specific game's assets.
	neighbor = Node3D.new()
	neighbor.visible = false

	var legs := MeshInstance3D.new()
	var legs_mesh := BoxMesh.new()
	legs_mesh.size = Vector3(0.7, 1.0, 0.4)
	legs.mesh = legs_mesh
	var legs_mat := StandardMaterial3D.new()
	legs_mat.albedo_color = Color(0.55, 0.12, 0.12)
	legs.material_override = legs_mat
	legs.position = Vector3(0, 0.5, 0)
	neighbor.add_child(legs)

	var torso := MeshInstance3D.new()
	var torso_mesh := BoxMesh.new()
	torso_mesh.size = Vector3(0.9, 1.1, 0.5)
	torso.mesh = torso_mesh
	var torso_mat := StandardMaterial3D.new()
	torso_mat.albedo_color = Color(0.15, 0.2, 0.4)
	torso.material_override = torso_mat
	torso.position = Vector3(0, 1.55, 0)
	neighbor.add_child(torso)

	for side in [-1, 1]:
		var arm := MeshInstance3D.new()
		var arm_mesh := BoxMesh.new()
		arm_mesh.size = Vector3(0.28, 1.0, 0.28)
		arm.mesh = arm_mesh
		var arm_mat := StandardMaterial3D.new()
		arm_mat.albedo_color = Color(0.85, 0.65, 0.2)
		arm.material_override = arm_mat
		arm.position = Vector3(side * 0.58, 1.45, 0)
		neighbor.add_child(arm)

	var head := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.32
	head_mesh.height = 0.64
	head.mesh = head_mesh
	var head_mat := StandardMaterial3D.new()
	head_mat.albedo_color = Color(0.92, 0.78, 0.65)
	head.material_override = head_mat
	head.position = Vector3(0, 2.35, 0)
	neighbor.add_child(head)

	var mustache := MeshInstance3D.new()
	var mustache_mesh := BoxMesh.new()
	mustache_mesh.size = Vector3(0.36, 0.08, 0.1)
	mustache.mesh = mustache_mesh
	var mustache_mat := StandardMaterial3D.new()
	mustache_mat.albedo_color = Color(0.1, 0.08, 0.06)
	mustache.material_override = mustache_mat
	mustache.position = Vector3(0, 2.22, -0.28)
	neighbor.add_child(mustache)

	# shovel, held to the side
	var handle := MeshInstance3D.new()
	var handle_mesh := CylinderMesh.new()
	handle_mesh.top_radius = 0.05
	handle_mesh.bottom_radius = 0.05
	handle_mesh.height = 1.4
	handle.mesh = handle_mesh
	var handle_mat := StandardMaterial3D.new()
	handle_mat.albedo_color = Color(0.4, 0.25, 0.15)
	handle.material_override = handle_mat
	handle.rotation_degrees = Vector3(0, 0, 25)
	handle.position = Vector3(0.75, 1.3, 0.1)
	neighbor.add_child(handle)

	var blade := MeshInstance3D.new()
	var blade_mesh := BoxMesh.new()
	blade_mesh.size = Vector3(0.35, 0.45, 0.06)
	blade.mesh = blade_mesh
	var blade_mat := StandardMaterial3D.new()
	blade_mat.albedo_color = Color(0.55, 0.55, 0.58)
	blade.material_override = blade_mat
	blade.position = Vector3(1.1, 0.7, 0.1)
	blade.rotation_degrees = Vector3(0, 0, 25)
	neighbor.add_child(blade)

	add_child(neighbor)


func _maze_world_to_cell(pos: Vector3) -> Vector2i:
	var local := pos - maze_origin
	var cx := int(round(local.x / MAZE_CELL))
	var cz := int(round(local.z / MAZE_CELL))
	cx = clamp(cx, 0, MAZE_SIZE - 1)
	cz = clamp(cz, 0, MAZE_SIZE - 1)
	return Vector2i(cx, cz)


func _maze_cell_to_world(cell: Vector2i) -> Vector3:
	return maze_origin + Vector3(cell.x * MAZE_CELL, 0, cell.y * MAZE_CELL)


func _maze_neighbors_of(cell: Vector2i) -> Array:
	var result := []
	if cell.x > 0 and not maze_wall_right[cell.x - 1][cell.y]:
		result.append(Vector2i(cell.x - 1, cell.y))
	if cell.x < MAZE_SIZE - 1 and not maze_wall_right[cell.x][cell.y]:
		result.append(Vector2i(cell.x + 1, cell.y))
	if cell.y > 0 and not maze_wall_down[cell.x][cell.y - 1]:
		result.append(Vector2i(cell.x, cell.y - 1))
	if cell.y < MAZE_SIZE - 1 and not maze_wall_down[cell.x][cell.y]:
		result.append(Vector2i(cell.x, cell.y + 1))
	return result


func _maze_bfs_next_step(start: Vector2i, goal: Vector2i) -> Vector2i:
	# Returns the first cell to move to from `start` on the shortest path
	# to `goal` through the generated maze corridors. Grid is tiny (≤36
	# cells) so a fresh BFS every call is cheap.
	if start == goal:
		return start

	var came_from := {}
	var queue := [start]
	var visited := {start: true}
	var head := 0

	while head < queue.size():
		var current: Vector2i = queue[head]
		head += 1
		if current == goal:
			break
		for n in _maze_neighbors_of(current):
			if not visited.has(n):
				visited[n] = true
				came_from[n] = current
				queue.append(n)

	if not came_from.has(goal):
		return start

	var step: Vector2i = goal
	while came_from.has(step) and came_from[step] != start:
		step = came_from[step]
	return step


func _update_neighbor_chase(delta: float) -> void:
	var margin := 4.0
	var min_pos: Vector3 = maze_origin + Vector3(-margin, 0, -margin)
	var max_pos: Vector3 = maze_origin + Vector3((MAZE_SIZE - 1) * MAZE_CELL + margin, 0, (MAZE_SIZE - 1) * MAZE_CELL + margin)
	var p := player.global_position
	var inside_maze: bool = p.x > min_pos.x and p.x < max_pos.x and p.z > min_pos.z and p.z < max_pos.z

	if inside_maze and not neighbor_active:
		neighbor_active = true
		neighbor.visible = true
		neighbor.global_position = _maze_cell_to_world(Vector2i(MAZE_SIZE - 1, MAZE_SIZE - 1)) + Vector3(0, 0, 0)
	elif not inside_maze and neighbor_active:
		neighbor_active = false
		neighbor.visible = false
		return

	if not neighbor_active or player_caught:
		return

	var player_cell := _maze_world_to_cell(player.global_position)
	var neighbor_cell := _maze_world_to_cell(neighbor.global_position)
	var next_cell := _maze_bfs_next_step(neighbor_cell, player_cell)
	var target := _maze_cell_to_world(next_cell) + Vector3(0, 0, 0)

	var dir := target - neighbor.global_position
	dir.y = 0
	if dir.length() > 0.15:
		dir = dir.normalized()
		neighbor.global_position += dir * NEIGHBOR_SPEED * delta
		neighbor.look_at(neighbor.global_position + dir, Vector3.UP)

	if neighbor.global_position.distance_to(player.global_position) < NEIGHBOR_CATCH_DISTANCE:
		_on_player_caught("СОСЕД ТЕБЯ ПОЙМАЛ...\nпопробуй снова")


func _setup_monster() -> void:
	monster = Node3D.new()
	monster.set_script(load("res://scripts/MonsterAI.gd"))
	monster.visible = false

	var body := MeshInstance3D.new()
	var body_mesh := CapsuleMesh.new()
	body_mesh.radius = 0.35
	body_mesh.height = 2.2
	body.mesh = body_mesh
	var body_mat := StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.02, 0.02, 0.03)
	body.material_override = body_mat
	body.position = Vector3(0, 1.1, 0)
	monster.add_child(body)

	for side in [-1, 1]:
		var eye := MeshInstance3D.new()
		var eye_mesh := SphereMesh.new()
		eye_mesh.radius = 0.05
		eye_mesh.height = 0.1
		eye.mesh = eye_mesh
		var eye_mat := StandardMaterial3D.new()
		eye_mat.albedo_color = Color(1, 0.1, 0.1)
		eye_mat.emission_enabled = true
		eye_mat.emission = Color(1, 0.1, 0.1)
		eye_mat.emission_energy_multiplier = 4.0
		eye.material_override = eye_mat
		eye.position = Vector3(side * 0.12, 1.9, -0.32)
		monster.add_child(eye)

	add_child(monster)


func _setup_showman() -> void:
	showman = Node3D.new()
	showman.position = Vector3(0, 0, -5)
	add_child(showman)

	var body := MeshInstance3D.new()
	var body_mesh := CapsuleMesh.new()
	body_mesh.radius = 0.5
	body_mesh.height = 1.8
	body.mesh = body_mesh
	var body_mat := StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.1, 0.1, 0.15)
	body.material_override = body_mat
	body.position = Vector3(0, 0.9, 0)
	showman.add_child(body)

	var hat := MeshInstance3D.new()
	var hat_mesh := CylinderMesh.new()
	hat_mesh.top_radius = 0.35
	hat_mesh.bottom_radius = 0.35
	hat_mesh.height = 0.5
	hat.mesh = hat_mesh
	var hat_mat := StandardMaterial3D.new()
	hat_mat.albedo_color = Color(0.05, 0.05, 0.05)
	hat.material_override = hat_mat
	hat.position = Vector3(0, 2.0, 0)
	showman.add_child(hat)

	var showman_label := Label3D.new()
	showman_label.text = "ШОУМЕН"
	showman_label.position = Vector3(0, 2.6, 0)
	showman_label.font_size = 64
	showman_label.outline_size = 12
	showman_label.modulate = Color(1, 1, 0.7)
	showman_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	showman.add_child(showman_label)

	showman.set_script(load("res://scripts/ShowmanAI.gd"))


func _make_eye(pos: Vector3, iris_color: Color) -> void:
	var eye := Node3D.new()
	eye.position = pos
	eye.set_script(load("res://scripts/FloatingEye.gd"))

	var sclera := MeshInstance3D.new()
	var sclera_mesh := SphereMesh.new()
	sclera_mesh.radius = 1.1
	sclera_mesh.height = 2.2
	sclera.mesh = sclera_mesh
	var sclera_mat := StandardMaterial3D.new()
	sclera_mat.albedo_color = Color(0.98, 0.97, 0.95)
	sclera.material_override = sclera_mat
	eye.add_child(sclera)

	var iris := MeshInstance3D.new()
	var iris_mesh := CylinderMesh.new()
	iris_mesh.top_radius = 0.55
	iris_mesh.bottom_radius = 0.55
	iris_mesh.height = 0.15
	iris.mesh = iris_mesh
	var iris_mat := StandardMaterial3D.new()
	iris_mat.albedo_color = iris_color
	iris.material_override = iris_mat
	iris.rotation_degrees = Vector3(90, 0, 0)
	iris.position = Vector3(0, 0, 1.05)
	eye.add_child(iris)

	var pupil := MeshInstance3D.new()
	var pupil_mesh := SphereMesh.new()
	pupil_mesh.radius = 0.22
	pupil_mesh.height = 0.44
	pupil.mesh = pupil_mesh
	var pupil_mat := StandardMaterial3D.new()
	pupil_mat.albedo_color = Color(0.02, 0.02, 0.02)
	pupil.material_override = pupil_mat
	pupil.position = Vector3(0, 0, 1.12)
	eye.add_child(pupil)

	add_child(eye)


func _setup_sky_eyes() -> void:
	_make_eye(Vector3(-20, 22, -30), Color(0.4, 0.65, 0.85))
	_make_eye(Vector3(18, 26, -25), Color(0.45, 0.28, 0.15))
	_make_eye(Vector3(35, 20, 10), Color(0.3, 0.5, 0.35))
	_make_eye(Vector3(-30, 24, 15), Color(0.5, 0.35, 0.6))
	_make_eye(Vector3(-10, 30, 35), Color(0.55, 0.4, 0.2))
	_make_eye(Vector3(25, 28, -55), Color(0.35, 0.55, 0.6))


func _setup_rainbow_arch() -> void:
	# A decorative rainbow gate standing over the north path, like the
	# reference photo. Purely visual, no collision — walk straight through.
	var arch_pos := Vector3(0, 0, -40)
	var colors := [
		Color(0.95, 0.15, 0.15), Color(1.0, 0.55, 0.1), Color(1.0, 0.85, 0.15),
		Color(0.2, 0.75, 0.3), Color(0.2, 0.55, 0.95), Color(0.35, 0.25, 0.75),
		Color(0.75, 0.3, 0.8),
	]
	var base_radius := 6.0
	for i in range(colors.size()):
		var ring := MeshInstance3D.new()
		var ring_mesh := TorusMesh.new()
		ring_mesh.inner_radius = base_radius + i * 0.65
		ring_mesh.outer_radius = base_radius + i * 0.65 + 0.6
		ring_mesh.rings = 6
		ring_mesh.ring_segments = 32
		ring.mesh = ring_mesh
		var mat := StandardMaterial3D.new()
		mat.albedo_color = colors[i]
		mat.emission_enabled = true
		mat.emission = colors[i]
		mat.emission_energy_multiplier = 0.3
		ring.material_override = mat
		ring.position = arch_pos
		ring.rotation_degrees = Vector3(90, 0, 0)
		add_child(ring)


func _setup_pink_door() -> void:
	# A surreal standalone door in a small clearing near the hub — stepping
	# close to it instantly opens a shortcut to the Strange World labyrinth.
	var door_pos := Vector3(18, 0, 18)

	var frame_color := Color(1.0, 0.55, 0.7)
	_box(Vector3(0.3, 4.2, 2.6), door_pos + Vector3(-1.15, 2.1, 0), frame_color, false)
	_box(Vector3(0.3, 4.2, 2.6), door_pos + Vector3(1.15, 2.1, 0), frame_color, false)
	_box(Vector3(2.6, 0.3, 2.6), door_pos + Vector3(0, 4.2, 0), frame_color, false)

	var slab := MeshInstance3D.new()
	var slab_mesh := BoxMesh.new()
	slab_mesh.size = Vector3(1.9, 3.8, 0.15)
	slab.mesh = slab_mesh
	var slab_mat := StandardMaterial3D.new()
	var door_tex: Texture2D = load("res://textures/door_sunflower.jpg")
	slab_mat.albedo_texture = door_tex
	slab_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	slab_mat.emission_enabled = true
	slab_mat.emission_texture = door_tex
	slab_mat.emission_energy_multiplier = 0.3
	slab.material_override = slab_mat
	slab.position = door_pos + Vector3(0, 1.95, 0)
	add_child(slab)

	_make_label("???", door_pos + Vector3(0, 5.0, 0), Color(1, 0.75, 0.85))

	var trigger := Area3D.new()
	var trigger_col := CollisionShape3D.new()
	var trigger_shape := SphereShape3D.new()
	trigger_shape.radius = 2.0
	trigger_col.shape = trigger_shape
	trigger.add_child(trigger_col)
	trigger.position = door_pos
	trigger.body_entered.connect(_on_door_entered)
	add_child(trigger)


func _on_door_entered(body: Node3D) -> void:
	if body == player and not player_caught:
		player.global_position = maze_origin + Vector3(-3, 2, (MAZE_SIZE - 1) * MAZE_CELL / 2.0)
		player.velocity = Vector3.ZERO


func _setup_photo_murals() -> void:
	# Real reference photos placed as signs/posters around the world.
	_make_mural("res://textures/weirdcore_sign.jpg", Vector3(7, 2.6, 7), Vector2(4, 4), 135)
	_make_mural("res://textures/retro_beach.jpg", Vector3(-30, 3.5, -82), Vector2(5, 5), 70)
	_make_mural("res://textures/mushroom_pond.jpg", maze_origin + Vector3(-6, 3, -4), Vector2(4.5, 4.5), 45)
	_make_mural("res://textures/rainbow_hill.jpg", Vector3(10, 4, -46), Vector2(5, 5), 0)
	_make_mural("res://textures/balloon_houses.jpg", Vector3(-32, 4.5, -52), Vector2(4, 5.3), -60)
	_make_mural("res://textures/rainbow_station.jpg", Vector3(-55, 5, 100), Vector2(4.5, 6), 90)
	_make_mural("res://textures/train_neon_meadow.jpg", INTERIOR_ORIGIN + Vector3(0, 3, -22.5), Vector2(6, 4), 180)


func _setup_clouds() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 99
	var cloud_mat := StandardMaterial3D.new()
	cloud_mat.albedo_color = Color(1, 1, 1, 0.75)
	cloud_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	cloud_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

	for i in range(18):
		var root := Node3D.new()
		var x: float = rng.randf_range(-300, 300)
		var z: float = rng.randf_range(-300, 300)
		var y: float = rng.randf_range(45, 85)
		root.position = Vector3(x, y, z)
		add_child(root)

		var puffs: int = rng.randi_range(3, 5)
		for p in range(puffs):
			var puff := MeshInstance3D.new()
			var mesh := SphereMesh.new()
			var r: float = rng.randf_range(5.0, 10.0)
			mesh.radius = r
			mesh.height = r * 2.0
			puff.mesh = mesh
			puff.material_override = cloud_mat
			puff.position = Vector3(rng.randf_range(-8, 8), rng.randf_range(-1.5, 1.5), rng.randf_range(-6, 6))
			root.add_child(puff)

		cloud_roots.append({"node": root, "speed": rng.randf_range(1.0, 3.0)})


func _update_clouds(delta: float) -> void:
	for entry in cloud_roots:
		var node: Node3D = entry["node"]
		node.position.x += entry["speed"] * delta
		if node.position.x > 320:
			node.position.x = -320


func _setup_rain() -> void:
	rain_particles = GPUParticles3D.new()
	rain_particles.amount = 400
	rain_particles.lifetime = 1.4
	rain_particles.emitting = false
	rain_particles.visibility_aabb = AABB(Vector3(-40, -20, -40), Vector3(80, 40, 80))

	var pm := ParticleProcessMaterial.new()
	pm.direction = Vector3(0, -1, 0)
	pm.spread = 3.0
	pm.initial_velocity_min = 22.0
	pm.initial_velocity_max = 26.0
	pm.gravity = Vector3(0, -2.0, 0)
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(35, 1, 35)
	rain_particles.process_material = pm

	var drop_mesh := BoxMesh.new()
	drop_mesh.size = Vector3(0.03, 0.5, 0.03)
	rain_particles.draw_pass_1 = drop_mesh

	var drop_mat := StandardMaterial3D.new()
	drop_mat.albedo_color = Color(0.8, 0.85, 0.95, 0.55)
	drop_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	drop_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	rain_particles.material_override = drop_mat

	rain_particles.position = Vector3(0, 18, 0)
	add_child(rain_particles)

	weather_timer = randf_range(20.0, 35.0)


func _update_weather(delta: float) -> void:
	if player == null:
		return
	rain_particles.global_position = Vector3(player.global_position.x, player.global_position.y + 18, player.global_position.z)

	weather_timer -= delta
	if weather_timer <= 0.0:
		is_raining = not is_raining
		rain_particles.emitting = is_raining
		if is_raining:
			weather_timer = randf_range(18.0, 32.0)
			sky_environment.fog_density = 0.012
			sun_light.light_energy = 0.6
		else:
			weather_timer = randf_range(25.0, 50.0)
			sky_environment.fog_density = 0.0035
			sun_light.light_energy = 1.3


func _make_npc(pos: Vector3, color: Color, wander_radius: float, glitchy: bool = false) -> void:
	var npc := CharacterBody3D.new()
	npc.position = pos

	var col := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.4
	shape.height = 1.6
	col.shape = shape
	col.position = Vector3(0, 0.8, 0)
	npc.add_child(col)

	var body := MeshInstance3D.new()
	var body_mesh := CapsuleMesh.new()
	body_mesh.radius = 0.4
	body_mesh.height = 1.6
	body.mesh = body_mesh
	var body_mat := StandardMaterial3D.new()
	body_mat.albedo_color = color
	body.material_override = body_mat
	body.position = Vector3(0, 0.8, 0)
	npc.add_child(body)

	var head := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.26
	head_mesh.height = 0.52
	head.mesh = head_mesh
	var head_mat := StandardMaterial3D.new()
	head_mat.albedo_color = Color(0.93, 0.8, 0.68)
	head.material_override = head_mat
	head.position = Vector3(0, 1.85, 0)
	npc.add_child(head)

	npc.set_script(load("res://scripts/NPCWander.gd"))
	npc.radius = wander_radius
	npc.glitchy = glitchy
	add_child(npc)


func _setup_npcs() -> void:
	_make_npc(Vector3(5, 0, -8), Color(0.5, 0.45, 0.8), 8.0)
	_make_npc(Vector3(-6, 0, 6), Color(0.8, 0.5, 0.45), 7.0)
	_make_npc(Vector3(-25, 0, -78), Color(0.9, 0.7, 0.3), 10.0)
	_make_npc(Vector3(12, 0, -90), Color(0.3, 0.7, 0.75), 9.0)
	_make_npc(Vector3(-10, 0, 115), Color(0.75, 0.3, 0.4), 12.0)
	_make_npc(Vector3(8, 0, 128), Color(0.4, 0.6, 0.35), 10.0)
	_make_npc(Vector3(-133, 0, 10), Color(0.55, 0.55, 0.6), 8.0)
	_make_npc(Vector3(3, 0, 2), Color(0.85, 0.85, 0.2), 6.0, true)  # the glitchy one


func _make_pine(pos: Vector3, scale_mul: float = 1.0, upside_down: bool = false) -> void:
	var tree := Node3D.new()
	tree.position = pos
	if upside_down:
		tree.rotation_degrees = Vector3(180, randf() * 360.0, 0)

	var trunk := MeshInstance3D.new()
	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.22 * scale_mul
	trunk_mesh.bottom_radius = 0.32 * scale_mul
	trunk_mesh.height = 2.2 * scale_mul
	trunk.mesh = trunk_mesh
	var trunk_mat := StandardMaterial3D.new()
	trunk_mat.albedo_color = Color(0.32, 0.22, 0.15)
	trunk.material_override = trunk_mat
	trunk.position = Vector3(0, 1.1 * scale_mul, 0)
	tree.add_child(trunk)

	var tiers := 3
	for i in range(tiers):
		var cone := MeshInstance3D.new()
		var cone_mesh := CylinderMesh.new()
		cone_mesh.top_radius = 0.05
		cone_mesh.bottom_radius = (2.2 - i * 0.55) * scale_mul
		cone_mesh.height = 2.0 * scale_mul
		cone.mesh = cone_mesh
		var cone_mat := StandardMaterial3D.new()
		cone_mat.albedo_color = Color(0.15 + i * 0.03, 0.4 - i * 0.03, 0.22)
		cone.material_override = cone_mat
		cone.position = Vector3(0, (2.2 + i * 1.4) * scale_mul, 0)
		tree.add_child(cone)

	add_child(tree)


func _setup_forest() -> void:
	# A dense little pine forest tucked in an otherwise empty corner of the
	# world, with one upside-down tree and a glowing "you are not alone"
	# easter egg buried deep inside.
	var rng := RandomNumberGenerator.new()
	rng.seed = 123
	var forest_center := Vector3(-100, 0, 100)

	for i in range(45):
		var x: float = forest_center.x + rng.randf_range(-45, 45)
		var z: float = forest_center.z + rng.randf_range(-45, 45)
		var s: float = rng.randf_range(0.8, 1.6)
		_make_pine(Vector3(x, 0, z), s)

	_make_pine(forest_center + Vector3(0, 9, 0), 1.3, true)
	_make_label("ЛЕС", forest_center + Vector3(0, 6, -40), Color(0.6, 0.9, 0.6))

	var orb := MeshInstance3D.new()
	var orb_mesh := SphereMesh.new()
	orb_mesh.radius = 0.4
	orb_mesh.height = 0.8
	orb.mesh = orb_mesh
	var orb_mat := StandardMaterial3D.new()
	orb_mat.albedo_color = Color(0.6, 1.0, 0.7)
	orb_mat.emission_enabled = true
	orb_mat.emission = Color(0.5, 1.0, 0.6)
	orb_mat.emission_energy_multiplier = 3.0
	orb.material_override = orb_mat
	orb.position = forest_center + Vector3(5, 1.0, 3)
	add_child(orb)
	_make_label("ты не один", forest_center + Vector3(5, 2.2, 3), Color(0.6, 1.0, 0.7))


func _setup_train() -> void:
	var waypoints := [
		Vector3(0, 0.6, 24), Vector3(0, 0.6, -55), Vector3(-25, 0.6, -108),
		Vector3(40, 0.6, -70), Vector3(120, 0.6, -25), Vector3(140, 0.6, 35),
		Vector3(70, 0.6, 100), Vector3(0, 0.6, 145), Vector3(-80, 0.6, 70),
		Vector3(-140, 0.6, 25), Vector3(-80, 0.6, -20), Vector3(-30, 0.6, 0),
	]
	train_waypoints = waypoints

	train = Node3D.new()
	train.position = waypoints[0]
	add_child(train)
	_make_train_segment(train, Color(0.15, 0.25, 0.45), true)

	for i in range(3):
		var carriage := Node3D.new()
		carriage.position = Vector3(0, 0, (i + 1) * 3.6)
		train.add_child(carriage)
		_make_train_segment(carriage, Color(0.5, 0.15, 0.2), false)

	_make_label("СТАНЦИЯ", waypoints[TRAIN_STATION_INDEX] + Vector3(0, 3.5, 0), Color(0.9, 0.95, 1.0))

	var platform := MeshInstance3D.new()
	var platform_mesh := BoxMesh.new()
	platform_mesh.size = Vector3(5, 0.4, 8)
	platform.mesh = platform_mesh
	var platform_mat := StandardMaterial3D.new()
	platform_mat.albedo_color = Color(0.6, 0.58, 0.55)
	platform.material_override = platform_mat
	platform.position = waypoints[TRAIN_STATION_INDEX] + Vector3(3, 0.2, 0)
	add_child(platform)

	var board_trigger := Area3D.new()
	var board_col := CollisionShape3D.new()
	var board_shape := SphereShape3D.new()
	board_shape.radius = 3.5
	board_col.shape = board_shape
	board_trigger.add_child(board_col)
	board_trigger.position = waypoints[TRAIN_STATION_INDEX]
	board_trigger.body_entered.connect(_on_train_board)
	add_child(board_trigger)


func _make_train_segment(parent: Node3D, color: Color, is_locomotive: bool) -> void:
	var body := MeshInstance3D.new()
	var body_mesh := BoxMesh.new()
	body_mesh.size = Vector3(2.2, 2.0, 3.2)
	body.mesh = body_mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	body.material_override = mat
	body.position = Vector3(0, 1.3, 0)
	parent.add_child(body)

	if is_locomotive:
		var nose := MeshInstance3D.new()
		var nose_mesh := BoxMesh.new()
		nose_mesh.size = Vector3(1.9, 1.6, 1.0)
		nose.mesh = nose_mesh
		var nose_mat := StandardMaterial3D.new()
		nose_mat.albedo_color = Color(0.9, 0.85, 0.3)
		nose_mat.emission_enabled = true
		nose_mat.emission = Color(0.9, 0.85, 0.3)
		nose_mat.emission_energy_multiplier = 0.8
		nose.material_override = nose_mat
		nose.position = Vector3(0, 1.0, -2.0)
		parent.add_child(nose)

	for sx in [-1, 1]:
		var wheel := MeshInstance3D.new()
		var wheel_mesh := CylinderMesh.new()
		wheel_mesh.top_radius = 0.4
		wheel_mesh.bottom_radius = 0.4
		wheel_mesh.height = 0.25
		wheel.mesh = wheel_mesh
		var wheel_mat := StandardMaterial3D.new()
		wheel_mat.albedo_color = Color(0.05, 0.05, 0.05)
		wheel.material_override = wheel_mat
		wheel.rotation_degrees = Vector3(90, 0, 0)
		wheel.position = Vector3(sx * 1.15, 0.4, 0)
		parent.add_child(wheel)


func _update_train(delta: float) -> void:
	if train == null or train_waypoints.size() < 2:
		return

	if train_stopped:
		train_stop_timer -= delta
		if train_stop_timer <= 0.0:
			train_stopped = false
			train_target_index = (TRAIN_STATION_INDEX + 1) % train_waypoints.size()
		if in_train:
			_sync_player_to_train()
		return

	var target: Vector3 = train_waypoints[train_target_index]
	var dir: Vector3 = target - train.global_position
	dir.y = 0
	var dist: float = dir.length()

	if dist < 1.5:
		if train_target_index == TRAIN_STATION_INDEX:
			train_stopped = true
			train_stop_timer = TRAIN_STOP_DURATION
			_show_puzzle_message("Поезд прибыл на станцию", Color(0.85, 0.9, 1.0))
		else:
			train_target_index = (train_target_index + 1) % train_waypoints.size()
		if in_train:
			_sync_player_to_train()
		return

	dir = dir.normalized()
	train.global_position += dir * TRAIN_SPEED * delta
	train.look_at(train.global_position + dir, Vector3.UP)

	if in_train:
		_sync_player_to_train()


func _sync_player_to_train() -> void:
	player.global_position = train.global_position + train.global_transform.basis.x * 1.6 + Vector3(0, 2.3, 0)
	player.velocity = Vector3.ZERO


func _on_train_board(body: Node3D) -> void:
	if body == player and train_stopped and not in_train and not player_caught:
		in_train = true
		player.controls_enabled = false
		_show_puzzle_message("Вы сели в поезд. ПРЫЖОК — чтобы выйти", Color(0.85, 0.9, 1.0))


func _exit_train() -> void:
	in_train = false
	player.global_position = train.global_position + train.global_transform.basis.x * -2.5 + Vector3(0, 1, 0)
	player.velocity = Vector3.ZERO
	player.controls_enabled = true


func _setup_roads() -> void:
	if train_waypoints.size() < 2:
		return
	var road_mat := StandardMaterial3D.new()
	road_mat.albedo_color = Color(0.3, 0.3, 0.32)
	road_mat.roughness = 1.0

	var line_mat := StandardMaterial3D.new()
	line_mat.albedo_color = Color(0.95, 0.9, 0.5)
	line_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

	for i in range(train_waypoints.size()):
		var a: Vector3 = train_waypoints[i]
		var b: Vector3 = train_waypoints[(i + 1) % train_waypoints.size()]
		var mid: Vector3 = (a + b) / 2.0
		var seg_len: float = a.distance_to(b)
		var angle: float = atan2(b.x - a.x, b.z - a.z)

		var road := MeshInstance3D.new()
		var road_mesh := PlaneMesh.new()
		road_mesh.size = Vector2(6.0, seg_len)
		road.mesh = road_mesh
		road.material_override = road_mat
		road.position = mid + Vector3(0, 0.04, 0)
		road.rotation.y = angle
		add_child(road)

		var line := MeshInstance3D.new()
		var line_mesh := PlaneMesh.new()
		line_mesh.size = Vector2(0.3, seg_len)
		line.mesh = line_mesh
		line.material_override = line_mat
		line.position = mid + Vector3(0, 0.05, 0)
		line.rotation.y = angle
		add_child(line)


func _make_house(pos: Vector3, rot_y_deg: float, body_color: Color, roof_color: Color) -> void:
	var house := Node3D.new()
	house.position = pos
	house.rotation_degrees = Vector3(0, rot_y_deg, 0)
	add_child(house)

	var body := MeshInstance3D.new()
	var body_mesh := BoxMesh.new()
	body_mesh.size = Vector3(4, 3, 4)
	body.mesh = body_mesh
	var body_mat := StandardMaterial3D.new()
	body_mat.albedo_color = body_color
	body.material_override = body_mat
	body.position = Vector3(0, 1.5, 0)
	house.add_child(body)

	var roof := MeshInstance3D.new()
	var roof_mesh := CylinderMesh.new()
	roof_mesh.top_radius = 0.1
	roof_mesh.bottom_radius = 3.2
	roof_mesh.height = 2.0
	roof_mesh.radial_segments = 4
	roof.mesh = roof_mesh
	var roof_mat := StandardMaterial3D.new()
	roof_mat.albedo_color = roof_color
	roof.material_override = roof_mat
	roof.rotation_degrees = Vector3(0, 45, 0)
	roof.position = Vector3(0, 4.0, 0)
	house.add_child(roof)

	var door := MeshInstance3D.new()
	var door_mesh := BoxMesh.new()
	door_mesh.size = Vector3(0.9, 1.6, 0.1)
	door.mesh = door_mesh
	var door_mat := StandardMaterial3D.new()
	door_mat.albedo_color = Color(0.4, 0.28, 0.2)
	door.material_override = door_mat
	door.position = Vector3(0, 0.8, 2.05)
	house.add_child(door)

	var wall_body := StaticBody3D.new()
	var wall_col := CollisionShape3D.new()
	var wall_shape := BoxShape3D.new()
	wall_shape.size = Vector3(4, 3, 4)
	wall_col.shape = wall_shape
	wall_col.position = Vector3(0, 1.5, 0)
	wall_body.add_child(wall_col)
	house.add_child(wall_body)


func _setup_neighborhood() -> void:
	if train_waypoints.size() < 3:
		return
	# Houses along the first couple of road segments near the hub.
	var palette := [
		Color(0.95, 0.75, 0.8), Color(0.65, 0.85, 0.8), Color(0.8, 0.85, 0.6),
		Color(0.75, 0.7, 0.95), Color(0.95, 0.85, 0.6),
	]
	var roof_palette := [
		Color(0.55, 0.4, 0.4), Color(0.4, 0.5, 0.45), Color(0.5, 0.45, 0.3),
	]
	var rng := RandomNumberGenerator.new()
	rng.seed = 55

	var npc_palette := [
		Color(0.6, 0.4, 0.5), Color(0.4, 0.55, 0.6), Color(0.65, 0.6, 0.3),
		Color(0.5, 0.35, 0.65), Color(0.3, 0.55, 0.4), Color(0.7, 0.45, 0.35),
	]

	var segments_to_build := [0, 1, 10, 11]
	for seg in segments_to_build:
		var a: Vector3 = train_waypoints[seg]
		var b: Vector3 = train_waypoints[(seg + 1) % train_waypoints.size()]
		var dir: Vector3 = (b - a).normalized()
		var perp := Vector3(dir.z, 0, -dir.x)

		for t in [0.2, 0.45, 0.7]:
			var base: Vector3 = a.lerp(b, t)
			for side in [-1, 1]:
				var hp: Vector3 = base + perp * side * 10.0
				var body_c: Color = palette[rng.randi_range(0, palette.size() - 1)]
				var roof_c: Color = roof_palette[rng.randi_range(0, roof_palette.size() - 1)]
				var facing: float = rad_to_deg(atan2(-perp.x * side, -perp.z * side))
				_make_house(hp, facing, body_c, roof_c)

				# a resident who wanders near their own front yard
				var resident_pos: Vector3 = hp + perp * side * 3.0
				var resident_color: Color = npc_palette[rng.randi_range(0, npc_palette.size() - 1)]
				_make_npc(resident_pos, resident_color, 4.0)


func _setup_zombie_zone() -> void:
	var ground_patch := MeshInstance3D.new()
	var patch_mesh := CylinderMesh.new()
	patch_mesh.top_radius = ZOMBIE_ZONE_RADIUS
	patch_mesh.bottom_radius = ZOMBIE_ZONE_RADIUS
	patch_mesh.height = 0.1
	ground_patch.mesh = patch_mesh
	var patch_mat := StandardMaterial3D.new()
	patch_mat.albedo_color = Color(0.35, 0.1, 0.1)
	ground_patch.material_override = patch_mat
	ground_patch.position = ZOMBIE_ZONE_CENTER + Vector3(0, 0.06, 0)
	add_child(ground_patch)

	_make_label("ЗОНА ЗОМБИ", ZOMBIE_ZONE_CENTER + Vector3(0, 5, -ZOMBIE_ZONE_RADIUS + 5), Color(1, 0.3, 0.3))
	_make_label("бесконечны. есть ружьё.", ZOMBIE_ZONE_CENTER + Vector3(0, 3.5, -ZOMBIE_ZONE_RADIUS + 5), Color(1, 0.6, 0.5))

	for i in range(4):
		_spawn_zombie()


func _spawn_zombie() -> void:
	if zombies.size() >= MAX_ZOMBIES:
		return

	var zombie := CharacterBody3D.new()
	var angle := randf() * TAU
	var dist := randf_range(ZOMBIE_ZONE_RADIUS * 0.5, ZOMBIE_ZONE_RADIUS * 0.95)
	zombie.position = ZOMBIE_ZONE_CENTER + Vector3(cos(angle) * dist, 0, sin(angle) * dist)
	zombie.add_to_group("zombie")

	var col := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.4
	shape.height = 1.7
	col.shape = shape
	col.position = Vector3(0, 0.85, 0)
	zombie.add_child(col)

	var body := MeshInstance3D.new()
	var body_mesh := CapsuleMesh.new()
	body_mesh.radius = 0.4
	body_mesh.height = 1.6
	body.mesh = body_mesh
	var body_mat := StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.35, 0.45, 0.3)
	body.material_override = body_mat
	body.position = Vector3(0, 0.8, 0)
	body.name = "ZombieBody"
	zombie.add_child(body)

	var head := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.26
	head_mesh.height = 0.52
	head.mesh = head_mesh
	var head_mat := StandardMaterial3D.new()
	head_mat.albedo_color = Color(0.5, 0.55, 0.4)
	head.material_override = head_mat
	head.position = Vector3(0, 1.85, 0)
	zombie.add_child(head)

	zombie.set_script(load("res://scripts/ZombieAI.gd"))
	zombie.speed = randf_range(2.0, 3.2)
	add_child(zombie)
	zombies.append(zombie)


func _update_zombies(delta: float) -> void:
	zombies = zombies.filter(func(z): return is_instance_valid(z))

	if player == null:
		return
	var dist_to_zone: float = player.global_position.distance_to(ZOMBIE_ZONE_CENTER)
	var was_in_zone := gun_in_zone
	gun_in_zone = dist_to_zone < ZOMBIE_ZONE_RADIUS + 15.0
	if gun_in_zone != was_in_zone and gun_button_node != null:
		gun_button_node.visible = gun_in_zone
		gun_label_node.visible = gun_in_zone

	if dist_to_zone < ZOMBIE_ZONE_RADIUS:
		zombie_spawn_timer -= delta
		if zombie_spawn_timer <= 0.0:
			zombie_spawn_timer = randf_range(3.0, 6.0)
			_spawn_zombie()

		for z in zombies:
			if is_instance_valid(z) and z.global_position.distance_to(player.global_position) < 1.4:
				_on_player_caught("ЗОМБИ ТЕБЯ УКУСИЛ...\nпопробуй снова")
				break

	if shoot_cooldown > 0.0:
		shoot_cooldown -= delta


func _shoot() -> void:
	if shoot_cooldown > 0.0 or player == null or player_caught:
		return
	shoot_cooldown = SHOOT_COOLDOWN_TIME

	var from: Vector3 = player_camera.global_position
	var to: Vector3 = from + player_camera.global_transform.basis.z * -60.0
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to)
	var result := space_state.intersect_ray(query)

	if result.has("collider"):
		var collider = result["collider"]
		if collider.is_in_group("zombie"):
			zombies.erase(collider)
			collider.die()
			_show_puzzle_message("Зомби повержен", Color(0.6, 1.0, 0.6))


func _setup_lavash_shop() -> void:
	var shop_body := _box(Vector3(4, 3, 3.5), LAVASH_POS + Vector3(0, 1.5, -1.5), Color(0.85, 0.55, 0.15))
	var roof := MeshInstance3D.new()
	var roof_mesh := BoxMesh.new()
	roof_mesh.size = Vector3(4.6, 0.3, 4.0)
	roof.mesh = roof_mesh
	var roof_mat := StandardMaterial3D.new()
	roof_mat.albedo_color = Color(0.5, 0.3, 0.15)
	roof.material_override = roof_mat
	roof.position = LAVASH_POS + Vector3(0, 3.15, -1.5)
	add_child(roof)

	var counter := _box(Vector3(3.5, 1.0, 0.6), LAVASH_POS + Vector3(0, 0.5, 0.2), Color(0.6, 0.4, 0.25))

	_make_label("ЛАВАШ", LAVASH_POS + Vector3(0, 3.8, -1.5), Color(1, 0.85, 0.5))
	_make_label("подходи, если клиент ждёт", LAVASH_POS + Vector3(0, 1.8, 0.6), Color(1, 1, 0.9))

	var trigger := Area3D.new()
	var trigger_col := CollisionShape3D.new()
	var trigger_shape := BoxShape3D.new()
	trigger_shape.size = Vector3(3, 2, 2)
	trigger_col.shape = trigger_shape
	trigger.add_child(trigger_col)
	trigger.position = LAVASH_POS + Vector3(0, 1, 1.2)
	trigger.body_entered.connect(_on_lavash_counter_entered)
	add_child(trigger)

	lavash_timer = randf_range(2.0, 4.0)


func _spawn_lavash_customer() -> void:
	lavash_customer_type = lavash_customer_types[randi() % lavash_customer_types.size()]

	var customer := Node3D.new()
	customer.position = LAVASH_POS + Vector3(0, 0, 2.2)

	var body := MeshInstance3D.new()
	var body_mesh := CapsuleMesh.new()
	body_mesh.radius = 0.4
	body_mesh.height = 1.6
	body.mesh = body_mesh
	var body_mat := StandardMaterial3D.new()
	body_mat.albedo_color = lavash_customer_type["color"]
	body.material_override = body_mat
	body.position = Vector3(0, 0.8, 0)
	customer.add_child(body)

	var head := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.26
	head_mesh.height = 0.52
	head.mesh = head_mesh
	var head_mat := StandardMaterial3D.new()
	head_mat.albedo_color = lavash_customer_type["color"].lightened(0.2)
	head.material_override = head_mat
	head.position = Vector3(0, 1.85, 0)
	customer.add_child(head)

	customer.look_at(LAVASH_POS, Vector3.UP)
	add_child(customer)
	lavash_customer_node = customer

	_show_puzzle_message(lavash_customer_type["arrive"], Color(1, 1, 0.8))
	lavash_state = "waiting_order"


func _on_lavash_counter_entered(body: Node3D) -> void:
	if body == player and lavash_state == "waiting_order":
		lavash_state = "cooking"
		lavash_timer = 2.0
		_show_puzzle_message("Готовите лаваш...", Color(1, 0.8, 0.4))


func _serve_lavash() -> void:
	_show_puzzle_message(lavash_customer_type["served"], Color(1, 0.9, 0.6))
	if is_instance_valid(lavash_customer_node):
		lavash_customer_node.queue_free()
	lavash_state = "served"
	lavash_timer = 2.0


func _update_lavash_shop(delta: float) -> void:
	match lavash_state:
		"empty":
			lavash_timer -= delta
			if lavash_timer <= 0.0:
				_spawn_lavash_customer()
		"cooking":
			lavash_timer -= delta
			if lavash_timer <= 0.0:
				_serve_lavash()
		"served":
			lavash_timer -= delta
			if lavash_timer <= 0.0:
				lavash_state = "empty"
				lavash_timer = randf_range(3.0, 6.0)


func _setup_rope_challenge() -> void:
	# --- dark environment used only while inside the rope challenge ---
	rope_environment = Environment.new()
	rope_environment.background_mode = Environment.BG_COLOR
	rope_environment.background_color = Color(0.0, 0.0, 0.0)
	rope_environment.fog_enabled = false
	rope_environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	rope_environment.ambient_light_color = Color(0, 0, 0)
	rope_environment.ambient_light_energy = 0.0
	rope_environment.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	rope_environment.glow_enabled = false

	# --- white entrance door, in the main world near the hub ---
	var door_pos := Vector3(-18, 0, -18)
	var frame_color := Color(0.95, 0.95, 0.98)
	_box(Vector3(0.3, 4.2, 2.6), door_pos + Vector3(-1.15, 2.1, 0), frame_color, false)
	_box(Vector3(0.3, 4.2, 2.6), door_pos + Vector3(1.15, 2.1, 0), frame_color, false)
	_box(Vector3(2.6, 0.3, 2.6), door_pos + Vector3(0, 4.2, 0), frame_color, false)

	var slab := MeshInstance3D.new()
	var slab_mesh := BoxMesh.new()
	slab_mesh.size = Vector3(1.9, 3.8, 0.15)
	slab.mesh = slab_mesh
	var slab_mat := StandardMaterial3D.new()
	slab_mat.albedo_color = Color(0.97, 0.97, 1.0)
	slab_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	slab_mat.emission_enabled = true
	slab_mat.emission = Color(1, 1, 1)
	slab_mat.emission_energy_multiplier = 0.5
	slab.material_override = slab_mat
	slab.position = door_pos + Vector3(0, 1.95, 0)
	add_child(slab)
	_make_label("???", door_pos + Vector3(0, 5.0, 0), Color(1, 1, 1))

	var enter_trigger := Area3D.new()
	var enter_col := CollisionShape3D.new()
	var enter_shape := SphereShape3D.new()
	enter_shape.radius = 2.0
	enter_col.shape = enter_shape
	enter_trigger.add_child(enter_col)
	enter_trigger.position = door_pos
	enter_trigger.body_entered.connect(_on_rope_entrance)
	add_child(enter_trigger)

	var dark_start_index := get_child_count()

	# --- the rope itself, out in a dark pocket of the world ---
	var rope_color := Color(0.4, 0.3, 0.2)
	var rope_center: Vector3 = ROPE_ORIGIN + Vector3(0, 0, -ROPE_LENGTH / 2.0)
	_box(Vector3(0.7, 0.25, ROPE_LENGTH), rope_center, rope_color)

	_make_label("иди вперёд. не упади.", ROPE_ORIGIN + Vector3(0, 2.0, -3), Color(1, 1, 1))

	# --- white exit door at the far end of the rope ---
	var exit_pos: Vector3 = ROPE_ORIGIN + Vector3(0, 0, -ROPE_LENGTH)
	_box(Vector3(0.3, 4.2, 2.6), exit_pos + Vector3(-1.15, 2.1, 0), frame_color, false)
	_box(Vector3(0.3, 4.2, 2.6), exit_pos + Vector3(1.15, 2.1, 0), frame_color, false)
	_box(Vector3(2.6, 0.3, 2.6), exit_pos + Vector3(0, 4.2, 0), frame_color, false)

	var exit_slab := MeshInstance3D.new()
	var exit_slab_mesh := BoxMesh.new()
	exit_slab_mesh.size = Vector3(1.9, 3.8, 0.15)
	exit_slab.mesh = exit_slab_mesh
	exit_slab.material_override = slab_mat
	exit_slab.position = exit_pos + Vector3(0, 1.95, 0)
	add_child(exit_slab)

	var exit_trigger := Area3D.new()
	var exit_col := CollisionShape3D.new()
	var exit_shape := SphereShape3D.new()
	exit_shape.radius = 2.0
	exit_col.shape = exit_shape
	exit_trigger.add_child(exit_col)
	exit_trigger.position = exit_pos
	exit_trigger.body_entered.connect(_on_rope_exit)
	add_child(exit_trigger)

	_setup_fallen_chamber()
	_apply_dark_layer(dark_start_index)


func _apply_dark_layer(start_index: int) -> void:
	for i in range(start_index, get_child_count()):
		_set_layer_recursive(get_child(i), 2)


func _set_layer_recursive(node: Node, layer: int) -> void:
	if node is VisualInstance3D:
		node.layers = layer
	for child in node.get_children():
		_set_layer_recursive(child, layer)


func _setup_fallen_chamber() -> void:
	var size := 16.0
	var floor_mi := MeshInstance3D.new()
	var floor_mesh := PlaneMesh.new()
	floor_mesh.size = Vector2(size, size)
	floor_mi.mesh = floor_mesh
	var floor_mat := StandardMaterial3D.new()
	floor_mat.albedo_color = Color(0.08, 0.08, 0.1)
	floor_mi.material_override = floor_mat
	floor_mi.position = FALLEN_CHAMBER_ORIGIN
	add_child(floor_mi)

	var floor_body := StaticBody3D.new()
	var floor_col := CollisionShape3D.new()
	var floor_shape := BoxShape3D.new()
	floor_shape.size = Vector3(size, 0.2, size)
	floor_col.shape = floor_shape
	floor_body.position = FALLEN_CHAMBER_ORIGIN
	floor_body.add_child(floor_col)
	add_child(floor_body)

	var wall_color := Color(0.05, 0.05, 0.07)
	_box(Vector3(size, 4, 0.4), FALLEN_CHAMBER_ORIGIN + Vector3(0, 2, -size / 2.0), wall_color)
	_box(Vector3(size, 4, 0.4), FALLEN_CHAMBER_ORIGIN + Vector3(0, 2, size / 2.0), wall_color)
	_box(Vector3(0.4, 4, size), FALLEN_CHAMBER_ORIGIN + Vector3(-size / 2.0, 2, 0), wall_color)
	_box(Vector3(0.4, 4, size), FALLEN_CHAMBER_ORIGIN + Vector3(size / 2.0, 2, 0), wall_color)

	# the apparatus — a console with 5 levers in front of it
	_box(Vector3(5, 1.6, 0.6), FALLEN_CHAMBER_ORIGIN + Vector3(0, 0.8, -5.5), Color(0.2, 0.2, 0.25))
	_make_label("ЗАГАДКА", FALLEN_CHAMBER_ORIGIN + Vector3(0, 2.6, -5.5), Color(0.9, 0.9, 1.0))

	var lever_x_positions := [-4.5, -2.2, 0.0, 2.2, 4.5]
	for i in range(lever_x_positions.size()):
		var lx: float = lever_x_positions[i]
		var lever_pos: Vector3 = FALLEN_CHAMBER_ORIGIN + Vector3(lx, 0, -3.5)

		_box(Vector3(0.2, 1.4, 0.2), lever_pos + Vector3(0, 0.7, 0), Color(0.5, 0.45, 0.4), false)

		var handle := MeshInstance3D.new()
		var handle_mesh := SphereMesh.new()
		handle_mesh.radius = 0.2
		handle_mesh.height = 0.4
		handle.mesh = handle_mesh
		var handle_mat := StandardMaterial3D.new()
		handle_mat.albedo_color = Color(0.7, 0.15, 0.15)
		handle.material_override = handle_mat
		handle.position = lever_pos + Vector3(0, 1.35, 0)
		add_child(handle)

		var lever_label := Label3D.new()
		lever_label.text = "?"
		lever_label.position = lever_pos + Vector3(0, 2.0, 0)
		lever_label.font_size = 56
		lever_label.outline_size = 12
		lever_label.modulate = Color(1, 1, 1)
		lever_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		add_child(lever_label)
		fallen_lever_labels.append(lever_label)
		fallen_lever_values.append(0)

		var trigger := Area3D.new()
		var trigger_col := CollisionShape3D.new()
		var trigger_shape := SphereShape3D.new()
		trigger_shape.radius = 1.0
		trigger_col.shape = trigger_shape
		trigger.add_child(trigger_col)
		trigger.position = lever_pos + Vector3(0, 1, 0)
		trigger.body_entered.connect(_on_lever_pulled.bind(i))
		add_child(trigger)


func _start_fallen_riddle() -> void:
	var a := randi_range(1, 9)
	var b := randi_range(1, 9)
	fallen_riddle_answer = a + b

	var correct_idx := randi_range(0, fallen_lever_labels.size() - 1)
	var used := {fallen_riddle_answer: true}
	for i in range(fallen_lever_labels.size()):
		var v: int
		if i == correct_idx:
			v = fallen_riddle_answer
		else:
			v = fallen_riddle_answer + randi_range(-6, 6)
			while v == fallen_riddle_answer or used.has(v) or v < 0:
				v = fallen_riddle_answer + randi_range(-6, 6)
			used[v] = true
		fallen_lever_values[i] = v
		fallen_lever_labels[i].text = str(v)

	_show_puzzle_message("Голос (муж.): " + str(a) + "...", Color(0.7, 0.8, 1.0))
	var t := create_tween()
	t.tween_interval(2.4)
	t.tween_callback(func(): _show_puzzle_message("Голос (жен.): " + str(b) + "...", Color(1.0, 0.8, 0.9)))
	t.tween_interval(2.4)
	t.tween_callback(func(): _show_puzzle_message("Сложи эти числа. Потяни нужный рычаг.", Color(1, 1, 0.8)))


func _on_lever_pulled(body: Node3D, i: int) -> void:
	if body != player or not fallen_chamber_active:
		return

	if fallen_lever_values[i] == fallen_riddle_answer:
		fallen_chamber_active = false
		player_camera.environment = null
		flashlight.visible = false
		player.global_position = Vector3(0, 2, 3)
		player.rotation = Vector3.ZERO
		player.rotate_y(deg_to_rad(180))
		player.velocity = Vector3.ZERO
		_show_puzzle_message("Рычаг верный! Ты выбрался.", Color(0.6, 1.0, 0.6))
	else:
		_show_puzzle_message("Неверно... голоса начинают заново.", Color(1, 0.4, 0.4))
		_start_fallen_riddle()


func _on_rope_entrance(body: Node3D) -> void:
	if body == player and not in_rope_challenge and not player_caught:
		in_rope_challenge = true
		player.global_position = ROPE_ORIGIN + Vector3(0, 1.0, 0)
		player.rotation = Vector3.ZERO
		player.rotate_y(deg_to_rad(180))
		player.velocity = Vector3.ZERO
		player_camera.environment = rope_environment
		flashlight.visible = true
		_show_puzzle_message("Темнота. Только канат под ногами.", Color(0.8, 0.8, 0.85))


func _on_rope_exit(body: Node3D) -> void:
	if body == player and in_rope_challenge:
		in_rope_challenge = false
		player_camera.environment = null
		flashlight.visible = false
		player.global_position = Vector3(0, 2, 3)
		player.rotation = Vector3.ZERO
		player.rotate_y(deg_to_rad(180))
		player.velocity = Vector3.ZERO
		_show_puzzle_message("Ты дошёл. Снова светло.", Color(1, 1, 0.8))


func _update_rope_challenge() -> void:
	if not in_rope_challenge or player == null:
		return
	if player.global_position.y < ROPE_ORIGIN.y - 12.0:
		in_rope_challenge = false
		fallen_chamber_active = true
		player.global_position = FALLEN_CHAMBER_ORIGIN + Vector3(0, 1.0, 5)
		player.rotation = Vector3.ZERO
		player.velocity = Vector3.ZERO
		_show_puzzle_message("Ты сорвался и упал во тьму...", Color(0.6, 0.6, 0.7))
		_start_fallen_riddle()


func _setup_pink_house() -> void:
	# A surreal oversized pink dollhouse, tilted, resting near the beach path —
	# purely a landmark to look at.
	var house := Node3D.new()
	house.position = Vector3(-24, 0, -55)
	house.rotation_degrees = Vector3(0, 25, 12)
	add_child(house)

	var pink := Color(0.98, 0.65, 0.78)
	var trim := Color(0.95, 0.9, 0.92)

	var body := MeshInstance3D.new()
	var body_mesh := BoxMesh.new()
	body_mesh.size = Vector3(7, 6, 6)
	body.mesh = body_mesh
	var body_mat := StandardMaterial3D.new()
	body_mat.albedo_color = pink
	body.material_override = body_mat
	body.position = Vector3(0, 5, 0)
	house.add_child(body)

	var roof := MeshInstance3D.new()
	var roof_mesh := CylinderMesh.new()
	roof_mesh.top_radius = 0.2
	roof_mesh.bottom_radius = 5.2
	roof_mesh.height = 4.0
	roof_mesh.radial_segments = 4
	roof.mesh = roof_mesh
	var roof_mat := StandardMaterial3D.new()
	roof_mat.albedo_color = trim
	roof.material_override = roof_mat
	roof.rotation_degrees = Vector3(0, 45, 0)
	roof.position = Vector3(0, 10, 0)
	house.add_child(roof)


# ---------------- PLAYER ----------------

func _setup_player() -> void:
	player = CharacterBody3D.new()
	player.position = Vector3(0, 2, 3)
	player.rotate_y(deg_to_rad(180))

	var col := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.4
	shape.height = 1.7
	col.shape = shape
	col.position = Vector3(0, 0.85, 0)
	player.add_child(col)

	var cam := Camera3D.new()
	cam.name = "Camera3D"
	cam.position = Vector3(0, 1.6, 0)
	cam.fov = 75
	player.add_child(cam)

	player.set_script(load("res://scripts/Player.gd"))
	player.add_to_group("player")
	add_child(player)
	player_camera = cam

	# simple low-poly gun, visible in first person
	var gun := Node3D.new()
	gun.position = Vector3(0.35, -0.3, -0.6)
	cam.add_child(gun)

	var gun_body := MeshInstance3D.new()
	var gun_body_mesh := BoxMesh.new()
	gun_body_mesh.size = Vector3(0.12, 0.12, 0.5)
	gun_body.mesh = gun_body_mesh
	var gun_mat := StandardMaterial3D.new()
	gun_mat.albedo_color = Color(0.1, 0.1, 0.12)
	gun_body.material_override = gun_mat
	gun.add_child(gun_body)

	flashlight = SpotLight3D.new()
	flashlight.visible = false
	flashlight.spot_range = 18.0
	flashlight.spot_angle = 30.0
	flashlight.light_energy = 2.2
	flashlight.light_color = Color(1.0, 0.95, 0.85)
	flashlight.light_cull_mask = 2  # layer 2 = the dark zone (rope + fallen chamber)
	flashlight.position = Vector3(0, 0, -0.2)
	cam.add_child(flashlight)

	var gun_handle := MeshInstance3D.new()
	var gun_handle_mesh := BoxMesh.new()
	gun_handle_mesh.size = Vector3(0.1, 0.22, 0.12)
	gun_handle.mesh = gun_handle_mesh
	gun_handle.material_override = gun_mat
	gun_handle.position = Vector3(0, -0.17, 0.15)
	gun.add_child(gun_handle)


# ---------------- UI / TOUCH CONTROLS ----------------

func _setup_ui() -> void:
	canvas = CanvasLayer.new()
	add_child(canvas)

	# Joystick base
	joystick_base = _make_circle(140, Color(1, 1, 1, 0.18))
	joystick_base.position = Vector2(150, 900)
	canvas.add_child(joystick_base)

	joystick_knob = _make_circle(70, Color(1, 1, 1, 0.45))
	joystick_knob.position = joystick_base.position + Vector2(35, 35)
	canvas.add_child(joystick_knob)

	# Jump button — bottom-left corner, far from the look-drag side (right).
	# Checked before the joystick zone in _input, so it always wins a tap
	# even though it technically sits inside the left (movement) half.
	var jump_size := 150
	var jump_btn := _make_circle(jump_size, Color(1, 0.85, 0.4, 0.55))
	jump_btn.position = Vector2(20, 1280 - jump_size - 20)
	canvas.add_child(jump_btn)
	jump_button_rect = Rect2(jump_btn.position, Vector2(jump_size, jump_size))

	var jump_label := Label.new()
	jump_label.text = "ПРЫЖОК"
	jump_label.position = jump_btn.position + Vector2(jump_size / 2.0 - 36, jump_size / 2.0 - 10)
	jump_label.add_theme_font_size_override("font_size", 18)
	canvas.add_child(jump_label)

	# Shoot button — only visible near the zombie zone.
	var gun_size := 140
	var gun_btn := _make_circle(gun_size, Color(0.9, 0.15, 0.15, 0.55))
	gun_btn.position = Vector2(720 - gun_size - 30, 1280 - gun_size - 30)
	gun_btn.visible = false
	canvas.add_child(gun_btn)
	gun_button_node = gun_btn
	gun_button_rect = Rect2(gun_btn.position, Vector2(gun_size, gun_size))

	var gun_label := Label.new()
	gun_label.text = "ОГОНЬ"
	gun_label.position = gun_btn.position + Vector2(gun_size / 2.0 - 32, gun_size / 2.0 - 10)
	gun_label.add_theme_font_size_override("font_size", 18)
	gun_label.visible = false
	canvas.add_child(gun_label)
	gun_label_node = gun_label

	# Dialogue panel
	dialogue_panel = Control.new()
	dialogue_panel.position = Vector2(0, 850)
	dialogue_panel.size = Vector2(720, 200)
	canvas.add_child(dialogue_panel)

	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.03, 0.08, 0.82)
	bg.size = Vector2(720, 200)
	dialogue_panel.add_child(bg)

	dialogue_label = Label.new()
	dialogue_label.position = Vector2(30, 30)
	dialogue_label.size = Vector2(660, 140)
	dialogue_label.add_theme_font_size_override("font_size", 26)
	dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	dialogue_panel.add_child(dialogue_label)

	var hint := Label.new()
	hint.text = "(нажми на экран)"
	hint.position = Vector2(500, 160)
	hint.modulate = Color(1, 1, 1, 0.6)
	hint.add_theme_font_size_override("font_size", 16)
	dialogue_panel.add_child(hint)

	# "Caught by monster" overlay
	caught_overlay = ColorRect.new()
	caught_overlay.color = Color(0.5, 0, 0, 0.0)
	caught_overlay.size = Vector2(720, 1280)
	caught_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(caught_overlay)

	caught_label = Label.new()
	caught_label.text = "ОНО ТЕБЯ НАШЛО...\nпопробуй снова"
	caught_label.position = Vector2(160, 560)
	caught_label.size = Vector2(400, 120)
	caught_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caught_label.add_theme_font_size_override("font_size", 30)
	caught_label.modulate = Color(1, 1, 1, 0)
	canvas.add_child(caught_label)

	# Puzzle feedback label (circus, etc.)
	puzzle_message_label = Label.new()
	puzzle_message_label.text = ""
	puzzle_message_label.position = Vector2(160, 200)
	puzzle_message_label.size = Vector2(400, 60)
	puzzle_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	puzzle_message_label.add_theme_font_size_override("font_size", 28)
	puzzle_message_label.modulate = Color(1, 1, 1, 0)
	canvas.add_child(puzzle_message_label)


func _make_circle(diameter: float, color: Color) -> Control:
	var c := Control.new()
	c.size = Vector2(diameter, diameter)
	var panel := ColorRect.new()
	panel.color = color
	panel.size = Vector2(diameter, diameter)
	c.add_child(panel)
	return c


func _show_intro_line() -> void:
	if intro_index < intro_lines.size():
		dialogue_label.text = intro_lines[intro_index]
		dialogue_panel.visible = true
	else:
		intro_active = false
		dialogue_panel.visible = false
		player.enable_controls()


func _advance_intro() -> void:
	intro_index += 1
	_show_intro_line()


# ---------------- INPUT ----------------

func _input(event: InputEvent) -> void:
	if intro_active:
		if event is InputEventScreenTouch and event.pressed:
			_advance_intro()
		elif event is InputEventMouseButton and event.pressed:
			_advance_intro()
		return

	if event is InputEventScreenTouch:
		if event.pressed:
			if jump_button_rect.has_point(event.position):
				if in_train:
					_exit_train()
				else:
					player.jump()
			elif gun_in_zone and gun_button_rect.has_point(event.position):
				_shoot()
			elif event.position.x < get_viewport().size.x / 2.0:
				joystick_touch_index = event.index
				joystick_center = event.position
				joystick_base.position = joystick_center - Vector2(70, 70)
				joystick_knob.position = joystick_center - Vector2(35, 35)
				joystick_base.visible = true
				joystick_knob.visible = true
			else:
				look_touch_index = event.index
		else:
			if event.index == joystick_touch_index:
				joystick_touch_index = -1
				player.set_move_vector(Vector2.ZERO)
				joystick_knob.position = joystick_base.position + Vector2(35, 35)
			if event.index == look_touch_index:
				look_touch_index = -1

	elif event is InputEventScreenDrag:
		if event.index == joystick_touch_index:
			var offset: Vector2 = event.position - joystick_center
			offset = offset.limit_length(JOYSTICK_RADIUS)
			joystick_knob.position = joystick_center + offset - Vector2(35, 35)
			var v := offset / JOYSTICK_RADIUS
			player.set_move_vector(Vector2(v.x, v.y))
		elif event.index == look_touch_index:
			player.add_look_delta(event.relative)

	# Desktop fallback (testing in the editor with mouse+keyboard)
	elif event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		player.add_look_delta(event.relative)
	elif event is InputEventMouseButton and event.pressed and not intro_active:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and gun_in_zone:
			_shoot()
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _process(delta: float) -> void:
	if intro_active or player == null:
		return

	_update_chase(delta)
	_update_neighbor_chase(delta)
	_update_weather(delta)
	_update_clouds(delta)
	_update_showman_riddles(delta)
	_update_train(delta)
	_update_zombies(delta)
	_update_lavash_shop(delta)
	_update_rope_challenge()

	if player_caught:
		return

	if not OS.has_feature("mobile"):
		var kb := Vector2.ZERO
		if Input.is_physical_key_pressed(KEY_W):
			kb.y -= 1
		if Input.is_physical_key_pressed(KEY_S):
			kb.y += 1
		if Input.is_physical_key_pressed(KEY_A):
			kb.x -= 1
		if Input.is_physical_key_pressed(KEY_D):
			kb.x += 1
		if kb.length() > 0:
			player.set_move_vector(kb.normalized())
		elif joystick_touch_index == -1:
			player.set_move_vector(Vector2.ZERO)
		if Input.is_physical_key_pressed(KEY_SPACE):
			if in_train:
				_exit_train()
			else:
				player.jump()


func _update_showman_riddles(delta: float) -> void:
	if showman_riddle_cooldown > 0.0:
		showman_riddle_cooldown -= delta
		return
	if showman == null or player == null:
		return
	if player.global_position.distance_to(showman.global_position) < 4.0:
		var line: String = showman_riddles[randi() % showman_riddles.size()]
		_show_puzzle_message(line, Color(1, 0.95, 0.7))
		showman_riddle_cooldown = 14.0


func _update_chase(delta: float) -> void:
	if player_caught:
		return

	var dist_to_zone := player.global_position.distance_to(chase_zone_center)

	if not chase_triggered and dist_to_zone < chase_zone_radius:
		chase_triggered = true
		var away := (player.global_position - chase_zone_center).normalized()
		if away.length() < 0.01:
			away = Vector3(0, 0, 1)
		monster.global_position = player.global_position + away * 14.0 + Vector3(0, 0, 0)
		monster.start_chase(player)

	if chase_triggered and monster.chasing:
		if monster.distance_to_target() < monster.catch_distance:
			_on_player_caught()
		elif dist_to_zone > chase_zone_radius * 2.2:
			# player escaped far enough — monster gives up
			monster.stop_chase()
			chase_triggered = false


func _on_player_caught(message: String = "ОНО ТЕБЯ НАШЛО...\nпопробуй снова") -> void:
	player_caught = true
	monster.stop_chase()
	neighbor_active = false
	neighbor.visible = false
	player.set_move_vector(Vector2.ZERO)
	if in_train:
		in_train = false
		player.controls_enabled = true

	caught_label.text = message
	var tween := create_tween()
	tween.tween_property(caught_overlay, "color:a", 0.55, 0.25)
	tween.parallel().tween_property(caught_label, "modulate:a", 1.0, 0.35)
	tween.tween_interval(1.2)
	tween.tween_callback(_respawn_player)
	tween.tween_property(caught_overlay, "color:a", 0.0, 0.4)
	tween.parallel().tween_property(caught_label, "modulate:a", 0.0, 0.4)
	tween.tween_callback(func(): player_caught = false; chase_triggered = false)


func _respawn_player() -> void:
	player.global_position = Vector3(0, 2, 3)
	player.rotation = Vector3.ZERO
	player.rotate_y(deg_to_rad(180))
	player.velocity = Vector3.ZERO
