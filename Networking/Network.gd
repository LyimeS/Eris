extends Node

# Most of the things in here I'm not really sure how they work.

const DEFAULT_IP : String = "127.0.0.1"
var selected_IP : String # set in Lobby
const DEFAULT_PORT : int = 32023
var selected_port : int # set in Lobby
const MAX_PLAYERS : int = 4

var local_player_id : int = 0
sync var players: Dictionary = {}
sync var player_data = {}
signal ready_to_spawn

#signal player_disconnected
#signal server_disconnected

func _ready():
	randomize()
	# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_disconnected", self, "_on_player_disconnected")
	# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self, "_on_player_connected")
	

func create_server():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(selected_port, MAX_PLAYERS)
	get_tree().network_peer = peer
	add_to_player_list()
	print("creating server on port ", selected_port)


func connect_to_server():
	var peer = NetworkedMultiplayerENet.new()
	# warning-ignore:return_value_discarded
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	peer.create_client(selected_IP, selected_port)
	get_tree().network_peer = peer
	print("connect to ", selected_IP, " on port ", selected_port)
	

func add_to_player_list():
	local_player_id = get_tree().get_network_unique_id()
	player_data = SaveGame.save_data
	players[local_player_id] = player_data


func _connected_to_server():
	add_to_player_list()
	rpc("_send_player_info", local_player_id, player_data)

# called when a player connects to host.
remote func _send_player_info(id, player_info):
	players[id] = player_info
	if local_player_id == 1:
		print(str(id) + " connected") #debug
		rset("players", players) # RSET: Remotely changes a property's value on other peers (and locally)
		rpc("update_waiting_room")

func _on_player_connected(id):
	print("i'm here")
	if not get_tree().is_network_server(): #same as "not local_player_id == 1"
		print(str(id) + " connected")

func _on_player_disconnected(id):
	print(id, "player disconnected")
	pass

sync func update_waiting_room():
	get_tree().call_group("WaitingRoom", "refresh_players", players)

func set_player_color(player_id, color_number):
	players[player_id]["color_number"] = color_number


# Called by Lobby._on_StartButton_pressed by the host
func start_game():
	# before the game starts, check if every player choose their color.
	# in case they did not, set a color to them.
	
	for player in players:
		if (not "color_number" in players[player]) or (players[player]["color_number"] == 0):
			print("color not selected by player ", player)
			
			var unused_colors: Array = GlobalVariables.COLORS
			for _player in players:
				if players[_player].has("color_number"):
					if players[_player]["color_number"] in unused_colors:
						unused_colors.erase(players[_player]["color_number"])
			
			#print("unused_colors: ", unused_colors)
			players[player]["color_number"] = unused_colors[0]
			#unused_colors.remove(0)
			#print("unused_colors: ", unused_colors)
	
	# also, set a flag to false. this flag will be used to check if they're
	# ready to recieve a rpc to spawn players
	for player in players:
		players[player]["ready_to_start"] = false
	
	rset("players", players) # RSET: Remotely changes a property's value on other peers (and locally)
	rpc("load_world")

sync func load_world() -> void:
	print("called load world")
	print(players)
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://World/Game.tscn")

# check if everybody is ready to spawn players. Called by host/players from raise_ready_to_start 
remote func check_ready_to_start(rec_player_id) -> void:
	print("called check_ready_to_start")
	print(players)
	print("player ", rec_player_id, " is ready to spawn players")
	players[rec_player_id]["ready_to_start"] = true
	
	var ready_to_start: bool = true
	for player in players:
		if players[player]["ready_to_start"] == false:
			ready_to_start = false
	
	if ready_to_start:
		print("everybody is ready to spawn")
		emit_signal("ready_to_spawn")

# called by grid._ready()
func raise_ready_to_start():
	if local_player_id == 1:
		check_ready_to_start(local_player_id)
	else:
		rpc_id(1, "check_ready_to_start", local_player_id)
