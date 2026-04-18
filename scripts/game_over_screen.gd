extends CanvasLayer

# Game Over screen script - shows "GAME OVER" text, final score, and RESTART button
# Visible in GAME_OVER state, hidden when restarting or in other states

# Background color (dark for readability)
const BG_COLOR: Color = Color(0.0, 0.0, 0.0, 0.85)

# Title text
const GAME_OVER_TEXT: String = "GAME OVER"

# Node references
var background_rect: ColorRect
var title_label: Label
var score_label: Label
var restart_button: Button

# Signal emitted when RESTART button is pressed
signal restart_pressed

func _ready() -> void:
	# Create and configure all UI elements
	_setup_ui()
	# Start hidden
	hide_game_over()

func _setup_ui() -> void:
	# Create dark background ColorRect covering full screen
	background_rect = ColorRect.new()
	background_rect.name = "Background"
	background_rect.color = BG_COLOR
	background_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background_rect)
	
	# Create centered "GAME OVER" Label
	title_label = Label.new()
	title_label.name = "GameOverLabel"
	title_label.text = GAME_OVER_TEXT
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.set_anchors_preset(Control.PRESET_CENTER)
	title_label.offset_left = -300
	title_label.offset_right = 300
	title_label.offset_top = -150
	title_label.offset_bottom = -50
	# Use default font - no imported assets
	title_label.add_theme_font_size_override("font_size", 72)
	title_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	add_child(title_label)
	
	# Create score Label below title
	score_label = Label.new()
	score_label.name = "ScoreLabel"
	score_label.text = "Score: 0"
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	score_label.set_anchors_preset(Control.PRESET_CENTER)
	score_label.offset_left = -200
	score_label.offset_right = 200
	score_label.offset_top = -20
	score_label.offset_bottom = 30
	# Use medium font size
	score_label.add_theme_font_size_override("font_size", 32)
	score_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	add_child(score_label)
	
	# Create RESTART Button below score
	restart_button = Button.new()
	restart_button.name = "RestartButton"
	restart_button.text = "RESTART"
	restart_button.set_anchors_preset(Control.PRESET_CENTER)
	restart_button.offset_left = -100
	restart_button.offset_right = 100
	restart_button.offset_top = 60
	restart_button.offset_bottom = 130
	restart_button.add_theme_font_size_override("font_size", 48)
	restart_button.connect("pressed", Callable(self, "_on_restart_pressed"))
	add_child(restart_button)
	
	# Create decorative separator line between score and button
	var separator = ColorRect.new()
	separator.name = "Separator"
	separator.color = Color(1.0, 1.0, 1.0, 0.3)
	separator.set_anchors_preset(Control.PRESET_CENTER)
	separator.offset_left = -200
	separator.offset_right = 200
	separator.offset_top = 47
	separator.offset_bottom = 51
	add_child(separator)

func _on_restart_pressed() -> void:
	restart_pressed.emit()

func show_game_over(final_score: int) -> void:
	score_label.text = "Score: %d" % final_score
	visible = true

func hide_game_over() -> void:
	visible = false
