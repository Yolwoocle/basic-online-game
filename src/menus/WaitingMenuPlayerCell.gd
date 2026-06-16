class_name WaitingMenuPlayerCell
extends MarginContainer

var user_id: int = -1
var user: UserData

@onready var color_rect: ColorRect = $ColorRect
@onready var sprite_2d: Sprite2D = $ColorRect/Sprite2D
@onready var player_name_label: Label = $ColorRect/PlayerName
@onready var user_id_label: Label = $ColorRect/UserID
@onready var mult_id_label: Label = $ColorRect/MultID
@onready var crown: Sprite2D = $ColorRect/Crown
@onready var remove_button: Button = $ColorRect/RemoveButton
@onready var prev_skin_button: Button = $ColorRect/PrevSkinButton
@onready var next_skin_button: Button = $ColorRect/NextSkinButton

func _ready() -> void:
	Online.user_data_changed.connect(_on_user_data_changed)

func set_user(_user_id: int):
	user_id = _user_id
	_update_view()

func _update_view():
	user = Online.get_user(user_id)
	if not user:
		print("No user ", user_id)
		return
	
	color_rect.color = Color("3fa2cc") if user.is_local() else Color("768a94")
	
	player_name_label.text = user.username
	crown.visible = user.is_server()
	
	var texture_path = OnlineGame.get_idle_skin_texture_path(user.skin)
	if texture_path and (sprite_2d.texture as CompressedTexture2D).resource_path != texture_path:
		sprite_2d.texture = load(texture_path)
	
	user_id_label.text = "User ID: %s" % [str(user.user_id)]
	mult_id_label.text = "Mult ID: %s" % [str(user.multiplayer_id)]
	
	remove_button.visible = user.is_local()
	prev_skin_button.visible = user.is_local()
	next_skin_button.visible = user.is_local()


func _on_user_data_changed(user_data: int, key: String, new_value: Variant) -> void:
	_update_view()


func _on_remove_button_pressed() -> void:
	Online.remove_local_user(user_id)


func _on_prev_skin_button_pressed() -> void:
	var skin = Online.get_user_data(user_id, "skin")
	Online.request_set_user_data(user_id, "skin", (skin-1) % OnlineGame.skin_colors.size())


func _on_next_skin_button_pressed() -> void:
	var skin = Online.get_user_data(user_id, "skin")
	Online.request_set_user_data(user_id, "skin", (skin+1) % OnlineGame.skin_colors.size())
