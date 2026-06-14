class_name Player
extends CharacterBody2D

@export var multiplayer_position: Vector2 = Vector2.ZERO 
@export var multiplayer_input: Vector2 = Vector2.ZERO 

@onready var username_label: Label = $UsernameLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var user: UserData
var user_id = -1
var is_authority = false

var acceleration = 50.0
var max_speed = 500.0

const colors = {
	0: "green",
	1: "pink",
	2: "purple",
	3: "yellow"
}

func _enter_tree() -> void:
	is_authority = Online.is_user_local(user_id)
	set_multiplayer_authority(Online.get_user_multiplayer_id(user_id))
	user = Online.get_user(user_id)


func _ready() -> void:
	if user:
		username_label.text = user.username
		
		if colors.has(user.skin):
			set_skin(colors[user.skin])


func set_skin(skin: String) -> void:
	sprite.sprite_frames = sprite.sprite_frames.duplicate()
	
	for anim in sprite.sprite_frames.get_animation_names():
		for i in range(sprite.sprite_frames.get_frame_count(anim)):
			var old_texture = sprite.sprite_frames.get_frame_texture(anim, i)
			
			if old_texture and old_texture.resource_path != "":
				var old_path = old_texture.resource_path
				var new_path = old_path.replace("green", skin)
				
				if ResourceLoader.exists(new_path):
					var new_texture = load(new_path)
					var duration = sprite.sprite_frames.get_frame_duration(anim, i)
					sprite.sprite_frames.set_frame(anim, i, new_texture, duration)
				else:
					push_warning("Could not find skin texture: " + new_path)



func _physics_process(delta: float) -> void:
	handle_input()
	move_and_slide()
	
	if is_authority:
		multiplayer_position = global_position
	else:
		global_position = lerp(global_position, multiplayer_position, 10.0 * delta)


func set_user_id(_user_id: int):
	user_id = _user_id


func handle_input():
	if not is_authority:
		return
	
	var vec = Input.get_vector("game_left","game_right","game_up","game_down")
	if vec:
		velocity = velocity.move_toward(vec * max_speed, acceleration)
		animation_player.play("Walk")
		sprite.flip_h = (vec.x < 0)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, acceleration)
		animation_player.play("Idle")


func _on_multiplayer_synchronizer_synchronized() -> void:
	pass
