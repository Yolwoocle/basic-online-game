extends Node

const DEFAULT_PORT = 9999

func create_client(ip_address: String, port: int):
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(ip_address, port)
	multiplayer.multiplayer_peer = peer
	if err:
		print("Error creating client: %s" % [err])


func create_server(port: int = DEFAULT_PORT):
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	if err:
		print("Error creating server: %s" % [err])
