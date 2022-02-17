extends "res://pawns/pawn.gd"


#var object_type: String = "Vertical Fill"
#var object_type: String = "Horizontal Fill"
#var object_type: String = "Move Blocker"
var object_type: String = "Turn Off Lights Trap"

func _ready():
	$Spawn.play()
