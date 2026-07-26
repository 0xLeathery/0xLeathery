extends Control

@onready var slot_buttons: Array[Button] = [
	%Slot0, %Slot1, %Slot2, %ToolSlot
]
@onready var result_label: Label = %ResultLabel
@onready var craft_button: Button = %CraftButton
@onready var clear_button: Button = %ClearButton
@onready var inventory_list: ItemList = %InventoryPicker
@onready var recipe_book_list: ItemList = %RecipeBookList

var _slot_values: Array = [null, null, null, null]
var _selected_slot: int = 0


func _ready() -> void:
	visible = false
	craft_button.pressed.connect(_on_craft_pressed)
	clear_button.pressed.connect(_on_clear_pressed)
	inventory_list.item_selected.connect(_on_inventory_selected)
	recipe_book_list.item_selected.connect(_on_recipe_selected)
	for i in range(slot_buttons.size()):
		slot_buttons[i].pressed.connect(_on_slot_pressed.bind(i))
	EventBus.inventory_changed.connect(_refresh_inventory_picker)
	EventBus.recipe_discovered.connect(_refresh_recipe_book)
	_refresh_inventory_picker()
	_refresh_recipe_book("")
	_update_slot_buttons()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_crafting"):
		visible = not visible
		if visible:
			_refresh_inventory_picker()
			_refresh_recipe_book("")


func _refresh_inventory_picker() -> void:
	inventory_list.clear()
	for entry in ItemDatabase.get_inventory_entries():
		var line := "%s x%d" % [entry["name"], entry["amount"]]
		inventory_list.add_item(line)
		inventory_list.set_item_metadata(inventory_list.item_count - 1, entry["id"])


func _refresh_recipe_book(_recipe_id: String) -> void:
	recipe_book_list.clear()
	for recipe in RecipeRegistry.get_known_recipes_for_book():
		var inputs: Array = recipe.get("inputs", [])
		var parts: PackedStringArray = []
		for slot in inputs:
			if slot == null:
				parts.append("—")
			else:
				parts.append(ItemDatabase.get_display_name(str(slot)))
		var tool := str(recipe.get("tool", ""))
		var tool_text := ItemDatabase.get_display_name(tool) if tool != "" else "No tool"
		var line := "%s -> %s (%s)" % [" + ".join(parts), ItemDatabase.get_display_name(str(recipe.get("output", ""))), tool_text]
		recipe_book_list.add_item(line)
		recipe_book_list.set_item_metadata(recipe_book_list.item_count - 1, recipe)


func _on_inventory_selected(index: int) -> void:
	var item_id = inventory_list.get_item_metadata(index)
	_slot_values[_selected_slot] = item_id
	_update_slot_buttons()


func _on_recipe_selected(index: int) -> void:
	var recipe: Dictionary = recipe_book_list.get_item_metadata(index)
	var inputs: Array = recipe.get("inputs", [])
	for i in range(3):
		_slot_values[i] = inputs[i] if i < inputs.size() else null
	_slot_values[3] = recipe.get("tool")
	_update_slot_buttons()


func _on_slot_pressed(index: int) -> void:
	_selected_slot = index
	EventBus.game_message.emit("Selected crafting slot %d." % index)


func _update_slot_buttons() -> void:
	for i in range(slot_buttons.size()):
		var value = _slot_values[i]
		if value == null or str(value) == "":
			slot_buttons[i].text = "Slot %d" % i if i < 3 else "Tool"
		else:
			slot_buttons[i].text = ItemDatabase.get_display_name(str(value))


func _on_clear_pressed() -> void:
	_slot_values = [null, null, null, null]
	_update_slot_buttons()
	result_label.text = ""


func _on_craft_pressed() -> void:
	var inputs := [_slot_values[0], _slot_values[1], _slot_values[2]]
	var tool := str(_slot_values[3]) if _slot_values[3] != null else ""
	var result := CraftingSystem.try_craft(inputs, tool)
	result_label.text = str(result.get("message", ""))
	if bool(result.get("success", false)):
		_slot_values = [null, null, null, null]
		_update_slot_buttons()
		_refresh_inventory_picker()
		_refresh_recipe_book(str(result.get("recipe_id", "")))
