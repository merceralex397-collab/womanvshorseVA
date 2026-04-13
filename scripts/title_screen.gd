extends CanvasLayer

# Title screen script - shows "WOMAN vs HORSE" title and START button
# Visible in TITLE state, hidden when PLAYING starts

# Background color (dark for readability)
const BG_COLOR: Color = Color(0.0, 0.0, 0.0, 0.85)

# Title text
const TITLE_TEXT: String = "WOMAN vs HORSE"

# Node references
var background_rect: ColorRect
var title_label: Label
var start_button: Button

func _ready() -> void:
	# Create and configure all UI elements
	_setup_ui()

func _setup_ui() -> void:
	# Create dark background ColorRect covering full screen
	background_rect = ColorRect.new()
	background_rect.name = "Background"
	background_rect.color = BG_COLOR
	background_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background_rect)
	
	# Create centered title Label
	title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.text = TITLE_TEXT
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.set_anchors_preset(Control.PRESET_CENTER)
	title_label.offset_left = -300
	title_label.offset_right = 300
	title_label.offset_top = -100
	title_label.offset_bottom = 0
	# Use default font - no imported assets
	title_label.add_theme_font_size_override("font_size", 72)
	title_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	add_child(title_label)
	
	# Create START Button below title
	start_button = Button.new()
	start_button.name = "StartButton"
	start_button.text = "START"
	start_button.set_anchors_preset(Control.PRESET_CENTER)
	start_button.offset_left = -100
	start_button.offset_right = 100
	start_button.offset_top = 50
	start_button.offset_bottom = 120
	start_button.add_theme_font_size_override("font_size", 48)
	start_button.connect("pressed", Callable(self, "_on_start_pressed"))
	add_child(start_button)
	
	# Start visible
	show_title()

func _on_start_pressed() -> void:
	# Get parent (main) and call change_state to PLAYING
	var main = get_parent()
	if main and main.has_method("_change_state"):
		main._change_state(main.GameState.PLAYING)

func show_title() -> void:
	visible = true

func hide_title() -> void:
	visible = false