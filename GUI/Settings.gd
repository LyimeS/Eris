extends Popup


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ButtonMainVolDown_pressed():
	AudioServer.set_bus_volume_db(0,AudioServer.get_bus_volume_db(0) -1)

func _on_ButtonMainVolUp_pressed():
	AudioServer.set_bus_volume_db(0,AudioServer.get_bus_volume_db(0) +1)


func _on_ButtonClose_pressed():
	visible = false
