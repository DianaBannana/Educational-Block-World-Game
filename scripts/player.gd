extends CharacterBody3D

# Player movement script for Ethan
# Third-person perspective, Minecraft-style controls

@export var speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.003

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var camera_angle: float = 0.0
var animation_player: AnimationPlayer
var audio_player: AudioStreamPlayer3D

# Customization
var hair_color: String = "brown"
var clothes_color: String = "red"
var has_helmet: bool = false
var sword_unlocked: bool = false

func _ready():
	# Get animation player and audio player
	animation_player = $AnimationPlayer
	audio_player = $AudioStreamPlayer3D
	load_customization()

func _physics_process(delta):
	# Handle gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
		play_animation("jump")
		play_sound("footstep1")
	
	# Get input direction
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		play_animation("walk")
		play_footstep_sound()
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		play_animation("idle")
	
	# Handle attack
	if Input.is_action_just_pressed("attack") and sword_unlocked:
		play_animation("attack")
		play_sound("attack")
	
	move_and_slide()

func play_animation(anim_name: String):
	if animation_player and animation_player.has_animation(anim_name):
		animation_player.play(anim_name)

func play_sound(sound_name: String):
	var sound_path = "res://sounds/ethan/" + sound_name
	if ResourceLoader.exists(sound_path):
		var sound = load(sound_path)
		audio_player.stream = sound
		audio_player.play()

func play_footstep_sound():
	if randf() > 0.5:
		play_sound("footstep1")
	else:
		play_sound("footstep2")

func load_customization():
	# Load customization from save file or defaults
	var save_file = FileAccess.open("user://player_save.json", FileAccess.READ)
	if save_file:
		var json = JSON.new()
		json.parse(save_file.get_as_text())
		var data = json.get_data()
		hair_color = data.get("hair_color", "brown")
		clothes_color = data.get("clothes_color", "red")
		has_helmet = data.get("has_helmet", false)
		sword_unlocked = data.get("sword_unlocked", false)
		save_file.close()

func interact_with_object(object):
	play_animation("interact")
	# Interaction logic handled by object

