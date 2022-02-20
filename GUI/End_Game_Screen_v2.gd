extends Control

onready var winner_name_label: Label = get_node("CenterContainer/VBoxContainer/HBoxContainer/winner_pannel/CenterContainer/VBoxContainer/name_label")
onready var winner_score_label: Label = get_node("CenterContainer/VBoxContainer/HBoxContainer/winner_pannel/CenterContainer/VBoxContainer/score_label")
onready var winner_colorRect: ColorRect = get_node("CenterContainer/VBoxContainer/HBoxContainer/winner_pannel/ColorRect")
onready var second_name_label: Label = get_node("CenterContainer/VBoxContainer/HBoxContainer/players_pannel/players_list/player_2/CenterContainer/VBoxContainer/name_label")
onready var second_score_label: Label = get_node("CenterContainer/VBoxContainer/HBoxContainer/players_pannel/players_list/player_2/CenterContainer/VBoxContainer/score_label")
onready var second_colorRect: ColorRect = get_node("CenterContainer/VBoxContainer/HBoxContainer/players_pannel/players_list/player_2/ColorRect")
onready var third_name_label: Label = get_node("CenterContainer/VBoxContainer/HBoxContainer/players_pannel/players_list/player_3/CenterContainer/VBoxContainer/name_label")
onready var third_score_label: Label = get_node("CenterContainer/VBoxContainer/HBoxContainer/players_pannel/players_list/player_3/CenterContainer/VBoxContainer/score_label")
onready var third_colorRect: ColorRect = get_node("CenterContainer/VBoxContainer/HBoxContainer/players_pannel/players_list/player_3/ColorRect")

onready var restart_button: Button = get_node("CenterContainer/VBoxContainer/RestartButton")

var players = Network.players.duplicate()
#var players = {1:{"score":50, "Player_name":"White", color_number:2}, 2:{"score":70, "Player_name":"Yellow",  color_number:1}, 3:{"score":100, "Player_name":"Orange",  color_number:3}}
var first_place_score: int = 0
var first_place_id: int = 0
var second_place_score: int = 0
var second_place_id: int = 0
var third_place_score: int = 0
var third_place_id: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	sort_players_by_score()
	$AudioStreamPlayer.play()
	if Network.local_player_id != 1:
		restart_button.visible = false
	
	if restart_button.connect("button_down", self, "_on_RestartButton_pressed") != 0: print("COULD NOT CONNECT TO RESTART BUTTON")
	
	# check if host is still connected
	Network.connect("host_missing_signal", self, "_on_host_missing")
	if Network.host_missing:
		$Host_Missing_Screen.visible = true
		$CenterContainer/VBoxContainer/ButtonHome.visible = true


func sort_players_by_score() -> void:
	for player in players:
		print("player: ", player, " score: ", players[player]["score"])
		
		if players[player]["score"] > first_place_score:
			first_place_id = player
			first_place_score = players[player]["score"]
	if first_place_id == 0: first_place_id = players.keys()[0]
	print(first_place_id)
	winner_name_label.text = players[first_place_id]["Player_name"]
	winner_score_label.text = str(players[first_place_id]["score"])
	winner_colorRect.color = GlobalVariables.SHADER_COLOR_LIST[players[first_place_id]["color_number"]]
	players.erase(first_place_id)
	print(players)
	
	if not players.empty():
		for player in players:
			print("player: ", player, " score: ", players[player]["score"])
			
			if players[player]["score"] > second_place_score:
				second_place_id = player
				second_place_score = players[player]["score"]
		print(second_place_id)
		if second_place_id == 0: second_place_id = players.keys()[0]
		second_name_label.text = players[second_place_id]["Player_name"]
		second_score_label.text = str(players[second_place_id]["score"])
		second_colorRect.color = GlobalVariables.SHADER_COLOR_LIST[players[second_place_id]["color_number"]]
		players.erase(second_place_id)
		print(players)
	
	if not players.empty():
		for player in players:
			print("player: ", player, " score: ", players[player]["score"])
			
			if players[player]["score"] > third_place_score:
				third_place_id = player
				third_place_score = players[player]["score"]
		print(third_place_id)
		if third_place_id == 0: third_place_id = players.keys()[0]
		third_name_label.text = players[third_place_id]["Player_name"]
		third_score_label.text = str(players[third_place_id]["score"])
		third_colorRect.color = GlobalVariables.SHADER_COLOR_LIST[players[third_place_id]["color_number"]]
		players.erase(third_place_id)
		print(players)

func _on_RestartButton_pressed() -> void:
	print("--------------------------------------------------")
	#Network.start_game()
	Network.remove_disconnected_players()
	$WaitingRoom.visible = true
	$WaitingRoom.refresh_players(Network.players)
	get_tree().call_group("HostOnly", "show")


func _on_host_missing() -> void:
	$Host_Missing_Screen.visible = true
	$CenterContainer/VBoxContainer/ButtonHome.visible = true


func _on_ButtonHome_pressed():
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://GUI/Lobby_v2/Lobby_v2.tscn")
