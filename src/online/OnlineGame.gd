extends Node

signal all_clients_loaded()

# Manages actual online game logic.
var loaded_clients = 0

func _ready() -> void:
	all_clients_loaded.connect(func(): print(Online.get_unique_id(), " ALL LOADED!"))

func start_game():
	if Online.is_server():
		loaded_clients = 0
		_load_game_scene.rpc("res://src/scenes/Level.tscn")


@rpc("authority", "call_local", "reliable")
func _load_game_scene(path: String) -> void:
	get_tree().change_scene_to_file(path)
	_notify_server_client_loaded.rpc_id(1)


@rpc("any_peer", "call_local", "reliable")
func _notify_server_client_loaded() -> void:
	if Online.is_server():
		loaded_clients += 1
		
		if loaded_clients == Online.users.size():
			_signal_all_clients_loaded.rpc()


@rpc("authority", "call_local", "reliable")
func _signal_all_clients_loaded():
	all_clients_loaded.emit()
