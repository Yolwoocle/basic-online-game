extends Node

signal peer_connected(multiplayer_id: int)
signal peer_disconnected(multiplayer_id: int)
signal user_added(user_id: int)
signal user_removed(user_id: int)

signal server_opened()
signal connected_to_server()
signal connection_failed()
signal server_disconnected()

signal user_data_changed(user_id: int, key: String, new_value: Variant)

const DEFAULT_PORT = 9999

var users: Dictionary[int, UserData] = {}
var local_users: Dictionary[int, UserData] = {}

var join_order = 0


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	server_opened.connect(_on_server_opened)


func reset() -> void:
	users.clear()


func disconnect_multiplayer() -> void:
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	reset()


func get_multiplayer_id() -> int:
	return multiplayer.get_unique_id()


func is_server() -> bool:
	return multiplayer.is_server()


func add_local_user() -> int:
	var user = UserData.new()
	var user_id = randi_range(1, 2_147_483_646) # max int
	
	user.username = _get_system_username() + str(randi_range(100, 999))
	user.user_id = user_id
	
	local_users[user_id] = user
	request_register_user(user_id, user.to_dict())
	
	return user_id


func remove_local_user(user_id: int):
	if not local_users.has(user_id):
		return
	var user = get_user(user_id)
	if not user.is_local():
		return
	
	request_unregister_user(user.user_id)
	local_users.erase(user.user_id)


@rpc("any_peer", "call_local", "reliable")
func register_user(user_id: int, user_dict: Dictionary):
	if not is_server():
		return
	
	user_dict["multiplayer_id"] = multiplayer.get_remote_sender_id()
	_add_user.rpc(user_id, user_dict)


@rpc("any_peer", "call_local", "reliable")
func unregister_user(user_id: int):
	if not is_server():
		return
	if not users.has(user_id):
		return
	_remove_user.rpc(user_id)


func get_user(user_id: int) -> UserData:
	if not has_user(user_id):
		return null
	
	return users[user_id]


func has_user(user_id: int) -> bool:
	return users.has(user_id)


func get_user_data(user_id: int, key: String) -> Variant:
	if not has_user(user_id):
		return null
	
	var user = users[user_id]
	return user.get(key)


func request_set_user_data(user_id: int, key: String, value: Variant) -> void:
	if not has_user(user_id):
		return
	
	_server_update_user_data.rpc_id(1, user_id, key, value)


func request_increase_user_data(user_id: int, key: String, diff: Variant) -> void:
	if not has_user(user_id):
		return
	
	var user = users[user_id]
	request_set_user_data(user_id, key, user.get(key) + diff)


func get_user_multiplayer_id(user_id: int):
	if not has_user(user_id):
		return -1
	
	var user = users[user_id]
	return user.multiplayer_id


func get_users_with_multiplayer_id(mutiplayer_id: int): # -> Array[UserData]
	var out = []
	for user_id in users:
		if users[user_id].multiplayer_id == mutiplayer_id:
			out.append(users[user_id])
	return out


func is_user_local(user_id: int):
	if not has_user(user_id):
		return -1
	
	return get_user(user_id).multiplayer_id == get_multiplayer_id()


################################################################################
## Server 
################################################################################

func create_server(port: int = DEFAULT_PORT) -> Error:
	reset()
	var peer = ENetMultiplayerPeer.new()
	var err: Error = peer.create_server(port)
	
	if err:
		print("Error creating server: %s" % [error_string(err)])
		return err
	
	multiplayer.multiplayer_peer = peer
	server_opened.emit()
	
	return err


func _update_client_with_current_users(multiplayer_id: int):
	for existing_user_id in users:
		_add_user.rpc_id(multiplayer_id, existing_user_id, users[existing_user_id].to_dict())


@rpc("any_peer", "call_local", "reliable")
func _server_update_user_data(user_id: int, key: String, value: Variant):
	if not is_server():
		return
	if multiplayer.get_remote_sender_id() != users[user_id].multiplayer_id:
		return
	if not users.has(user_id):
		return
	
	_set_user_data.rpc(user_id, key, value)


################################################################################
## Client 
################################################################################


func create_client(ip_address: String, port: int = DEFAULT_PORT) -> Error:
	reset()
	var peer = ENetMultiplayerPeer.new()
	var err: Error = peer.create_client(ip_address, port)
	if err:
		print("Error creating client: %s" % [error_string(err)])
		return err
	
	multiplayer.multiplayer_peer = peer
	return err


func request_register_user(user_id: int, user_dict: Dictionary) -> void:
	register_user.rpc_id(1, user_id, user_dict)


func request_unregister_user(user_id: int) -> void:
	unregister_user.rpc_id(1, user_id)


@rpc("authority", "call_local", "reliable")
func _add_user(user_id: int, user_dict: Dictionary) -> void:
	users[user_id] = UserData.from_dict(user_dict)
	user_added.emit(user_id)


@rpc("authority", "call_local", "reliable")
func _remove_user(user_id: int) -> void:
	if not users.has(user_id):
		return
	
	user_removed.emit(user_id)
	users.erase(user_id)


@rpc("authority", "call_local", "reliable")
func _set_user_data(user_id: int, key: String, value: Variant):
	if users.has(user_id):
		users[user_id].set(key, value)
		user_data_changed.emit(user_id, key, value)


################################################################################
## Signals
################################################################################


func _on_peer_connected(multiplayer_id: int) -> void:
	peer_connected.emit(multiplayer_id)
	
	if is_server():
		_update_client_with_current_users(multiplayer_id)


func _on_peer_disconnected(multiplayer_id: int) -> void:
	peer_disconnected.emit(multiplayer_id)
	
	if is_server():
		for user_id in users.keys():
			if users[user_id].multiplayer_id == multiplayer_id:
				request_unregister_user(user_id)


func _on_server_opened() -> void:
	pass

func _on_connected_to_server() -> void:
	Chat.add_message("Connected to server.")
	connected_to_server.emit()
	
	# Register users to the server
	for user in local_users.values():
		user.multiplayer_id = get_multiplayer_id()
		request_register_user(user.user_id, user.to_dict())


func _on_connection_failed() -> void:
	Chat.add_message("Connection failed.")
	connection_failed.emit()
	
	disconnect_multiplayer()


func _on_server_disconnected() -> void:
	Chat.add_message("Server disconnected.")
	server_disconnected.emit()
	
	disconnect_multiplayer()


################################################################################
## Utility
################################################################################


func _get_system_username() -> String:
	if OS.has_environment("USERNAME"):
		return OS.get_environment("USERNAME") # Windows
	elif OS.has_environment("USER"):
		return OS.get_environment("USER") # Linux and macOS
	
	return "Username" # Fallback
