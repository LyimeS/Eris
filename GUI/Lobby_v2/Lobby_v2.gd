extends Control

# https://godotengine.org/qa/105799/how-to-get-local-ip-address

onready var NameEdit: LineEdit = $MarginContainer/VBoxContainer/MarginContainer/CenterContainer/HBoxContainer2/NameEdit
onready var selected_host_Port: LineEdit = $MarginContainer/VBoxContainer/HBoxContainer/Panel_host/VBoxContainer/CenterContainer2/HBoxContainer/PortEdit
onready var selected_join_IP: LineEdit = $MarginContainer/VBoxContainer/HBoxContainer/Panel_connect/VBoxContainer/CenterContainer2/GridContainer/HostIPEdit
onready var selected_join_Port: LineEdit = $MarginContainer/VBoxContainer/HBoxContainer/Panel_connect/VBoxContainer/CenterContainer2/GridContainer/PortEdit
onready var light_mode: CheckButton = $WaitingRoom/VBoxContainer/CenterContainer3/HBoxContainer2/CenterContainer/VBoxContainer/CheckButton
onready var min_spinBox: SpinBox = $WaitingRoom/VBoxContainer/CenterContainer3/HBoxContainer2/Time_box/CenterContainer/GridContainer/min_SpinBox
onready var sec_spinBox: SpinBox = $WaitingRoom/VBoxContainer/CenterContainer3/HBoxContainer2/Time_box/CenterContainer/GridContainer/sec_SpinBox


# Called when the node enters the scene tree for the first time.
func _ready():
	$AudioStreamPlayer.play()
	AudioServer.set_bus_volume_db(0, SaveGame.save_data["Main_vol"])
	AudioServer.set_bus_volume_db(1, SaveGame.save_data["Music_vol"])
	AudioServer.set_bus_volume_db(2, SaveGame.save_data["VFX_vol"])
	
	#$MarginContainer/HBoxContainer/Panel_host/ColorRect.connect("mouse_entered", self, "_on_Panel_host_mouse_entered")
	#$MarginContainer/HBoxContainer/Panel_host/ColorRect.connect("mouse_exited", self, "_on_Panel_host_mouse_exited")
	#$HBoxContainer/Panel_host/ColorRect.color = Color(1, 0, 0, 1)
	
	# insert in NameEdit box the last name used by the player. Same for Host IP. Ports are set to default.
	NameEdit.text = SaveGame.save_data["Player_name"]
	selected_join_IP.text = SaveGame.save_data["Host_IP"]
	selected_join_Port.text = str(Network.DEFAULT_PORT )
	selected_host_Port.text = str(Network.DEFAULT_PORT )
	
	# reset host_missing flag
	Network.host_missing = false
	# warning-ignore:return_value_discarded
	Network.connect("host_missing_signal", self, "_on_host_missing")
	
	# hide the overlay when pop-up is closed 
	# warning-ignore:return_value_discarded
	$Settings.connect("hide", self, "hide_pop_up")
	# warning-ignore:return_value_discarded
	$Host_Missing_Screen.connect("hide", self, "hide_pop_up")
	# warning-ignore:return_value_discarded
	$connecting_to_host.connect("hide", self, "hide_pop_up")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
# warning-ignore:unused_argument
func _process(delta):
	if Input.is_action_just_pressed("ui_settings"):
		$Blur.show()
		$Settings.show()

func _on_HostButton_pressed() -> void:
	Network.selected_port = int(selected_host_Port.text)
	Network.create_server()
	show_waiting_room()
	get_tree().call_group("HostOnly", "show")

func _on_JoinButton_pressed() -> void:
	Network.selected_IP = selected_join_IP.text
	Network.selected_port = int(selected_join_Port.text)
	Network.connect_to_server()
	#show_waiting_room()
	# warning-ignore:return_value_discarded
	get_tree().connect("connected_to_server", self, "show_waiting_room")
	$Blur.show()
	$connecting_to_host.show()

# save the name of the player everytime the LineEdit is changed
func _on_NameEdit_text_changed(new_text) -> void:
	SaveGame.save_data["Player_name"] = new_text
	SaveGame.save_game()

func _on_HostIPEdit_text_changed(new_text):
	SaveGame.save_data["Host_IP"] = new_text
	SaveGame.save_game()

func show_waiting_room() -> void:
	$connecting_to_host.hide()
	$WaitingRoom.popup_centered()
	print(Network.players)
	$WaitingRoom.refresh_players(Network.players)
	
	#min_spinBox.value = 1
	#sec_spinBox.value = 0
	
	if Network.local_player_id != 1:
		#print("disabling control")
		light_mode.disabled = true
		min_spinBox.editable = false
		sec_spinBox.editable = false
	else:
		GlobalVariables.set_light_mode(SaveGame.save_data["Light"])


#func _on_StartButton_pressed() -> void:
	#Network.start_game()

func _on_Panel_host_mouse_entered():
	print("entered")
	$MarginContainer/HBoxContainer/Panel_host/ColorRect.color = Color(0, 144, 231, 255)


func _on_Panel_host_mouse_exited():
	print("exited")
	$MarginContainer/HBoxContainer/Panel_host/ColorRect.color = Color(0.3, 0.3, 0.3, 1)

func _on_host_missing():
	$Blur.show()
	$Host_Missing_Screen.show()
	$Host_Missing_Screen.raise()

func hide_pop_up():
	$Blur.hide()

