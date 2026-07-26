extends Node

var _items: Dictionary = {}


func _ready() -> void:
	_load_items()


func _load_items() -> void:
	var file := FileAccess.open("res://data/items/items.json", FileAccess.READ)
	if file == null:
		push_error("Failed to load items.json")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("items.json must be a dictionary")
		return
	_items = parsed


func get_item(item_id: String) -> Dictionary:
	return _items.get(item_id, {}).duplicate()


func get_all_items() -> Dictionary:
	return _items.duplicate(true)


func get_items_by_tag(tag: String) -> Array[String]:
	var result: Array[String] = []
	for item_id in _items.keys():
		var tags: Array = _items[item_id].get("tags", [])
		if tag in tags:
			result.append(item_id)
	return result


func is_tool(item_id: String) -> bool:
	return bool(_items.get(item_id, {}).get("is_tool", false))


func get_display_name(item_id: String) -> String:
	return str(_items.get(item_id, {}).get("name", item_id.capitalize()))


func get_color(item_id: String) -> Color:
	var hex := str(_items.get(item_id, {}).get("color", "#FFFFFF"))
	return Color.html(hex)


func get_icon(item_id: String) -> Texture2D:
	var path := "res://assets/sprites/items/%s.png" % item_id
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null


func get_inventory_entries() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for item_id in GameState.inventory.keys():
		entries.append({
			"id": item_id,
			"amount": int(GameState.inventory[item_id]),
			"name": get_display_name(item_id),
			"color": get_color(item_id),
			"is_tool": is_tool(item_id),
			"icon": get_icon(item_id),
		})
	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return str(a["name"]) < str(b["name"])
	)
	return entries
