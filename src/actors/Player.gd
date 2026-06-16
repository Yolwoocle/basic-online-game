class_name Player
extends Actor

@onready var username_label: Label = $UsernameLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var life_component: LifeComponent = $LifeComponent

var user: UserData
var user_id = -1

var acceleration = 50.0
var max_speed = 500.0

func _enter_tree() -> void:
	set_multiplayer_authority(Online.get_user_multiplayer_id(user_id))
	user = Online.get_user(user_id)


func _ready() -> void:
	if user:
		set_skin(user.skin)


func set_skin(skin: OnlineGame.SkinColor) -> void:
	if OnlineGame.skin_colors.has(skin):
		sprite.set_skin(OnlineGame.skin_colors[skin])


func _physics_process(delta: float) -> void:
	handle_input()
	super(delta)
	
	move_and_slide()
	if user:
		username_label.text = user.username
		if user.is_local():
			username_label.text = "[%s]" % [username_label.text]
		username_label.text += "\nHP: %s/%s" % [life_component.life, life_component.max_life]


func set_user_id(_user_id: int):
	user_id = _user_id


func handle_input():
	if not is_multiplayer_authority():
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
