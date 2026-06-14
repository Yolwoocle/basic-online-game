extends Node

signal message_added(message: String)

var chat = []

func add_message(message: String) -> void:
	chat.append(message)
	message_added.emit(message)


@rpc("any_peer", "call_local", "reliable")
func send_message(message: String) -> void:
	var sender_id = multiplayer.get_remote_sender_id()
	
	var username = ""
	if Online.local_users.is_empty():
		username = "User"
	else:
		username = Online.local_users[Online.local_users.keys()[0]].username
	
	add_message("<%s>: %s" % [username, message])
