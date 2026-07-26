extends Control

@onready var research_list: ItemList = %ResearchList
@onready var detail_label: Label = %DetailLabel
@onready var unlock_button: Button = %UnlockButton
@onready var helper_option: OptionButton = %HelperOption
@onready var job_option: OptionButton = %JobOption
@onready var assign_button: Button = %AssignButton
@onready var helper_status: Label = %HelperStatus

var _selected_research_id: String = ""


func _ready() -> void:
	visible = false
	unlock_button.pressed.connect(_on_unlock_pressed)
	assign_button.pressed.connect(_on_assign_pressed)
	research_list.item_selected.connect(_on_research_selected)
	EventBus.research_unlocked.connect(_refresh_research)
	EventBus.helper_assigned.connect(func(_i, _j): _refresh_helpers())
	EventBus.building_placed.connect(func(_b): _refresh_helpers())
	_refresh_research("")
	_refresh_helpers()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_research"):
		visible = not visible
		if visible:
			_refresh_research("")
			_refresh_helpers()


func _refresh_research(_id: String) -> void:
	research_list.clear()
	for node in ResearchRegistry.get_all_nodes():
		var research_id := str(node["id"])
		var prefix := "[x] " if research_id in GameState.unlocked_research else "[ ] "
		if ResearchRegistry.can_unlock(research_id):
			prefix = "[+] "
		research_list.add_item(prefix + str(node.get("name", research_id)))
		research_list.set_item_metadata(research_list.item_count - 1, node)


func _on_research_selected(index: int) -> void:
	var node: Dictionary = research_list.get_item_metadata(index)
	_selected_research_id = str(node.get("id", ""))
	var cost_lines: PackedStringArray = []
	for item_id in node.get("cost", {}).keys():
		cost_lines.append("%s x%d" % [ItemDatabase.get_display_name(str(item_id)), int(node["cost"][item_id])])
	detail_label.text = "%s\n\n%s\n\nCost: %s" % [
		node.get("name", ""),
		node.get("description", ""),
		", ".join(cost_lines),
	]


func _on_unlock_pressed() -> void:
	if _selected_research_id == "":
		return
	var result := AutomationSystem.try_unlock_research(_selected_research_id)
	EventBus.game_message.emit(str(result.get("message", "")))
	_refresh_research(_selected_research_id)


func _refresh_helpers() -> void:
	helper_option.clear()
	job_option.clear()
	for i in range(GameState.helpers.size()):
		helper_option.add_item(str(GameState.helpers[i].get("name", "Helper %d" % i)))
	for job in ResearchRegistry.get_available_helper_jobs():
		job_option.add_item(str(job.get("name", job.get("id", "Job"))))
		job_option.set_item_metadata(job_option.item_count - 1, job.get("id"))

	if not GameState.camp_buildings.get("workshop", false):
		helper_status.text = "Build a workshop to assign helpers."
		return

	var status_lines: PackedStringArray = []
	for helper in GameState.helpers:
		var job_name := "Idle"
		if str(helper.get("job", "")) != "":
			var job := ResearchRegistry.get_helper_job(str(helper["job"]))
			job_name = str(job.get("name", helper["job"]))
		status_lines.append("%s: %s" % [helper.get("name", "Helper"), job_name])
	helper_status.text = "\n".join(status_lines)


func _on_assign_pressed() -> void:
	if not GameState.camp_buildings.get("workshop", false):
		EventBus.game_message.emit("Build a workshop first.")
		return
	if helper_option.item_count == 0 or job_option.item_count == 0:
		return
	var helper_index := helper_option.selected
	var job_id = job_option.get_item_metadata(job_option.selected)
	GameState.assign_helper(helper_index, str(job_id))
	EventBus.game_message.emit("Assigned %s to %s." % [
		GameState.helpers[helper_index].get("name", "Helper"),
		ResearchRegistry.get_helper_job(str(job_id)).get("name", job_id),
	])
	_refresh_helpers()
