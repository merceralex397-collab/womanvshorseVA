extends Node2D

# Game state enumeration
enum GameState { TITLE, PLAYING, GAME_OVER }

# Current game state
var current_state: GameState = GameState.TITLE

# Arena border settings
const ARENA_INSET: int = 45
const BORDER_THICKNESS: int = 3
const BORDER_COLOR: Color = Color(1.0, 1.0, 1.0, 1.0)  # White
const BACKGROUND_COLOR: Color = Color(0.05, 0.05, 0.1, 1.0)  # Dark blue-black

func _ready() -> void:
	# Initial state is TITLE
	_change_state(GameState.TITLE)

func _change_state(new_state: GameState) -> void:
	current_state = new_state
	# State change logic will be expanded in later tickets
	# For now, just update the state
	match new_state:
		GameState.TITLE:
			_show_title_screen()
		GameState.PLAYING:
			_hide_title_screen()
			_spawn_player_and_joystick()
			_setup_hud()
		GameState.GAME_OVER:
			_trigger_game_over()
			_show_game_over_screen()
	queue_redraw()

func _show_title_screen() -> void:
	var title_screen = get_node_or_null("TitleScreen")
	if title_screen and title_screen.has_method("show_title"):
		title_screen.show_title()

func _hide_title_screen() -> void:
	var title_screen = get_node_or_null("TitleScreen")
	if title_screen and title_screen.has_method("hide_title"):
		title_screen.hide_title()

func _show_game_over_screen() -> void:
	var game_over_screen = get_node_or_null("GameOverScreen")
	if game_over_screen and game_over_screen.has_method("show_game_over"):
		var wave_spawner = get_node_or_null("WaveSpawner")
		var final_score = wave_spawner.score if wave_spawner else 0
		game_over_screen.show_game_over(final_score)
		# Connect restart signal
		if not game_over_screen.restart_pressed.is_connected(Callable(self, "restart_game")):
			game_over_screen.restart_pressed.connect(Callable(self, "restart_game"))

func _hide_game_over_screen() -> void:
	var game_over_screen = get_node_or_null("GameOverScreen")
	if game_over_screen and game_over_screen.has_method("hide_game_over"):
		game_over_screen.hide_game_over()

func _trigger_game_over() -> void:
	# Stop wave spawner (plan review recommendation: freeze wave spawner)
	var wave_spawner = get_node_or_null("WaveSpawner")
	if wave_spawner:
		wave_spawner.set_physics_process(false)
		wave_spawner.set_process(false)
	
	# Freeze player (plan review recommendation: freeze player)
	var player = get_node_or_null("Player")
	if player:
		player.set_physics_process(false)
		player.set_process(false)

func _reset_game() -> void:
	# Clear all enemies from arena
	_clear_enemies()
	
	# Clear any existing player and joystick
	if has_node("Player"):
		$Player.queue_free()
	if has_node("VirtualJoystick"):
		$VirtualJoystick.queue_free()
	
	# Clear HUD
	if has_node("HUD"):
		$HUD.queue_free()
	
	# Reset wave spawner state
	var wave_spawner = get_node_or_null("WaveSpawner")
	if wave_spawner:
		wave_spawner.score = 0
		wave_spawner.wave_number = 0
		wave_spawner.enemies_alive = 0
		wave_spawner.set_physics_process(true)
		wave_spawner.set_process(true)

func _clear_enemies() -> void:
	# Remove all enemies from scene by type name
	var children = get_children()
	for child in children:
		if "Enemy" in child.name:
			child.queue_free()

func restart_game() -> void:
	_reset_game()
	_hide_game_over_screen()
	_change_state(GameState.TITLE)

func _on_player_died() -> void:
	_change_state(GameState.GAME_OVER)

func _spawn_player_and_joystick() -> void:
	# Remove any existing player/joystick first (for restart scenario)
	if has_node("Player"):
		$Player.queue_free()
	if has_node("VirtualJoystick"):
		$VirtualJoystick.queue_free()
	
	# Create and add VirtualJoystick
	var joystick = Node2D.new()
	joystick.set_script(load("res://scripts/virtual_joystick.gd"))
	joystick.name = "VirtualJoystick"
	add_child(joystick)
	
	# Create and add Player
	var player = CharacterBody2D.new()
	player.set_script(load("res://scripts/player.gd"))
	player.name = "Player"
	add_child(player)
	
	# Connect player_died signal to trigger GAME_OVER (plan review recommendation)
	player.connect("player_died", Callable(self, "_on_player_died"))

func _setup_hud() -> void:
	# Remove any existing HUD
	if has_node("HUD"):
		$HUD.queue_free()
	
	# Create and add HUD
	var hud = CanvasLayer.new()
	hud.set_script(load("res://scripts/hud.gd"))
	hud.name = "HUD"
	add_child(hud)
	
	# Connect HUD to player health signal
	var player = get_node_or_null("Player")
	var wave_spawner = get_node_or_null("WaveSpawner")
	var hud_script = hud.get_script()
	
	if player and player.has_signal("health_changed"):
		player.connect("health_changed", Callable(hud_script, "update_health"))
	
	if wave_spawner:
		if wave_spawner.has_signal("wave_started"):
			wave_spawner.connect("wave_started", Callable(hud_script, "update_wave"))
		if wave_spawner.has_signal("score_changed"):
			wave_spawner.connect("score_changed", Callable(hud_script, "update_score"))

func _draw() -> void:
	# Draw dark background
	var viewport_size = get_viewport_rect().size
	var background_rect = Rect2(Vector2.ZERO, viewport_size)
	draw_rect(background_rect, BACKGROUND_COLOR)
	
	# Draw arena border as a white rectangle outline inset from viewport edges
	var border_rect = Rect2(
		Vector2(ARENA_INSET, ARENA_INSET),
		Vector2(viewport_size.x - (ARENA_INSET * 2), viewport_size.y - (ARENA_INSET * 2))
	)
	
	# Draw the border using multiple rects for thickness (since Godot's draw_rect has no thickness param)
	for i in range(BORDER_THICKNESS):
		var inset = ARENA_INSET + i
		var inset_rect = Rect2(
			Vector2(inset, inset),
			Vector2(viewport_size.x - (inset * 2), viewport_size.y - (inset * 2))
		)
		draw_rect(inset_rect, BORDER_COLOR, false)
