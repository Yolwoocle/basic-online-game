extends Node

signal all_clients_loaded()

# Manages actual online game logic.
var loaded_clients = 0
var are_all_clients_loaded = false

enum SkinColor {
	GREEN,
	PINK,
	PURPLE,
	YELLOW
}

const skin_colors = {
	0: "green",
	1: "pink",
	2: "purple",
	3: "yellow"
}

func get_idle_skin_texture_path(color: SkinColor): 
	if not skin_colors.has(color): 
		return null
	
	var texture_path = "res://assets/actors/character_green_idle.png"
	texture_path = texture_path.replace("green", skin_colors[color])
	return texture_path


func _ready() -> void:
	all_clients_loaded.connect(func(): print(Online.get_multiplayer_id(), " ALL LOADED!"))

func start_game():
	if Online.is_server():
		loaded_clients = 0
		are_all_clients_loaded = false
		_load_game_scene.rpc("res://src/scenes/level/Level.tscn")


func quit_game():
	get_tree().change_scene_to_file("res://src/menus/MainMenu.tscn")
	Online.disconnect_multiplayer()


@rpc("authority", "call_local", "reliable")
func _load_game_scene(path: String) -> void:
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	_notify_server_client_loaded.rpc_id(1)


@rpc("any_peer", "call_local", "reliable")
func _notify_server_client_loaded() -> void:
	if Online.is_server():
		loaded_clients += 1
		
		if loaded_clients == Online.users.size():
			are_all_clients_loaded = true
			_signal_all_clients_loaded.rpc()


@rpc("authority", "call_local", "reliable")
func _signal_all_clients_loaded():
	all_clients_loaded.emit()
