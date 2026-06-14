extends Control

@onready var chat_label: Label = %ChatLabel
@onready var text_edit: TextEdit = %TextEdit
@onready var user_info_label: Label = %UserInfoLabel
@onready var start_game_button: Button = %StartGameButton

func _ready() -> void:
	Chat.message_added.connect(_on_chat_message_added)
	
	Online.connection_failed.connect(_on_connection_failed)
	Online.server_disconnected.connect(_on_server_disconnected)
	
	start_game_button.hide()


func _process(delta: float) -> void:
	user_info_label.text = ""
	for user_id in Online.local_users.keys():
		var user = Online.local_users[user_id]
		user_info_label.text += "[%s] (UserID: %s)\n" % [user.username, user_id]
	user_info_label.text += "MultID: %s\n" % [Online.get_unique_id()]
	user_info_label.text += "\n"
	
	user_info_label.text += "Connected: (%s)\n" % [Online.users.size()]
	for user_id in Online.users.keys():
		var user = Online.users[user_id]
		user_info_label.text += "- %s (skin=%s)\n  - UserID:%s\n  - MultID:%s\n" % [
			user.username, user.skin, user_id, user.multiplayer_id,
		]
	
	start_game_button.visible = Online.is_server()


func leave_game():
	Online.disconnect_multiplayer()
	get_tree().change_scene_to_file("res://src/menus/MainMenu.tscn")


func _on_leave_lobby_button_pressed() -> void:
	leave_game()


func _on_send_chat_button_pressed() -> void:
	Chat.send_message.rpc(text_edit.text)
	text_edit.clear()


func _on_chat_message_added(message: String) -> void:
	chat_label.text += message + "\n"


func _on_skin_plus_1_pressed() -> void:
	for user_id in Online.local_users.keys():
		var user = Online.users[user_id]
		Online.request_increase_user_data(user_id, "skin", +1)


func _on_skin_minus_1_pressed() -> void:
	for user_id in Online.local_users.keys():
		var user = Online.users[user_id]
		Online.request_increase_user_data(user_id, "skin", -1)


func _on_connection_failed() -> void:
	leave_game()


func _on_server_disconnected() -> void:
	leave_game()


func _on_start_game_button_pressed() -> void:
	OnlineGame.start_game()
