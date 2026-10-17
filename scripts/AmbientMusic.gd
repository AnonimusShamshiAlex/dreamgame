extends AudioStreamPlayer

const SAMPLE_RATE := 44100.0

var playback: AudioStreamGeneratorPlayback
var t := 0.0

# Two warm chord voicings we slowly morph between (C-based and D-based triads)
# so the pad keeps gently evolving instead of droning on a single frozen chord.
var chord_a := [130.81, 196.00, 261.63]   # C3, G3, C4
var chord_b := [146.83, 220.00, 293.66]   # D3, A3, D4
var chord_progress := 0.0
var chord_dir := 1.0

var chime_timer := 0.0
var next_chime_in := 4.0
var chime_notes := [523.25, 587.33, 659.25, 783.99, 880.0]
var active_chimes: Array = []


func _ready() -> void:
	var gen := AudioStreamGenerator.new()
	gen.mix_rate = SAMPLE_RATE
	gen.buffer_length = 0.5
	stream = gen
	volume_db = -13.0
	play()
	playback = get_stream_playback()
	_fill_buffer(int(SAMPLE_RATE * 0.5))


func _process(_delta: float) -> void:
	if playback == null:
		return
	var frames_available := playback.get_frames_available()
	if frames_available > 0:
		_fill_buffer(frames_available)


func _fill_buffer(frames: int) -> void:
	var dt := 1.0 / SAMPLE_RATE

	for i in range(frames):
		t += dt

		chord_progress += dt / 24.0 * chord_dir
		if chord_progress >= 1.0:
			chord_progress = 1.0
			chord_dir = -1.0
		elif chord_progress <= 0.0:
			chord_progress = 0.0
			chord_dir = 1.0

		var sample := 0.0
		for v in range(chord_a.size()):
			var f: float = lerp(chord_a[v], chord_b[v], chord_progress)
			var vol: float = 0.09 if v == 0 else (0.065 if v == 1 else 0.045)
			sample += sin(t * f * TAU) * vol
			sample += sin(t * f * 1.006 * TAU) * vol * 0.6

		chime_timer += dt
		if chime_timer >= next_chime_in:
			chime_timer = 0.0
			next_chime_in = randf_range(3.0, 7.0)
			active_chimes.append({
				"freq": chime_notes[randi() % chime_notes.size()],
				"age": 0.0,
				"dur": randf_range(2.5, 4.0),
			})

		var j := active_chimes.size() - 1
		while j >= 0:
			var c = active_chimes[j]
			c["age"] += dt
			if c["age"] >= c["dur"]:
				active_chimes.remove_at(j)
			else:
				var env: float = sin(PI * c["age"] / c["dur"])
				sample += sin(t * c["freq"] * TAU) * env * 0.05
			j -= 1

		playback.push_frame(Vector2(sample, sample))
