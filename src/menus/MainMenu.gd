extends Control

@onready var host_game_button: Button = $VBoxContainer/HostGameButton
@onready var join_game_button: Button = $VBoxContainer/JoinGameButton
@onready var port_line_edit: LineEdit = $PortLineEdit
@onready var error_label: Label = $ErrorLabel

var error_timer = 0.0

func _ready() -> void:
	host_game_button.pressed.connect(_on_host_game_button_pressed)
	join_game_button.pressed.connect(_on_join_game_button_pressed)
	port_line_edit.text = str(Online.DEFAULT_PORT)


func _process(delta: float) -> void:
	error_timer -= delta
	if error_timer < 0:
		error_label.text = ""


func _on_host_game_button_pressed():
	var port 
	if port_line_edit.text.is_valid_int():
		port = int(port_line_edit.text)
	else:
		new_notification("Invalid port.")
		return
	
	Online.create_server(port)
	get_tree().change_scene_to_file("res://src/menus/WaitingMenu.tscn")


func new_notification(text: String) -> void:
	error_label.text = text
	error_timer = 30.0


func _on_join_game_button_pressed():
	get_tree().change_scene_to_file("res://src/menus/JoinMenu.tscn")
