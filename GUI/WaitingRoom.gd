extends Popup

onready var PlayerList : ItemList = $VBoxContainer/CenterContainer/ItemList
onready var light_mode : Node = $VBoxContainer/CenterContainer3/HBoxContainer2/CenterContainer/VBoxContainer/CheckButton

func _ready() -> void:
	PlayerList.clear()
	light_mode.pressed = SaveGame.save_data["Light"]

func refresh_players(players) -> void:
	#print("refreshing player list, to insert the players: ", players)
	PlayerList.clear()
	
	for player_id in players:
		var player : String = players[player_id]["Player_name"]
		PlayerList.add_item(player, null, false)



func _on_CheckButton_pressed() -> void:
	GlobalVariables.set_light_mode(light_mode.pressed)
	SaveGame.save_data["Light"] = light_mode.pressed
	SaveGame.save_game()


func _on_StartButton_pressed():
	$VBoxContainer/CenterContainer3/HBoxContainer2/Time_box.set_timer()
	Network.start_game()
