extends Control

@onready var host_game_button: Button = $VBoxContainer/HostGameButton
@onready var join_game_button: Button = $VBoxContainer/JoinGameButton

func _ready() -> void:
	host_game_button.pressed.connect(_on_host_game_button_pressed)
	join_game_button.pressed.connect(_on_join_game_button_pressed)


func _on_host_game_button_pressed():
	Online.create_server()
	get_tree().change_scene_to_file("res://src/menus/WaitingMenu.tscn")


func _on_join_game_button_pressed():
	Online.create_client("localhost")
	get_tree().change_scene_to_file("res://src/menus/WaitingMenu.tscn")
