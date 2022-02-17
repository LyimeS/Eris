extends Node


var music_list: Array = ["res://Assets/Audio/Music/USSR.mp3", 
						"res://Assets/Audio/Music/Creepy Comedy.mp3",
						"res://Assets/Audio/Music/Jungle Mission.mp3"]



# Called when the node enters the scene tree for the first time.
func _ready():
	if GlobalVariables.light_mode == true:
		$CanvasModulate.queue_free()
		print("removing ", GlobalVariables.object_type[4])
		GlobalVariables.object_type.remove(4)
	else:
		$CanvasModulate.visible = true
	
	if Network.local_player_id == 1:
		print("host picking music")
		set_music()


# Called every frame. 'delta' is the elapsed time since the previous frame.
# warning-ignore:unused_argument
func _process(delta):
	pass

func set_music():
	var index = randi() % music_list.size()
	rpc("play_music", index)

sync func play_music(index: int) -> void:
	var music: AudioStreamMP3 = load(music_list[index])
	$AudioStreamPlayer.set_stream(music)
	$AudioStreamPlayer.play()
