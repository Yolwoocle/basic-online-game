extends Control

@onready var error_text: Label = $ErrorText
@onready var ip_line_edit: LineEdit = $VBoxContainer/IpEdit/IPLineEdit
@onready var port_line_edit: LineEdit = $VBoxContainer/IpEdit/PortLineEdit
var error_timer = 0.0

func _ready() -> void:
	Online.connection_failed.connect(_on_connection_failed)
	Online.connected_to_server.connect(_on_connected_to_server)
	port_line_edit.text = str(Online.DEFAULT_PORT)


func _process(delta: float) -> void:
	error_timer -= delta
	if error_timer < 0:
		error_text.text = ""


func _on_connection_failed():
	new_notification("Connection failed.")


func new_notification(text: String) -> void:
	error_text.text = text
	error_timer = 30.0


func _on_connected_to_server():
	get_tree().change_scene_to_file("res://src/menus/WaitingMenu.tscn")


func _on_back_button_pressed() -> void:
	Online.disconnect_multiplayer()
	get_tree().change_scene_to_file("res://src/menus/MainMenu.tscn")


func _on_connect_button_pressed() -> void:
	if not port_line_edit.text.is_valid_int():
		new_notification("Invalid port.")
		return
	
	Online.create_client(ip_line_edit.text, int(port_line_edit.text))
