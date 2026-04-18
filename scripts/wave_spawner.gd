class_name WaveSpawner
extends Node2D

signal wave_started(wave_number: int)
signal enemies_alive_changed(count: int)
signal score_changed(new_score: int)

@export var arena_margin: float = 50.0

var wave_number: int = 0
var enemies_alive: int = 0
var score: int = 0

var _point_values: Dictionary = {
	"brown": 10,
	"black": 20,
	"war": 50,
	"boss": 100
}

func _ready() -> void:
	call_deferred("start_next_wave")

func start_next_wave() -> void:
	wave_number += 1
	wave_started.emit(wave_number)
	AudioManager.play_wave_start_sfx()
	_spawn_wave_enemies()

func _spawn_wave_enemies() -> void:
	var composition = _get_wave_composition(wave_number)
	for enemy_type in composition:
		var enemy = _create_enemy(enemy_type)
		enemy.global_position = _get_spawn_position()
		enemy.connect("enemy_died", _on_enemy_died)
		get_parent().add_child(enemy)
		enemies_alive += 1
	enemies_alive_changed.emit(enemies_alive)

func _get_wave_composition(wave: int) -> Array:
	var result: Array = []
	
	# Wave 1: 3 brown
	if wave == 1:
		for i in range(3):
			result.append("brown")
	# Wave 2: 5 brown
	elif wave == 2:
		for i in range(5):
			result.append("brown")
	# Wave 3: 3 brown + 2 black
	elif wave == 3:
		for i in range(3):
			result.append("brown")
		for i in range(2):
			result.append("black")
	# Wave 4+: scaling browns (base 3 brown + 2 black, add browns as wave increases)
	elif wave >= 4:
		# Base composition: 3 brown + 2 black
		for i in range(3):
			result.append("brown")
		for i in range(2):
			result.append("black")
		# Additional browns scaling with wave (wave 4 = +1 brown, wave 5 = +2 brown, etc., capped)
		var extra_browns = mini(wave - 4, 5)  # Cap extra browns at 5
		for i in range(extra_browns):
			result.append("brown")
	
	# Boss waves: every 5 waves (5, 10, 15...)
	if wave % 5 == 0:
		result.append("boss")
		result.append("brown")  # Escort 1
		result.append("brown")  # Escort 2
	
	return result

func _create_enemy(type: String) -> EnemyBase:
	match type:
		"brown": return EnemyBrown.new()
		"black": return EnemyBlack.new()
		"war": return EnemyWar.new()
		"boss": return EnemyBoss.new()
		_: return EnemyBrown.new()

func _get_spawn_position() -> Vector2:
	var viewport_size = get_viewport_rect().size
	var edge = randi() % 4
	match edge:
		0: return Vector2(randi() % int(viewport_size.x), arena_margin)
		1: return Vector2(viewport_size.x - arena_margin, randi() % int(viewport_size.y))
		2: return Vector2(randi() % int(viewport_size.x), viewport_size.y - arena_margin)
		3: return Vector2(arena_margin, randi() % int(viewport_size.y))
	return Vector2.ZERO

func _on_enemy_died(enemy: EnemyBase) -> void:
	enemies_alive -= 1
	enemies_alive_changed.emit(enemies_alive)
	# Increment score based on enemy type
	score += _point_values.get(enemy.type, 10)
	score_changed.emit(score)
	if enemies_alive <= 0:
		start_next_wave()
