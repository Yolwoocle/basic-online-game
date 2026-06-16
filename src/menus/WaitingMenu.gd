extends Control

@onready var chat_label: Label = %ChatLabel
@onready var text_edit: LineEdit = %TextEdit
@onready var start_game_button: Button = %StartGameButton
@onready var player_previews: HBoxContainer = $PlayerPreviews
@onready var info_label: Label = %InfoLabel

func _ready() -> void:
	Chat.message_added.connect(_on_chat_message_added)
	
	Online.connected_to_server.connect(_on_connected_to_server)
	Online.connection_failed.connect(_on_connection_failed)
	Online.server_disconnected.connect(_on_server_disconnected)
	
	Online.peer_connected.connect(_on_peer_connected)
	Online.peer_disconnected.connect(_on_peer_disconnected)
	
	Online.user_added.connect(_on_user_added)
	Online.user_removed.connect(_on_user_removed)
	
	start_game_button.hide()


func _process(delta: float) -> void:
	start_game_button.visible = Online.is_server()
	info_label.text = ""


func leave_game():
	Online.disconnect_multiplayer()
	get_tree().change_scene_to_file("res://src/menus/MainMenu.tscn")


func _on_peer_connected(mult_id: int) -> void:
	Chat.add_message("Peer %s joined." % [mult_id])


func _on_peer_disconnected(mult_id: int) -> void:
	Chat.add_message("Peer %s left." % [mult_id])


func _on_user_added(user_id: int):
	var user = Online.get_user(user_id)
	if not user:
		return
	
	var node: WaitingMenuPlayerCell = preload("res://src/menus/WaitingMenuPlayerCell.tscn").instantiate()
	node.name = str(user_id)
	player_previews.add_child(node)
	node.set_user(user_id)


func _on_user_removed(user_id: int):
	var node = get_node_or_null("PlayerPreviews/" + str(user_id))
	if not node: 
		return
	
	var user = Online.get_user(user_id)
	if not user:
		return
	
	node.queue_free()


func _on_leave_lobby_button_pressed() -> void:
	leave_game()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_send_message"):
		send_current_chat_input()


func _on_send_chat_button_pressed() -> void:
	send_current_chat_input()


func send_current_chat_input():
	Chat.send_message.rpc(text_edit.text)
	text_edit.text = ""


func _on_chat_message_added(message: String) -> void:
	chat_label.text += message + "\n"


func _on_connected_to_server() -> void:
	pass


func _on_connection_failed() -> void:
	leave_game()


func _on_server_disconnected() -> void:
	leave_game()


func _on_start_game_button_pressed() -> void:
	OnlineGame.start_game()


func _on_add_player_button_pressed() -> void:
	add_user()


func add_user():
	var user_id = Online.add_local_user()
