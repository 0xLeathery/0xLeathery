class_name ModalLayout
extends RefCounted

static func layout_panel(root: Control, panel: Control, backdrop: ColorRect, max_size: Vector2, margin: float = 16.0) -> void:
	var vp := root.get_viewport_rect().size
	if backdrop:
		backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
		backdrop.size = vp
	var width := minf(max_size.x, vp.x - margin * 2.0)
	var height := minf(max_size.y, vp.y - margin * 2.0)
	panel.custom_minimum_size = Vector2(width, height)
	panel.size = Vector2(width, height)
	panel.position = (vp - panel.size) * 0.5
