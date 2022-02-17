extends Control

onready var NameEdit : LineEdit = $VBoxContainer/CenterContainer/ConfigContainer/NameEdit
onready var selected_IP : LineEdit = $VBoxContainer/CenterContainer/ConfigContainer/IPEdit
onready var selected_Port : LineEdit = $VBoxContainer/CenterContainer/ConfigContainer/PortEdit
onready var light_mode : CheckButton = $WaitingRoom/VBoxContainer/CenterContainer3/HBoxContainer2/CheckButton
onready var min_spinBox: SpinBox = $VBoxContainer/CenterContainer3/HBoxContainer2/Control/CenterContainer/GridContainer/min_SpinBox
onready var sec_spinBox: SpinBox = $VBoxContainer/CenterContainer3/HBoxContainer2/Control/CenterContainer/GridContainer/_SpinBox


func _ready() -> void:
	# insert in NameEdit box the last name used by the player
	NameEdit.text = SaveGame.save_data["Player_name"]
	
	selected_IP.text = Network.DEFAULT_IP 
	selected_Port.text = str(Network.DEFAULT_PORT )

func _on_HostButton_pressed() -> void:
	Network.selected_port = int(selected_Port.text)
	Network.create_server()
	show_waiting_room()
	get_tree().call_group("HostOnly", "show")


func _on_JoinButton_pressed() -> void:
	Network.selected_IP = selected_IP.text
	Network.selected_port = int(selected_Port.text)
	Network.connect_to_server()
	show_waiting_room()


# save the name of the player everytime the LineEdit is changed
func _on_NameEdit_text_changed(new_text) -> void:
	SaveGame.save_data["Player_name"] = new_text
	SaveGame.save_game()


func show_waiting_room() -> void:
	$WaitingRoom.popup_centered()
	print(Network.players)
	$WaitingRoom.refresh_players(Network.players)
	
	if Network.local_player_id != 1:
		print("disabling control")
		light_mode.disabled = true
		
	else:
		GlobalVariables.set_light_mode(SaveGame.save_data["Light"])


func _on_StartButton_pressed() -> void:
	Network.start_game()
