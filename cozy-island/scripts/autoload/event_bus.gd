extends Node

signal inventory_changed
signal meters_changed
signal time_changed(hour: float, day: int)
signal recipe_discovered(recipe_id: String)
signal skill_gained(skill: String, level: int)
signal item_gathered(item_id: String, amount: int)
signal building_placed(building_id: String)
signal research_unlocked(research_id: String)
signal helper_assigned(helper_index: int, job_id: String)
signal production_completed(job_id: String, output_id: String, amount: int)
signal dialogue_requested(speaker: String, lines: PackedStringArray)
signal game_message(text: String)
signal relaxed_mode_changed(enabled: bool)
signal zone_discovered(zone_id: String)
