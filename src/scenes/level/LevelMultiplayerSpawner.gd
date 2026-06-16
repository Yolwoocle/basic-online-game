extends MultiplayerSpawner

const player_path = "res://src/actors/Player.tscn"
const enemy_path = "res://src/actors/Enemy.tscn"

func _ready() -> void:
	add_spawnable_scene(player_path)
	set_spawn_function(_multiplayer_spawner_spawn_func)


func _multiplayer_spawner_spawn_func(data: Dictionary):
	if data["type"] == "player":
		var player: Player = preload(player_path).instantiate()
		var user_id = data["user_id"]
		player.global_position = Vector2(120.0 + randf_range(-50.0, 50.0), 120.0 + randf_range(-50.0, 50.0))
		player.name = "Player" + str(user_id)
		player.set_user_id(user_id)
		return player
	
	elif data["type"] == "enemy":
		var enemy: Enemy = preload(enemy_path).instantiate()
		enemy.global_position = data["position"]
		return enemy
