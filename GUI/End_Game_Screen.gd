extends Control


var block_double_click: bool


# Called when the node enters the scene tree for the first time.
func _ready():
	print("end v1 called")
	block_double_click = false
	#print(Network.players)
	if Network.local_player_id != 1:
		$CenterContainer/VBoxContainer/RestartButton.visible = false
		
	for player in Network.players:
		var lbl_name = Label.new()
		$CenterContainer/VBoxContainer/GridContainer .add_child(lbl_name)
		lbl_name.text = str(Network.players[player]["Player_name"])
		var lbl_score = Label.new()
		$CenterContainer/VBoxContainer/GridContainer.add_child(lbl_score)
		lbl_score.text = str(Network.players[player]["score"])
	
	print("--------------------------------------------------")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_RestartButton_pressed():
	Network.start_game()
