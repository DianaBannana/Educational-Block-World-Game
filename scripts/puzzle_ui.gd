extends Control

# Puzzle UI for displaying and handling puzzles

@onready var question_label: Label = $VBoxContainer/QuestionLabel
@onready var picture_texture: TextureRect = $VBoxContainer/PictureTexture
@onready var options_container: VBoxContainer = $VBoxContainer/OptionsContainer
@onready var hint_label: Label = $VBoxContainer/HintLabel

var current_puzzle: Dictionary = {}
var puzzle_system: Node

func _ready():
	puzzle_system = get_node_or_null("/root/PuzzleSystem")
	if puzzle_system:
		puzzle_system.puzzle_completed.connect(_on_puzzle_completed)
	
	hide()

func setup_puzzle(puzzle: Dictionary):
	current_puzzle = puzzle
	show()
	
	# Set question
	question_label.text = puzzle.get("question", "")
	
	# Load picture if available
	if puzzle.has("picture") and puzzle["picture"] != "":
		var picture_path = "res://images/puzzles/" + puzzle["picture"]
		if ResourceLoader.exists(picture_path):
			var texture = load(picture_path)
			picture_texture.texture = texture
			picture_texture.show()
		else:
			picture_texture.hide()
	else:
		picture_texture.hide()
	
	# Create option buttons
	clear_options()
	var options = puzzle.get("options", [])
	for i in range(options.size()):
		var button = Button.new()
		button.text = options[i]
		button.pressed.connect(func(): select_option(i))
		options_container.add_child(button)
	
	hint_label.hide()

func clear_options():
	for child in options_container.get_children():
		child.queue_free()

func select_option(index: int):
	if puzzle_system:
		puzzle_system.submit_answer(index)

func show_hint(hint_text: String):
	hint_label.text = hint_text
	hint_label.show()

func _on_puzzle_completed(puzzle_id: String, correct: bool):
	if correct:
		hide()
		hint_label.hide()

