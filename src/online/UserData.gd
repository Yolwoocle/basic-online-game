class_name UserData
extends Resource

@export var multiplayer_id = -1
@export var user_id = -1
@export var username = "Username"
@export var skin = 0


func _init() -> void:
	pass


func to_dict() -> Dictionary:
	return {
		"multiplayer_id": multiplayer_id,
		"user_id": user_id,
		"username": username,
		"skin": skin
	}

static func from_dict(data: Dictionary) -> UserData:
	var user = UserData.new()
	user.multiplayer_id = data.get("multiplayer_id", -1)
	user.user_id = data.get("user_id", -1)
	user.username = data.get("username", "Username")
	user.skin = data.get("skin", 0)
	return user


func is_server():
	return multiplayer_id == 1


func is_local():
	return multiplayer_id == Online.get_multiplayer_id()
