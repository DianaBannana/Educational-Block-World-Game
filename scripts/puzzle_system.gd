extends Node

# Puzzle system for handling educational puzzles
# Supports picture-word matching and multiple-choice questions

signal puzzle_completed(puzzle_id, correct: bool)
signal reward_given(reward_data)

var puzzles_data: Dictionary = {}
var current_puzzle: Dictionary = {}
var puzzles_ui: Control

func _ready():
	load_puzzles()

func load_puzzles():
	var file = FileAccess.open("res://data/puzzles.json", FileAccess.READ)
	if file:
		var json = JSON.new()
		json.parse(file.get_as_text())
		var data = json.get_data()
		puzzles_data = data
		file.close()

func start_puzzle(puzzle_id: String):
	var puzzles = puzzles_data.get("puzzles", [])
	for puzzle in puzzles:
		if puzzle.get("id") == puzzle_id:
			current_puzzle = puzzle
			show_puzzle_ui()
			play_voice_prompt()
			return

func show_puzzle_ui():
	# Create or show puzzle UI
	if not puzzles_ui:
		puzzles_ui = preload("res://ui/puzzle_ui.tscn").instantiate()
		get_tree().current_scene.add_child(puzzles_ui)
	
	puzzles_ui.show()
	puzzles_ui.setup_puzzle(current_puzzle)

func play_voice_prompt():
	# Play voice prompt for non-readers
	# First try audio file, fallback to text-to-speech or text display
	var voice_path = "res://sounds/voice/" + current_puzzle.get("id", "") + "_prompt.wav"
	if ResourceLoader.exists(voice_path):
		var voice = load(voice_path)
		var audio_player = AudioStreamPlayer.new()
		add_child(audio_player)
		audio_player.stream = voice
		audio_player.play()
		await audio_player.finished
		audio_player.queue_free()
	else:
		# Fallback: Use voice_prompt text field (can be used with TTS)
		var prompt_text = current_puzzle.get("voice_prompt", "")
		if prompt_text != "":
			# Display text or use TTS system here
			print("Voice prompt: ", prompt_text)

func submit_answer(selected_index: int):
	var correct = selected_index == current_puzzle.get("correct_answer", -1)
	
	if correct:
		handle_correct_answer()
	else:
		handle_wrong_answer()
	
	puzzle_completed.emit(current_puzzle.get("id", ""), correct)

func handle_correct_answer():
	# Give rewards
	var reward = current_puzzle.get("reward", {})
	give_reward(reward)
	
	# Damage enemy if applicable
	var enemy_target = current_puzzle.get("enemy_target", "")
	if enemy_target:
		damage_enemy(enemy_target, current_puzzle.get("damage", 1))
	
	# Play success sound
	play_dialogue("puzzle_correct")
	
	# Hide UI
	if puzzles_ui:
		puzzles_ui.hide()

func handle_wrong_answer():
	# Show hint from Brak
	play_dialogue("puzzle_wrong")
	play_dialogue("brak_hint")
	
	# Show hint text
	if puzzles_ui:
		puzzles_ui.show_hint(current_puzzle.get("hint", ""))

func give_reward(reward_data: Dictionary):
	# Add coins
	if reward_data.has("coins"):
		GameManager.add_coins(reward_data["coins"])
	
	# Add diamonds
	if reward_data.has("diamonds"):
		GameManager.add_diamonds(reward_data["diamonds"])
	
	# Add building tool part
	if reward_data.has("building_tool_part"):
		GameManager.add_building_tool_part(reward_data["building_tool_part"])
	
	reward_given.emit(reward_data)

func damage_enemy(enemy_id: String, damage: int):
	var enemy = get_tree().get_first_node_in_group("enemies")
	if enemy and enemy.has_method("take_damage"):
		enemy.take_damage(damage)

func play_dialogue(dialogue_id: String):
	GameManager.play_dialogue(dialogue_id)

