extends CanvasLayer

const JOYSTICK_RADIUS := 68.0
const KNOB_RADIUS := 26.0

@onready var joystick_zone: Control = $JoystickZone
@onready var joystick_base: Panel = $JoystickZone/JoystickBase
@onready var joystick_knob: Panel = $JoystickZone/JoystickKnob
@onready var action_buttons: HBoxContainer = $ActionButtons

var _active_touch_id: int = -1
var _joystick_center: Vector2 = Vector2.ZERO


func _ready() -> void:
	visible = MobileInput.enabled
	if not visible:
		return
	joystick_zone.gui_input.connect(_on_joystick_gui_input)
	_style_controls()
	get_viewport().size_changed.connect(_layout_controls)
	call_deferred("_layout_controls")
	call_deferred("_reset_knob")


func _style_controls() -> void:
	var labels := ["Gather", "Craft", "Items", "Research", "Sleep"]
	var i := 0
	for child in action_buttons.get_children():
		if child is Button:
			child.text = labels[i] if i < labels.size() else child.text
			child.custom_minimum_size = Vector2(78, 78)
			i += 1
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.12, 0.1, 0.08, 0.5)
	panel_style.set_corner_radius_all(999)
	panel_style.set_border_width_all(2)
	panel_style.border_color = Color(0.95, 0.82, 0.55, 0.45)
	joystick_base.add_theme_stylebox_override("panel", panel_style)
	var knob_style := panel_style.duplicate()
	knob_style.bg_color = Color(0.95, 0.82, 0.55, 0.85)
	joystick_knob.add_theme_stylebox_override("panel", knob_style)


func _layout_controls() -> void:
	var vp := get_viewport_rect().size
	var pad := 14.0
	var zone_size := minf(180.0, vp.y * 0.34)
	joystick_zone.position = Vector2(pad, vp.y - zone_size - pad)
	joystick_zone.size = Vector2(zone_size, zone_size)
	joystick_base.position = Vector2(8, 8)
	joystick_base.size = Vector2(zone_size - 16, zone_size - 16)
	var knob_size := zone_size * 0.36
	joystick_knob.size = Vector2(knob_size, knob_size)
	action_buttons.position = Vector2(vp.x - minf(420, vp.x - 24) - pad, vp.y - zone_size - pad)
	action_buttons.size = Vector2(minf(420, vp.x - zone_size - pad * 3), zone_size)


func _process(_delta: float) -> void:
	if not visible:
		return
	_joystick_center = joystick_base.global_position + joystick_base.size * 0.5


func _on_joystick_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed and _active_touch_id == -1:
			_active_touch_id = touch.index
			_update_joystick(touch.position)
		elif not touch.pressed and touch.index == _active_touch_id:
			_active_touch_id = -1
			_reset_knob()
	elif event is InputEventScreenDrag and event.index == _active_touch_id:
		_update_joystick(event.position)


func _update_joystick(touch_position: Vector2) -> void:
	var offset := touch_position - _joystick_center
	var radius := joystick_base.size.x * 0.42
	if offset.length() > radius:
		offset = offset.normalized() * radius
	var knob_size := joystick_knob.size
	joystick_knob.global_position = _joystick_center + offset - knob_size * 0.5
	var direction := offset / radius if radius > 0 else Vector2.ZERO
	MobileInput.set_move_vector(direction)


func _reset_knob() -> void:
	var knob_size := joystick_knob.size
	joystick_knob.global_position = _joystick_center - knob_size * 0.5
	MobileInput.clear_move_vector()


func _on_interact_pressed() -> void:
	MobileInput.press_action("interact")


func _on_craft_pressed() -> void:
	MobileInput.press_action("toggle_crafting")


func _on_inventory_pressed() -> void:
	MobileInput.press_action("toggle_inventory")


func _on_research_pressed() -> void:
	MobileInput.press_action("toggle_research")


func _on_sleep_pressed() -> void:
	MobileInput.press_action("sleep")
