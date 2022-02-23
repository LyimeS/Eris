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
	volume_changed()


func _on_ButtonMainVolUp_pressed():
	AudioServer.set_bus_volume_db(0,AudioServer.get_bus_volume_db(0) +1)
	volume_changed()

func _on_ButtonVolMusicDown_pressed():
	AudioServer.set_bus_volume_db(1,AudioServer.get_bus_volume_db(1) -1)
	volume_changed()

func _on_ButtonVolMusicUp_pressed():
	AudioServer.set_bus_volume_db(1,AudioServer.get_bus_volume_db(1) +1)
	volume_changed()

func _on_ButtonVolSFXDown_pressed():
	AudioServer.set_bus_volume_db(2,AudioServer.get_bus_volume_db(2) -1)
	volume_changed()

func _on_ButtonVolSFXUp_pressed():
	AudioServer.set_bus_volume_db(2,AudioServer.get_bus_volume_db(2) +1)
	volume_changed()

func volume_changed()-> void:
	SaveGame.save_data["Main_vol"] = AudioServer.get_bus_volume_db(0)
	SaveGame.save_data["Music_vol"] = AudioServer.get_bus_volume_db(1)
	SaveGame.save_data["VFX_vol"] = AudioServer.get_bus_volume_db(2)
	SaveGame.save_game()
	print("saving settings")

func _on_ButtonClose_pressed():
	hide()
