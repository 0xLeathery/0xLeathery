class_name SurvivalMeters
extends RefCounted

static func get_time_label(hour: float) -> String:
	var h := int(hour) % 24
	var minutes := int((hour - floor(hour)) * 60.0)
	var period := "AM" if h < 12 else "PM"
	var display_hour := h % 12
	if display_hour == 0:
		display_hour = 12
	return "%d:%02d %s" % [display_hour, minutes, period]


static func is_night(hour: float) -> bool:
	return hour < 6.0 or hour >= 19.0


static func get_light_color(hour: float) -> Color:
	if is_night(hour):
		return Color(0.15, 0.18, 0.35, 1.0)
	if hour < 8.0 or hour >= 17.0:
		return Color(1.0, 0.85, 0.65, 1.0)
	return Color(1.0, 1.0, 0.95, 1.0)


static func get_ambient_modulate(hour: float) -> Color:
	if is_night(hour):
		return Color(0.55, 0.6, 0.85, 1.0)
	if hour < 8.0 or hour >= 17.0:
		return Color(1.0, 0.92, 0.78, 1.0)
	return Color(1.0, 1.0, 1.0, 1.0)
