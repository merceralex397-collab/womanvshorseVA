class_name SFXPlayer
extends Node2D

# Lightweight helper node for triggering procedural SFX
# Usage: Add as child to any node that needs to play sounds
# Call play_sfx("attack"), play_sfx("hit"), etc.

func _ready() -> void:
	pass

func play_sfx(sfx_type: String) -> void:
	match sfx_type:
		"attack":
			AudioManager.play_attack_sfx()
		"hit":
			AudioManager.play_hit_sfx()
		"death":
			AudioManager.play_death_sfx()
		"player_hit":
			AudioManager.play_player_hit_sfx()
		"wave_start":
			AudioManager.play_wave_start_sfx()