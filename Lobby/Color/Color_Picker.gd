extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	for button in $VBoxContainer/GridContainer.get_children():
		button.connect("pressed", self, "on_button_pressed", [button.color_number])

func on_button_pressed(color_number):
	print("color pressed: ", color_number)
	if Network.local_player_id == 1:
		color_selected(color_number, 1)
	else:
		rpc_id(1, "color_selected", color_number, Network.local_player_id)
	

remote func color_selected(color_number, player_id):
	print("color ", color_number , " asked by peer number ", player_id)
	rpc("disable_button", color_number, player_id)
	
# called by host from color_selected
sync func disable_button(color_number, player_id) -> void:
	for button in $VBoxContainer/GridContainer.get_children():
		if Network.players[player_id].has("color_number") and button.color_number == Network.players[player_id]["color_number"]:
			button.disabled = false
			button.text = GlobalVariables.COLOR_LIST[button.color_number]
	
	Network.set_player_color(player_id, color_number)
	var button = $VBoxContainer/GridContainer.get_child(color_number -1)
	button.disabled = true
	button.text = button.text + " - " + Network.players[player_id]["Player_name"]


