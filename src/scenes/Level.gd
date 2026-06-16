extends Node2D

@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner

const player_path = "res://src/actors/Player.tscn"

func _ready() -> void:
	print(Online.get_multiplayer_id(), " LOAD LEVEL")
	multiplayer_spawner.add_spawnable_scene(player_path) # Player.tscn
	multiplayer_spawner.set_spawn_function(_multiplayer_spawner_spawn_func)
	
	OnlineGame.all_clients_loaded.connect(_on_all_clients_loaded)
	if OnlineGame.are_all_clients_loaded:
		_on_all_clients_loaded()


func spawn_player(user_id: int) -> void:
	multiplayer_spawner.spawn(user_id)


func spawn_all_players():
	if Online.is_server():
		for user_id in Online.users.keys():
			print("SPAWN USER ", user_id)
			spawn_player(user_id)


################################################################################


func _multiplayer_spawner_spawn_func(user_id: int):
	var player: Player = preload(player_path).instantiate()
	player.position = Vector2(randf_range(30,300), randf_range(30,300))
	player.set_user_id(user_id)
	return player


func _on_all_clients_loaded():
	print(Online.get_multiplayer_id(), " All loaded")
	if Online.is_server():
		print("Spawn all players")
		spawn_all_players()


func _on_quit_button_pressed() -> void:
	OnlineGame.quit_game
	pass
