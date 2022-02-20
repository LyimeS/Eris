extends Node


const COLORS: Array = [1, 2, 3, 4]
const COLOR_LIST: Array = ["null", 
							"Blue", 
							"Green", 
							"Yellow", 
							"Red"]

const SHADER_COLOR_LIST: Array = [Color.white, 
							Color("0341b5"), 
							Color("21b039"), 
							Color("ffc61a"), 
							Color("ee113d")]

var object_type: Array = ["Vertical Fill", 
						"Horizontal Fill", 
						"Move Blocker Trap", 
						"Move Blocker", 
						"Turn Off Lights Trap"]

sync var light_mode: bool
func set_light_mode(value):
	rset("light_mode", value)
	print("light mode: ",light_mode )
	

# time variables
sync var minutes: int
func set_match_time_minutes(value):
	rset("minutes", value)

sync var seconds: int
func set_match_time_seconds(value):
	rset("seconds", value)

sync var match_time: int
func set_match_time(value):
	rset("match_time", value)

