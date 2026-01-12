extends Area3D

# NPC interaction system for Pug, Brak, and Skibidi

@export var npc_id: String = ""
@export var dialogue_id: String = ""
@export var interaction_range: float = 2.0

var npc_data: Dictionary = {}
var player_in_range: bool = false
var animation_player: AnimationPlayer
var audio_player: AudioStreamPlayer3D

func _ready():
	load_npc_data()
	setup_animations()
	
	# Connect area signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func load_npc_data():
	var file = FileAccess.open("res://data/characters.json", FileAccess.READ)
	if file:
		var json = JSON.new()
		json.parse(file.get_as_text())
		var data = json.get_data()
		for char in data.get("characters", []):
			if char.get("id") == npc_id:
				npc_data = char
				break
		file.close()

func setup_animations():
	animation_player = $AnimationPlayer
	audio_player = $AudioStreamPlayer3D
	play_animation("idle")

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		show_interaction_prompt()

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		hide_interaction_prompt()

func _input(event):
	if player_in_range and event.is_action_pressed("interact"):
		interact()

func interact():
	match npc_id:
		"pug":
			interact_pug()
		"brak":
			interact_brak()
		"skibidi":
			interact_skibidi()

func interact_pug():
	play_dialogue("pug_greeting")
	play_animation("wag_tail")
	play_sound("happy")
	# Pug can help with puzzles
	if GameManager.current_puzzle:
		play_dialogue("pug_puzzle_help")

func interact_brak():
	play_dialogue("brak_greeting")
	play_animation("talk")
	play_sound("meow1")
	# Brak gives hints
	if GameManager.puzzle_failed:
		play_dialogue("brak_hint")
		GameManager.puzzle_failed = false

func interact_skibidi():
	play_dialogue("skibidi_encounter")
	play_animation("attack")
	play_sound("growl1")
	# Skibidi challenges player to puzzle
	var puzzle_id = "puzzle_" + str(randi() % 6 + 1)
	GameManager.start_puzzle(puzzle_id)

func play_animation(anim_name: String):
	if animation_player and animation_player.has_animation(anim_name):
		animation_player.play(anim_name)

func play_sound(sound_name: String):
	var sound_path = "res://sounds/" + npc_id + "/" + sound_name
	if ResourceLoader.exists(sound_path):
		var sound = load(sound_path)
		audio_player.stream = sound
		audio_player.play()

func play_dialogue(dialogue_id: String):
	GameManager.play_dialogue(dialogue_id)

func show_interaction_prompt():
	# Show "Press E to interact" prompt
	var prompt = get_node_or_null("InteractionPrompt")
	if prompt:
		prompt.show()

func hide_interaction_prompt():
	var prompt = get_node_or_null("InteractionPrompt")
	if prompt:
		prompt.hide()

func take_damage(amount: int):
	if npc_id == "skibidi":
		npc_data["health"] = npc_data.get("health", 3) - amount
		if npc_data["health"] <= 0:
			defeated()

func defeated():
	play_dialogue("skibidi_defeated")
	play_animation("idle")
	# Drop rewards
	GameManager.spawn_reward(global_position, "coin_medium")

