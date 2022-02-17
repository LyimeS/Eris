extends MarginContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _on_min_SpinBox_value_changed(value):
	if Network.local_player_id == 1:
		set_timer()
		rpc("sync_min_value", value)
	
sync func sync_min_value(value):
	$CenterContainer/GridContainer/min_SpinBox.value = value

func _on_sec_SpinBox_value_changed(value):
	if Network.local_player_id == 1:
		set_timer()
		rpc("sync_sec_value", value)

sync func sync_sec_value(value):
	$CenterContainer/GridContainer/sec_SpinBox.value = value

func set_timer() -> void:
	var minutes = $CenterContainer/GridContainer/min_SpinBox.value * 60
	var seconds = $CenterContainer/GridContainer/sec_SpinBox.value
	var seconds_total = minutes + seconds
	print(seconds_total)
	GlobalVariables.set_match_time(seconds_total)
