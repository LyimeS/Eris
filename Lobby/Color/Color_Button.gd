extends Button


export var color_number: int

func _ready():
	text = GlobalVariables.COLOR_LIST[color_number]

