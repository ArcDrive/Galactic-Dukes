extends Node2D

@export var number_of_stars: int

@export var port: int = 10191 #Reference to Dune, the first book takes place in year 10191

@export var galaxy: Node2D

var menu
var username

func _ready():
	menu = $CanvasLayer/MainMenu


func _process(delta):
	pass

func client_host(port_line, playername):
	Global.host = true
	Global.print_console("Generating galaxy with " + str(number_of_stars) + " stars")
	galaxy._generate_galaxy(number_of_stars)
	
	if port_line.is_valid_int():
		port = int(port_line)
	
	Global.print_console("Attempting to host server on port " + str(port))
	
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(player_connected)
	multiplayer.peer_disconnected.connect(player_disconnected)
	
	menu.visible = false
	Global.players[1] = {"username": playername}


func client_join(address_line, port_line, playername):
	
	username = playername
	
	if port_line.is_valid_int():
		port = int(port_line)
	
	Global.print_console("Attempting connection to " + address_line + " on port " + str(port))
	
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(address_line, port)
	multiplayer.multiplayer_peer = peer
	
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.connected_to_server.connect(_on_connection_succeeded)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func player_connected(id):
	galaxy.send_stars(id)

func player_disconnected(id):
	Global.print_console("Player id " + str(id) + " disconnected")

func _on_connection_failed():
	Global.print_console("Failed to connect")

func _on_connection_succeeded():
	Global.print_console("Successfully connected")
	menu.visible = false
	add_player.rpc_id(1, username)

func _on_server_disconnected():
	Global.print_console("Lost connection to server")

@rpc("any_peer")
func add_player(playername):
	var player_id = multiplayer.get_remote_sender_id()
	
	var original_name = playername
	var name_count = 1
	while is_username_taken(playername):
		name_count += 1
		playername = "%s%d" % [original_name, name_count]
	
	Global.players[player_id] = {"username": playername}
	Global.print_console("Player %s with ID %d has joined." % [playername, player_id])
	update_players.rpc(Global.players)

@rpc
func update_players(players):
	for player_id in players:
		if player_id not in Global.players:
			Global.players[player_id] = players[player_id]
			Global.print_console("Player %s with ID %d has joined." % [Global.players[player_id].username, player_id])

func is_username_taken(username):
	for p in Global.players.values():
		if p["username"] == username:
			return true
	return false
