extends CanvasLayer

@onready var hunger_bar: ProgressBar = %HungerBar
@onready var thirst_bar: ProgressBar = %ThirstBar
@onready var energy_bar: ProgressBar = %EnergyBar
@onready var time_label: Label = %TimeLabel
@onready var day_label: Label = %DayLabel
@onready var message_label: Label = %MessageLabel
@onready var zone_label: Label = %ZoneLabel
@onready var relaxed_toggle: CheckButton = %RelaxedToggle


func _ready() -> void:
	EventBus.meters_changed.connect(_refresh_meters)
	EventBus.time_changed.connect(_refresh_time)
	EventBus.game_message.connect(_show_message)
	EventBus.zone_discovered.connect(_on_zone_discovered)
	relaxed_toggle.toggled.connect(_on_relaxed_toggled)
	if has_node("Root/ControlsHint"):
		$Root/ControlsHint.visible = not MobileInput.enabled
	_configure_meter_colors()
	_refresh_meters()
	_refresh_time(GameState.time_of_day, GameState.day_count)
	var hint := "Explore the island. Use the joystick and buttons below."
	if not MobileInput.enabled:
		hint = "Welcome to Cozy Island. WASD to move, E to interact, C craft, I inventory, R research."
	message_label.text = hint
	get_viewport().size_changed.connect(_layout)
	call_deferred("_layout")


func _configure_meter_colors() -> void:
	_apply_bar_color(hunger_bar, UiTheme.COLORS.hunger)
	_apply_bar_color(thirst_bar, UiTheme.COLORS.thirst)
	_apply_bar_color(energy_bar, UiTheme.COLORS.energy)


func _apply_bar_color(bar: ProgressBar, color: Color) -> void:
	var fill := StyleBoxFlat.new()
	fill.bg_color = color
	fill.set_corner_radius_all(6)
	bar.add_theme_stylebox_override("fill", fill)


func _layout() -> void:
	var vp := get_viewport().get_visible_rect().size
	var compact := vp.x < 900.0 or MobileInput.enabled
	if has_node("Root/TopBar"):
		var top: Control = $Root/TopBar
		top.position = Vector2(12, 12)
		top.size = Vector2(minf(440, vp.x - 24), 108 if compact else 118)
	if has_node("Root/MessagePanel"):
		var msg: Control = $Root/MessagePanel
		var height := 52.0 if compact else 60.0
		msg.position = Vector2(12, vp.y - height - 12)
		msg.size = Vector2(vp.x - 24, height)
	if compact and has_node("Root/TopBar/VBox/InfoRow/ZoneLabel"):
		$Root/TopBar/VBox/InfoRow/ZoneLabel.visible = false


func _refresh_meters() -> void:
	hunger_bar.value = GameState.hunger
	thirst_bar.value = GameState.thirst
	energy_bar.value = GameState.energy


func _refresh_time(hour: float, day: int) -> void:
	time_label.text = SurvivalMeters.get_time_label(hour)
	day_label.text = "Day %d" % day


func _show_message(text: String) -> void:
	message_label.text = text


func _on_zone_discovered(zone_id: String) -> void:
	zone_label.text = "Discovered: %s" % zone_id.capitalize()


func _on_relaxed_toggled(enabled: bool) -> void:
	GameState.set_relaxed_mode(enabled)
	EventBus.game_message.emit("Relaxed mode %s." % ("enabled" if enabled else "disabled"))
