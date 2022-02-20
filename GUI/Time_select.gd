extends MarginContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	#print("GlobalVariables: ", GlobalVariables.seconds, " sec. ", GlobalVariables.minutes, " minutes")
	if GlobalVariables.seconds == 0 and GlobalVariables.minutes == 0:
		$CenterContainer/GridContainer/sec_SpinBox.value = 0
		$CenterContainer/GridContainer/min_SpinBox.value = 1
		#print("seting a minimal time")
	else:
		$CenterContainer/GridContainer/sec_SpinBox.value = GlobalVariables.seconds
		$CenterContainer/GridContainer/min_SpinBox.value = GlobalVariables.minutes
		
	


func _on_min_SpinBox_value_changed(value):
	if Network.local_player_id == 1:
		
		# set the math_time to at leats 10 seconds
		if value == 0 and $CenterContainer/GridContainer/sec_SpinBox.value < 10:
			$CenterContainer/GridContainer/sec_SpinBox.value = 10
		
		if value == 0:
			$CenterContainer/GridContainer/sec_SpinBox.min_value = 10
		else:
			$CenterContainer/GridContainer/sec_SpinBox.min_value = 0
		
		set_timer()
		rpc("sync_min_value", value)

sync func sync_min_value(value):
	$CenterContainer/GridContainer/min_SpinBox.value = value
	GlobalVariables.set_match_time_minutes(value)

func _on_sec_SpinBox_value_changed(value):

	if Network.local_player_id == 1:
		set_timer()
		rpc("sync_sec_value", value)

sync func sync_sec_value(value):
	$CenterContainer/GridContainer/sec_SpinBox.value = value
	GlobalVariables.set_match_time_seconds(value)

func set_timer() -> void:
	var minutes = $CenterContainer/GridContainer/min_SpinBox.value * 60
	var seconds = $CenterContainer/GridContainer/sec_SpinBox.value
	var seconds_total = minutes + seconds
	print(seconds_total)
	GlobalVariables.set_match_time(seconds_total)
