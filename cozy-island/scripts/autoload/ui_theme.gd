extends Node

## Applies a shared cozy theme and base font sizing for web/mobile.

const BASE_FONT_SIZE := 18
const COLORS := {
	"bg_dark": Color("#2C2416"),
	"bg_panel": Color("#3D3224"),
	"bg_panel_light": Color("#4A3F30"),
	"accent": Color("#E9A66C"),
	"accent_soft": Color("#F4D3A1"),
	"text": Color("#FFF8EE"),
	"text_dim": Color("#D4C4A8"),
	"success": Color("#7CB342"),
	"water": Color("#5DADE2"),
	"hunger": Color("#E67E22"),
	"thirst": Color("#3498DB"),
	"energy": Color("#F1C40F"),
}


func _ready() -> void:
	get_tree().root.theme = build_theme()
	get_viewport().size_changed.connect(_on_viewport_resized)
	_on_viewport_resized()


func build_theme() -> Theme:
	var theme := Theme.new()
	var font_size := _scaled_font_size()

	theme.set_font_size("font_size", "Label", font_size)
	theme.set_font_size("font_size", "Button", font_size)
	theme.set_color("font_color", "Label", COLORS.text)
	theme.set_color("font_color", "Button", COLORS.text)
	theme.set_color("font_color", "CheckButton", COLORS.text)
	theme.set_color("font_color", "ItemList", COLORS.text)
	theme.set_color("font_color", "OptionButton", COLORS.text)

	var panel := _make_panel_style(COLORS.bg_panel, 12)
	var panel_light := _make_panel_style(COLORS.bg_panel_light, 10)
	var button := _make_button_style(COLORS.bg_panel_light, COLORS.accent)
	var button_hover := _make_button_style(COLORS.accent_soft, COLORS.accent, true)
	var joystick := _make_panel_style(Color(0.15, 0.12, 0.1, 0.45), 999)

	theme.set_stylebox("panel", "PanelContainer", panel)
	theme.set_stylebox("panel", "Panel", panel_light)
	theme.set_stylebox("normal", "Button", button)
	theme.set_stylebox("hover", "Button", button_hover)
	theme.set_stylebox("pressed", "Button", button)
	theme.set_stylebox("focus", "Button", button_hover)
	theme.set_stylebox("panel", "ProgressBar", _make_panel_style(COLORS.bg_dark, 6))

	var progress_fill := StyleBoxFlat.new()
	progress_fill.bg_color = COLORS.accent
	progress_fill.set_corner_radius_all(6)
	theme.set_stylebox("fill", "ProgressBar", progress_fill)

	# Store joystick style for mobile controls
	theme.set_meta("joystick_panel", joystick)
	return theme


func get_joystick_style() -> StyleBoxFlat:
	return build_theme().get_meta("joystick_panel") as StyleBoxFlat


func _scaled_font_size() -> int:
	var shortest := minf(get_viewport().get_visible_rect().size.x, get_viewport().get_visible_rect().size.y)
	if shortest <= 0:
		return BASE_FONT_SIZE
	return clampi(int(BASE_FONT_SIZE * (shortest / 480.0)), 14, 24)


func _on_viewport_resized() -> void:
	var theme := build_theme()
	get_tree().root.theme = theme


func _make_panel_style(color: Color, radius: int) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.set_corner_radius_all(radius)
	box.border_color = COLORS.accent_soft.darkened(0.35)
	box.set_border_width_all(2)
	box.content_margin_left = 12
	box.content_margin_top = 10
	box.content_margin_right = 12
	box.content_margin_bottom = 10
	return box


func _make_button_style(bg: Color, border: Color, bright: bool = false) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = bg if not bright else bg.lightened(0.08)
	box.set_corner_radius_all(10)
	box.border_color = border
	box.set_border_width_all(2)
	box.content_margin_left = 14
	box.content_margin_top = 10
	box.content_margin_right = 14
	box.content_margin_bottom = 10
	return box
