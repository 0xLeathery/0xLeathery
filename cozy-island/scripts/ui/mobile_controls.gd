extends CanvasLayer

const JOYSTICK_RADIUS := 72.0
const KNOB_RADIUS := 28.0

@onready var joystick_zone: Control = $JoystickZone
@onready var joystick_base: Panel = $JoystickZone/JoystickBase
@onready var joystick_knob: Panel = $JoystickZone/JoystickKnob

var _active_touch_id: int = -1
var _joystick_center: Vector2 = Vector2.ZERO


func _ready() -> void:
	visible = MobileInput.enabled
	if not visible:
		return
	joystick_zone.gui_input.connect(_on_joystick_gui_input)
	_reset_knob()


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
	if offset.length() > JOYSTICK_RADIUS:
		offset = offset.normalized() * JOYSTICK_RADIUS
	joystick_knob.global_position = _joystick_center + offset - Vector2(KNOB_RADIUS, KNOB_RADIUS)
	var direction := offset / JOYSTICK_RADIUS
	if direction.length_squared() > 1.0:
		direction = direction.normalized()
	MobileInput.set_move_vector(direction)


func _reset_knob() -> void:
	joystick_knob.global_position = _joystick_center - Vector2(KNOB_RADIUS, KNOB_RADIUS)
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
