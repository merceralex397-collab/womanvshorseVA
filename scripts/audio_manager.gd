class_name AudioManager
extends Node

# Procedural audio manager using AudioStreamGenerator
# All SFX is generated via GDScript - no external audio files

const SAMPLE_RATE: int = 44100
const BUFFER_SIZE: int = 1024

# Pre-created audio stream players for concurrent SFX playback
var _attack_player: AudioStreamPlayer
var _hit_player: AudioStreamPlayer
var _death_player: AudioStreamPlayer
var _player_hit_player: AudioStreamPlayer
var _wave_start_player: AudioStreamPlayer

func _ready() -> void:
	_attack_player = AudioStreamPlayer.new()
	_hit_player = AudioStreamPlayer.new()
	_death_player = AudioStreamPlayer.new()
	_player_hit_player = AudioStreamPlayer.new()
	_wave_start_player = AudioStreamPlayer.new()
	
	add_child(_attack_player)
	add_child(_hit_player)
	add_child(_death_player)
	add_child(_player_hit_player)
	add_child(_wave_start_player)

# Play attack SFX - short sine sweep (high→low), ~120ms
static func play_attack_sfx() -> void:
	var manager = _get_manager()
	if manager:
		manager._play_attack()

# Play hit SFX - percussive noise burst, ~80ms
static func play_hit_sfx() -> void:
	var manager = _get_manager()
	if manager:
		manager._play_hit()

# Play death SFX - descending sine tone, ~200ms
static func play_death_sfx() -> void:
	var manager = _get_manager()
	if manager:
		manager._play_death()

# Play player hit SFX - harsh buzz (square wave), ~180ms
static func play_player_hit_sfx() -> void:
	var manager = _get_manager()
	if manager:
		manager._play_player_hit()

# Play wave start SFX - ascending chime (sine), ~250ms
static func play_wave_start_sfx() -> void:
	var manager = _get_manager()
	if manager:
		manager._play_wave_start()

static func _get_manager() -> AudioManager:
	var tree = Engine.get_main_loop() as SceneTree
	if tree and tree.root.has_node("AudioManager"):
		return tree.root.get_node("AudioManager") as AudioManager
	return null

func _play_attack() -> void:
	_play_generator(0.12, "_gen_attack")

func _play_hit() -> void:
	_play_generator(0.08, "_gen_hit")

func _play_death() -> void:
	_play_generator(0.20, "_gen_death")

func _play_player_hit() -> void:
	_play_generator(0.18, "_gen_player_hit")

func _play_wave_start() -> void:
	_play_generator(0.25, "_gen_wave_start")

func _play_generator(duration: float, gen_type: String) -> void:
	var player: AudioStreamPlayer
	var sample_func: Callable
	
	match gen_type:
		"_gen_attack":
			player = _attack_player
			sample_func = _generate_attack_sample
		"_gen_hit":
			player = _hit_player
			sample_func = _generate_hit_sample
		"_gen_death":
			player = _death_player
			sample_func = _generate_death_sample
		"_gen_player_hit":
			player = _player_hit_player
			sample_func = _generate_player_hit_sample
		"_gen_wave_start":
			player = _wave_start_player
			sample_func = _generate_wave_start_sample
		_:
			return
	
	var generator = AudioStreamGenerator.new()
	generator.buffer_length = BUFFER_SIZE / float(SAMPLE_RATE)
	
	var playback = generator.get_playback()
	player.stream = generator
	player.play()
	
	var total_samples = int(duration * SAMPLE_RATE)
	var sample_index = 0
	
	while sample_index < total_samples and player.playing:
		var frames = playback.get_available_frames()
		if frames > 0:
			var to_write = mini(frames, total_samples - sample_index)
			var chunk: PackedVector2Array = PackedVector2Array()
			for i in range(to_write):
				var s = sample_func.call(sample_index + i)
				chunk.append(Vector2(s, s))
			playback.push_frame(chunk)
			sample_index += to_write
		else:
			await get_tree().process_frame
	
	player.stop()

# Attack: sine sweep high → low
func _generate_attack_sample(sample_index: int) -> float:
	var t = float(sample_index) / SAMPLE_RATE
	var freq_start = 880.0  # A5
	var freq_end = 220.0    # A3
	var freq = freq_start + (freq_end - freq_start) * (t / 0.12)
	var phase = t * freq * 2.0 * PI
	var envelope = 1.0 - (t / 0.12)  # Linear decay
	return sin(phase) * envelope * 0.5

# Hit: noise burst with decay
func _generate_hit_sample(sample_index: int) -> float:
	var t = float(sample_index) / SAMPLE_RATE
	var envelope = exp(-t * 30.0)  # Fast exponential decay
	var noise = randf() * 2.0 - 1.0
	var tone = sin(t * 400.0 * 2.0 * PI) * 0.3
	return (noise * 0.7 + tone) * envelope * 0.4

# Death: descending sine tone
func _generate_death_sample(sample_index: int) -> float:
	var t = float(sample_index) / SAMPLE_RATE
	var freq_start = 440.0   # A4
	var freq_end = 110.0     # A2
	var freq = freq_start + (freq_end - freq_start) * (t / 0.20)
	var phase = t * freq * 2.0 * PI
	var envelope = 1.0 - (t / 0.20)
	return sin(phase) * envelope * 0.5

# Player hit: harsh buzz with square wave
func _generate_player_hit_sample(sample_index: int) -> float:
	var t = float(sample_index) / SAMPLE_RATE
	var envelope = exp(-t * 8.0)  # Slower decay than hit
	var buzz = sign(sin(t * 120.0 * 2.0 * PI)) * 0.5
	var noise = randf() * 0.3 - 0.15
	return (buzz + noise) * envelope * 0.4

# Wave start: ascending chime
func _generate_wave_start_sample(sample_index: int) -> float:
	var t = float(sample_index) / SAMPLE_RATE
	var freq_start = 440.0   # A4
	var freq_end = 880.0     # A5
	var freq = freq_start + (freq_end - freq_start) * (t / 0.25)
	var phase = t * freq * 2.0 * PI
	var envelope = 1.0 - (t / 0.25)
	# Add slight vibrato
	var vibrato = 1.0 + 0.02 * sin(t * 20.0 * 2.0 * PI)
	return sin(phase * vibrato) * envelope * 0.4