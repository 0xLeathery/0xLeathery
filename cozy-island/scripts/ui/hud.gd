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
	_refresh_meters()
	_refresh_time(GameState.time_of_day, GameState.day_count)
	message_label.text = "Welcome to Cozy Island. WASD to move, E to interact, C craft, I inventory, R research."


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
