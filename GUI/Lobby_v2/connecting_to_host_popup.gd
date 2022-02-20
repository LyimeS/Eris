extends Popup


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var texture_looking_right = load("res://Assets/sprites/character_v2_looking_right.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	#visible = true
	var shader_color = GlobalVariables.SHADER_COLOR_LIST[randi() % GlobalVariables.SHADER_COLOR_LIST.size()]
	$MarginContainer/MarginContainer2/CenterContainer/VBoxContainer/Actor/Sprite.material.set_shader_param("NEWCOLOR1", shader_color)
	$MarginContainer/MarginContainer2/CenterContainer/VBoxContainer/Actor/Sprite.texture = texture_looking_right
	$MarginContainer/MarginContainer2/CenterContainer/VBoxContainer/Actor/AnimationPlayer.play("walk")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
