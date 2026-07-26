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
	return get_ambient_modulate(hour)


static func get_ambient_modulate(hour: float) -> Color:
	## Smooth day/night grade keyed to in-game hour.
	var h := fposmod(hour, 24.0)
	var night := Color(0.48, 0.52, 0.78, 1.0)
	var dawn := Color(1.0, 0.78, 0.62, 1.0)
	var day := Color(1.0, 1.0, 0.98, 1.0)
	var golden := Color(1.0, 0.88, 0.68, 1.0)
	var dusk := Color(0.82, 0.62, 0.78, 1.0)

	if h < 5.0:
		return night
	if h < 6.5:
		return night.lerp(dawn, _smooth((h - 5.0) / 1.5))
	if h < 8.0:
		return dawn.lerp(day, _smooth((h - 6.5) / 1.5))
	if h < 16.5:
		return day
	if h < 18.0:
		return day.lerp(golden, _smooth((h - 16.5) / 1.5))
	if h < 19.5:
		return golden.lerp(dusk, _smooth((h - 18.0) / 1.5))
	if h < 21.0:
		return dusk.lerp(night, _smooth((h - 19.5) / 1.5))
	return night


static func _smooth(t: float) -> float:
	t = clampf(t, 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)
