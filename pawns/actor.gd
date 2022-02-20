extends "pawn.gd"

onready var Grid = get_parent()
var player_id : int
var color_number: int
sync var can_move: bool = true
sync var has_light: bool = true

var match_timer: Timer
var timer_is_set: bool = false

var texture_looking_right = load("res://Assets/sprites/character_v2_looking_right.png")
var texture_looking_down = load("res://Assets/sprites/character_v2_looking front.png")
var texture_looking_up = load("res://Assets/sprites/character_v2_eyes_closed.png")

func _ready():
	color_number = Network.players[player_id]["color_number"]
	$Name.text = Network.players[player_id]["Player_name"]
	update_look_direction(Vector2(1, 0))
	add_to_group("notify_players")
	
	if Network.local_player_id != player_id:
		print(name, "is not local player. player id: ", player_id)
		$Camera2D.queue_free()
	else:
		#print("setting camera to current. player: ", name, ". playerid: ", player_id)
		$Camera2D.current = true
	if GlobalVariables.light_mode == true:
		$Light2D.visible = false
	
	var shader_color = GlobalVariables.SHADER_COLOR_LIST[Network.players[player_id]["color_number"]]
	$Sprite.material.set_shader_param("NEWCOLOR1", shader_color)

# warning-ignore:unused_argument
func _process(delta):
	if get_node_or_null("Camera2D") != null:
		$Camera2D.current = true
		timer_update()
		
	if not can_move:
		$Sprite.visible = false
		$cannot_move_sprite.visible = true
	else:
		$Sprite.visible = true
		$cannot_move_sprite.visible = false
	
	if not has_light or GlobalVariables.light_mode == true:
		$Light2D.visible = false
	else:
		$Light2D.visible = true
	
	if player_id == Network.local_player_id:
		var input_direction = get_input_direction()
		if not input_direction:
			return
		rpc("update_look_direction", input_direction)
		
		# prevent player of sending move request
		# while the previous one isn't completly processed
		set_process(false)
		
		if Network.local_player_id == 1:
			req_movement(player_id, input_direction)
		else:
			rpc_id(1, "req_movement", player_id, input_direction)
		

remote func req_movement(rec_player_id, input_direction) -> void:
	#print("player ", rec_player_id, " requested to move")
	var target_position = Grid.request_move(rec_player_id, input_direction)
	if target_position:
		rpc("move_to",target_position)
	else:
		rpc("bump")

func get_input_direction() -> Vector2:
	return Vector2(
		int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")),
		int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	)

sync func update_look_direction(direction) -> void:
	#$Sprite.rotation = direction.angle()
	#$cannot_move_sprite.rotation = direction.angle()
	
	#print(direction)
	if direction == Vector2(-1, 0): 
		#print("looking left")
		$Sprite.texture = texture_looking_right
		$Sprite.flip_h = true
	if direction == Vector2(1, 0): 
		#print("looking right")
		$Sprite.texture = texture_looking_right
		$Sprite.flip_h = false
	if direction == Vector2(0, -1): $Sprite.texture = texture_looking_up
	if direction == Vector2(0, 1): $Sprite.texture = texture_looking_down

# called by host on req_movement
sync func move_to(target_position) -> void:
	set_process(false)
	$AnimationPlayer.play("walk")

	# Move the node to the target cell instantly,
	# and animate the sprite moving from the start to the target cell	
	$Tween.interpolate_property(
		self,"position",
		position,target_position,
		$AnimationPlayer.current_animation_length,
		Tween.TRANS_LINEAR, Tween.EASE_IN
	)

	$Tween.start()
	# Stop the function execution until the animation finished
	yield($AnimationPlayer, "animation_finished")
	set_process(true)

# called by host on req_movement
sync func bump() -> void:
	set_process(false)
	$AnimationPlayer.play("bump")
	yield($AnimationPlayer, "animation_finished")
	set_process(true)

func set_can_move(value) -> void:
	rset("can_move", value)

func set_has_light(value) -> void:
	rset("has_light", value)

# called by grid's object_handling calling a group
func notify(player, action) -> void:
	rpc("sync_notify", player, action)

# called by grid's object_handling
sync func sync_notify(player, action) -> void:
	if get_node_or_null("Camera2D") == null:
		return
	print("player: ", Network.players[player]["Player_name"], " ", action)
	var _notification_scene = load("res://GUI/Notification.tscn")
	var _notification = _notification_scene.instance()
	$Camera2D/notification_container.add_child(_notification)
	var animation : AnimationPlayer = _notification.get_node("AnimationPlayer")
	_notification.get_node("Panel").get_node("Notification_Text").text = str(Network.players[player]["Player_name"]) + " " + action
	animation.play("only")
	yield(animation, "animation_finished")
	_notification.queue_free()

func timer_set() -> void:
	timer_is_set = true
	match_timer = get_tree().root.get_node("Game/match_timer")

func timer_update() -> void:
	if timer_is_set:
		var seconds : int = int(match_timer.get_time_left())
		# warning-ignore:integer_division
		var a = "%02d" % [int(seconds/3600)]
		# warning-ignore:integer_division
		var b = "%02d" % [int((seconds%3600)/60)]
		var c = "%02d" % [int((seconds%3600)%60)]
		#print(a, ":", b, ":", c)
		$Camera2D/VBoxContainer/Match_timer.text = str(a, ":", b, ":", c)
		#$Control/VBoxContainer/Label.text = str(a, ":", b, ":", c)

# caled by grid.gd, on object_handling
func play_power_up() -> void:
	$PowerUp.play()

# caled by grid.gd, on object_handling
func play_trap() -> void:
	$ItsATrapBino.play()
