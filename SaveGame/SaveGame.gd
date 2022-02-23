extends Node

var save_data: Dictionary = {}

# this might change depending on the Operating System
const SAVEGAME : String = "user://Savegame.json"

func _ready() -> void:
	save_data = get_data()

func get_data():
	print("getting data...")
	var file: File = File.new()
	if not file.file_exists(SAVEGAME):
		save_data = {"Player_name":"Unnamed", 
					"Light":false,
					"Main_vol":0,
					"Music_vol":0,
					"VFX_vol":0}
		save_game()
	# warning-ignore:return_value_discarded
	file.open(SAVEGAME, File.READ)
	var content = file.get_as_text()
	var data = parse_json(content)
	save_data = data
	file.close()
	data = check_values(data)
	print(data)
	return(data)


func save_game() -> void:
	print("saving data: ", save_data)
	var save_game : File = File.new()
	# warning-ignore:return_value_discarded
	save_game.open(SAVEGAME, File.WRITE)
	save_game.store_line(to_json(save_data))

func check_values(data) -> Dictionary:
	if not data.has("Main_vol"):
		print("Main_vol not found")
		data["Main_vol"] = 0
	if not data.has("Music_vol"):
		print("Music_vol not found")
		data["Music_vol"] = 0
	if not data.has("VFX_vol"):
		print("VFX_vol not found")
		data["VFX_vol"] = 0
	return data
