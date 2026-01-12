extends Node

# Main game manager for Stage 1: Ruined Zone After Skibidi Attack

signal coins_changed(new_amount)
signal diamonds_changed(new_amount)
signal health_changed(new_amount)
signal level_changed(new_level)

var player_health: int = 5
var player_coins: int = 0
var player_diamonds: int = 0
var current_level: int = 1
var building_tool_parts: Array = []
var current_puzzle: String = ""
var puzzle_failed: bool = false

signal building_tool_parts_changed(parts: Array)

var dialogues_data: Dictionary = {}
var rewards_data: Dictionary = {}
var building_tools_data: Dictionary = {}

func _ready():
	load_game_data()
	setup_ui()

func load_game_data():
	# Load dialogues
	var file = FileAccess.open("res://data/dialogues.json", FileAccess.READ)
	if file:
		var json = JSON.new()
		json.parse(file.get_as_text())
		dialogues_data = json.get_data()
		file.close()
	
	# Load rewards
	file = FileAccess.open("res://data/rewards.json", FileAccess.READ)
	if file:
		var json = JSON.new()
		json.parse(file.get_as_text())
		rewards_data = json.get_data()
		file.close()
	
	# Load building tools
	file = FileAccess.open("res://data/building_tools.json", FileAccess.READ)
	if file:
		var json = JSON.new()
		json.parse(file.get_as_text())
		building_tools_data = json.get_data()
		file.close()

func setup_ui():
	# Create floating UI panel (top-left)
	var ui_panel = preload("res://ui/game_ui.tscn").instantiate()
	get_tree().current_scene.add_child(ui_panel)
	ui_panel.update_health(player_health)
	ui_panel.update_coins(player_coins)
	ui_panel.update_level(current_level)

func add_coins(amount: int):
	player_coins += amount
	coins_changed.emit(player_coins)
	update_ui()

func add_diamonds(amount: int):
	player_diamonds += amount
	diamonds_changed.emit(player_diamonds)
	update_ui()

func add_health(amount: int):
	player_health = min(player_health + amount, 5)
	health_changed.emit(player_health)
	update_ui()

func take_damage(amount: int):
	player_health = max(player_health - amount, 0)
	health_changed.emit(player_health)
	update_ui()
	if player_health <= 0:
		game_over()

func add_building_tool_part(part_id: String):
	if part_id not in building_tool_parts:
		building_tool_parts.append(part_id)
		building_tool_parts_changed.emit(building_tool_parts)
		play_dialogue("building_tool_collected")
		check_portal_complete()

func check_portal_complete():
	if "building_tool_part_1" in building_tool_parts and "building_tool_part_2" in building_tool_parts:
		play_dialogue("portal_complete")
		# Enable portal to next stage
		enable_portal()

func enable_portal():
	var portal = get_tree().get_first_node_in_group("portal")
	if portal:
		portal.enable()

func start_puzzle(puzzle_id: String):
	current_puzzle = puzzle_id
	puzzle_failed = false
	var puzzle_system = get_node_or_null("/root/PuzzleSystem")
	if puzzle_system:
		puzzle_system.start_puzzle(puzzle_id)

func play_dialogue(dialogue_id: String):
	var dialogue = find_dialogue(dialogue_id)
	if dialogue:
		var dialogue_ui = preload("res://ui/dialogue_ui.tscn").instantiate()
		get_tree().current_scene.add_child(dialogue_ui)
		dialogue_ui.show_dialogue(dialogue)
		
		# Play voice file if available
		if dialogue.has("voice_file"):
			var voice_path = "res://sounds/voice/" + dialogue["voice_file"]
			if ResourceLoader.exists(voice_path):
				var voice = load(voice_path)
				var audio_player = AudioStreamPlayer.new()
				add_child(audio_player)
				audio_player.stream = voice
				audio_player.play()

func find_dialogue(dialogue_id: String) -> Dictionary:
	for dialogue in dialogues_data.get("dialogues", []):
		if dialogue.get("id") == dialogue_id:
			return dialogue
	return {}

func spawn_reward(position: Vector3, reward_id: String):
	var reward_scene = preload("res://objects/reward_item.tscn").instantiate()
	get_tree().current_scene.add_child(reward_scene)
	reward_scene.global_position = position
	reward_scene.setup_reward(reward_id)

func update_ui():
	var ui_panel = get_tree().get_first_node_in_group("game_ui")
	if ui_panel:
		ui_panel.update_health(player_health)
		ui_panel.update_coins(player_coins)
		ui_panel.update_diamonds(player_diamonds)
		ui_panel.update_level(current_level)

func game_over():
	# Show game over screen
	var game_over_ui = preload("res://ui/game_over_ui.tscn").instantiate()
	get_tree().current_scene.add_child(game_over_ui)

# Singleton access
static func get_manager() -> Node:
	return Engine.get_main_loop().root.get_node_or_null("/root/GameManager")

