extends Node2D

@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var actors: Node2D = $Actors


func _ready() -> void:
	print(Online.get_multiplayer_id(), " LOAD LEVEL")
	
	Online.peer_disconnected.connect(_on_peer_disconnected)
	
	OnlineGame.all_clients_loaded.connect(_on_all_clients_loaded)
	if OnlineGame.are_all_clients_loaded:
		_on_all_clients_loaded()


func spawn_player(user_id: int) -> void:
	multiplayer_spawner.spawn(
		{"type": "player", "user_id": user_id}
	)


func spawn_enemy(position: Vector2) -> void:
	multiplayer_spawner.spawn(
		{"type": "enemy", "position": position}
	)


func spawn_all_players():
	if Online.is_server():
		for user_id in Online.users.keys():
			print("SPAWN USER ", user_id)
			spawn_player(user_id)


func _on_all_clients_loaded():
	print(Online.get_multiplayer_id(), " All loaded")
	if Online.is_server():
		print("Spawn all players")
		spawn_all_players()


func _on_quit_button_pressed() -> void:
	OnlineGame.quit_game()


func _on_peer_disconnected(multiplayer_id: int) -> void:
	if Online.is_server():
		for user in Online.get_users_with_multiplayer_id(multiplayer_id):
			var player = actors.get_node_or_null("Player" + str(user.user_id))
			if player and player is Player:
				player.queue_free()


func _on_spawn_enemy_button_pressed() -> void:
	spawn_enemy(Vector2(150, 150) + Vector2(randf_range(-50, 50), randf_range(-50, 50)))
