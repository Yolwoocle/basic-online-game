extends Node2D

@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner

const player_path = "uid://mjt3lrjwjeue"


func _ready() -> void:
	multiplayer_spawner.add_spawnable_scene(player_path) # Player.tscn
	multiplayer_spawner.set_spawn_function(_multiplayer_spawner_spawn_func)
	
	OnlineGame.all_clients_loaded.connect(_on_all_clients_loaded)


func _multiplayer_spawner_spawn_func(user_id: int):
	var player: Player = preload(player_path).instantiate()
	player.position = Vector2(randf_range(30,300), randf_range(30,300))
	player.set_user_id(user_id)
	return player


func spawn_player(user_id: int) -> void:
	multiplayer_spawner.spawn(user_id)


func spawn_all_players():
	if Online.is_server():
		for user_id in Online.users.keys():
			spawn_player(user_id)


func _on_all_clients_loaded():
	if Online.is_server():
		spawn_all_players()
