extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var shader_color: Color

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Host_Missing_Screen_visibility_changed():
	if visible:
		# set the color of host player to host missing animation
		if Network.players.has(1) and Network.players[1].has("color_number"):
			shader_color = GlobalVariables.SHADER_COLOR_LIST[Network.players[1]["color_number"]]
		else:
			shader_color = GlobalVariables.SHADER_COLOR_LIST[0]
	
		$Actor/Sprite.material.set_shader_param("NEWCOLOR1", shader_color)

func _on_ButtonX_pressed():
	visible = false


func _on_ButtonHome_pressed():
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://GUI/Lobby_v2/Lobby_v2.tscn")
