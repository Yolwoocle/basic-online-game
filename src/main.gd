class_name Main
extends Node

func _ready():
	await get_tree().create_timer(0.05).timeout
	
	# Parse arguments
	var arguments = {}
	for argument in OS.get_cmdline_args():
		if argument.contains("="):
			var key_value = argument.split("=")
			arguments[key_value[0].trim_prefix("--")] = key_value[1]
		else:
			arguments[argument.trim_prefix("--")] = ""
	
	var usable_rect = DisplayServer.screen_get_usable_rect()
	var quarter_size = usable_rect.size / 2
	var window = get_window()
	var decoration_size = window.get_size_with_decorations() - window.size
	usable_rect.position += decoration_size
	window.size = quarter_size - decoration_size
	
	if arguments.has("server"):
		Online.create_server()
		
		# Dock the window to the top left corner of the screen
		window.position = usable_rect.position
		
		get_tree().call_deferred("change_scene_to_file", "res://src/menus/WaitingMenu.tscn")
		
	elif arguments.has("client"):
		Online.create_client("localhost")
		
		# Dock the window to the a corner of the screen
		if arguments["client"] == "1":
			# Top-right
			window.position = usable_rect.position + Vector2i(quarter_size.x, 0)
		elif arguments["client"] == "2":
			# Bottom-left
			window.position = usable_rect.position + Vector2i(0, quarter_size.y)
		elif arguments["client"] == "3":
			# Bottom-right
			window.position = usable_rect.position + quarter_size
		
		get_tree().call_deferred("change_scene_to_file", "res://src/menus/WaitingMenu.tscn")
		
	else:
		get_tree().call_deferred("change_scene_to_file", "res://src/menus/MainMenu.tscn")
