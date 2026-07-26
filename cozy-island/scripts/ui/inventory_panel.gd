extends Control

@onready var item_list: ItemList = %ItemList
@onready var use_button: Button = %UseButton


func _ready() -> void:
	visible = false
	use_button.pressed.connect(_on_use_pressed)
	EventBus.inventory_changed.connect(_refresh)
	_refresh()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		visible = not visible
		if visible:
			_refresh()


func _refresh() -> void:
	item_list.clear()
	for entry in ItemDatabase.get_inventory_entries():
		var line := "%s x%d" % [entry["name"], entry["amount"]]
		item_list.add_item(line)
		item_list.set_item_metadata(item_list.item_count - 1, entry["id"])


func _on_use_pressed() -> void:
	var selected := item_list.get_selected_items()
	if selected.is_empty():
		return
	var item_id = item_list.get_item_metadata(selected[0])
	var item := ItemDatabase.get_item(item_id)
	if item.is_empty():
		return
	if item.has("effects"):
		if GameState.remove_item(item_id, 1):
			GameState.apply_item_consumable(item_id)
			EventBus.game_message.emit("Used %s." % ItemDatabase.get_display_name(item_id))
			_refresh()
	else:
		EventBus.game_message.emit("%s cannot be used directly." % ItemDatabase.get_display_name(item_id))
