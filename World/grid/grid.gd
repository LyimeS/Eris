extends TileMap

enum { EMPTY = -1, ACTOR, OBSTACLE, OBJECT}
var y_pos = 100
var max_cell #set by lowerGrid when _ready

#var match_time: int = 60
var match_time = GlobalVariables.match_time

#var wait_object_spawn: GDScriptFunctionState

func _ready() -> void:
	randomize()
	# warning-ignore:return_value_discarded
	Network.connect("ready_to_spawn", self, "ready_to_spawn")
	print("grid ready")
	Network.raise_ready_to_start()
	
func ready_to_spawn() -> void:
	if Network.local_player_id == 1:
		print("resuming _ready")
		sort_players()
		rpc("set_collisions")
		set_object_spawn_timer()
		rpc("match_timer")

# called by request_move
func get_cell_pawn(coordinates): #not hard typed function
	print("caled get_cell_pawn to check: ", coordinates)
	# called when hitting an object or player. doesn't detect walls. 
	for node in get_children():
		if world_to_map(node.position) == coordinates:
			#print("it has this node: ", node)
			return(node)

# caled by the player (actor.gd)
func request_move(player_id, direction): #not hard typed function
	# get the node based on it's ID
	var pawn # means "player"
	for node in get_children():
		if node.get("player_id") == player_id:
			pawn = node
	if pawn == null:
		print("ID NOT FOUND: ", player_id)
	
	if not pawn.can_move: #player blocked by object "Move Blocker"
		return # end this function if player cannot move
	
	var cell_start = world_to_map(pawn.position)
	var cell_target = cell_start + direction
	
	var cell_target_type = get_cellv(cell_target) #returns a number
	match cell_target_type: # don't know how this works
		EMPTY:
			rpc("color_cell", cell_target, pawn.color_number)
			return update_pawn_position(pawn, cell_start, cell_target)
		OBJECT:
			rpc("color_cell", cell_target, pawn.color_number)
			var object_pawn = get_cell_pawn(cell_target)
			print("object_type: ", object_pawn.object_type)
			object_handling(object_pawn.object_type, cell_target, pawn)
			#print("object name: ", object_pawn.name )
			rpc("object_queue_free", cell_target)
			return update_pawn_position(pawn, cell_start, cell_target)
		ACTOR:
			var actor = get_cell_pawn(cell_target)
			if actor == null: #make sure the player is still there
				print("actor null cell skipped")
				return
			else:
				var pawn_name = actor.name
				print("Cell %s contains %s" % [cell_target, pawn_name])
				get_parent().get_node("LowerGrid").count_cells(1)
		OBSTACLE:
			print("unforeseen obstacle at ", cell_target)
	
# caled by the Request_move
func update_pawn_position(pawn, cell_start, cell_target):
	set_cellv(cell_target, pawn.type)
	set_cellv(cell_start, EMPTY)
	return map_to_world(cell_target) + cell_size / 2

# called by host on request_move
sync func color_cell(cell_target, color_number) -> void:
	get_parent().get_node("LowerGrid").set_cell(cell_target.x, cell_target.y, color_number)

# called by host when ready_to_spawn
func sort_players() -> void:
	var copy_players: Array = []
	
	for player in Network.players:
		copy_players.append(player)
	copy_players.shuffle()
	#print("shuffled list: ", copy_players)
	
	for player_id in copy_players:
		rpc("add_player", player_id)


# called by host when grid is _ready
sync func add_player(player_id) -> void:
	print("adding player ", player_id, " to scene")
	var player_scene = load("res://pawns/Actor.tscn")
	var player = player_scene.instance()
	player.player_id = player_id
	player.position = map_to_world(world_to_map(Vector2(100, y_pos))) + cell_size / 2
	add_child(player)
	y_pos += 60
	


# called by host when grid is _ready
sync func set_collisions() -> void: 
	print("setting collisions")
	for child in get_children():
		# this sets the sprite bellow players and set their collisions
		# ^ not sure about that anymore
		set_cellv(world_to_map(child.position), child.type)
		print("position: ", child.position, ", child type: ", child.type)

# called by request_move when hitting an object
func object_handling(object_type, cell_target, pawn):
	match object_type:
		"Vertical Fill":
			#print("max_cell:  ",max_cell)
			pawn.play_power_up()
			for cell_y in range(max_cell.y + 1):
				if get_cellv(Vector2(cell_target.x, cell_y)) == -1:
					rpc("color_cell", Vector2(cell_target.x, cell_y), pawn.color_number)
		"Horizontal Fill":
			#print("max_cell:  ",max_cell)
			pawn.play_power_up()
			for cell_x in range(max_cell.x + 1):
				if get_cellv(Vector2(cell_x, cell_target.y)) == -1:
					rpc("color_cell", Vector2(cell_x, cell_target.y), pawn.color_number)
		"Move Blocker Trap":
			pawn.play_trap()
			pawn.set_can_move(false)
			get_tree().call_group("notify_players", "notify", pawn.player_id, "stepped on a trap, and is now blocked")
			yield(get_tree().create_timer(5), "timeout") # change it to a regular timer
			pawn.set_can_move(true)
			print("player can now move")
		"Move Blocker":
			pawn.play_power_up()
			print("blocking other players:")
			for node in get_children():
				if node.get("player_id") and node.player_id != pawn.player_id:
					node.set_can_move(false)
			get_tree().call_group("notify_players", "notify", pawn.player_id, "blocked everyone")
			yield(get_tree().create_timer(5), "timeout") # change it to a regular timer
			for node in get_children():
				if node.get("player_id"):
					node.set_can_move(true)
		"Turn Off Lights Trap":
			pawn.play_trap()
			pawn.set_has_light(false)
			get_tree().call_group("notify_players", "notify", pawn.player_id, "stepped on a trap, has its light off")
			yield(get_tree().create_timer(5), "timeout") # change it to a regular timer
			pawn.set_has_light(true)
			print("player can now move")

sync func object_queue_free(cell_target):
	for node in get_children():
		if world_to_map(node.position) == cell_target:
			node.queue_free()


# called when ready_to_spawn. acts in loop.
func set_object_spawn_timer() -> void:
	var time: float= rand_range(10, 15)
	print("timer of ", time, " seconds")
	
	var timer: Timer = Timer.new()
	get_parent().call_deferred("add_child", timer)
	timer.autostart = true
	timer.wait_time = 3.5
	timer.name = "object_spawn_timer"
	# warning-ignore:return_value_discarded
	timer.connect("timeout", self, "object_spawn_timeout")

func object_spawn_timeout():
	print("time to spawn object")
	# do not set the list below as array type!
	var rand_object_type = GlobalVariables.object_type
	rand_object_type.shuffle()
	rand_object_type = rand_object_type[0]
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var pos_x = rng.randi_range(60, 1200)
	var pos_y = rng.randi_range(60, 800)
	print("object spawn position: ", pos_x , ", ", pos_y)
	var _position = map_to_world(world_to_map(Vector2(pos_x, pos_y))) + cell_size / 2

	if get_cellv(world_to_map(_position)) != -1:
		print("cell not empty. skipping spawn")
	else:
		print("empty cell. spawning object")
		rpc("spawn_object", _position, rand_object_type)
	
sync func spawn_object(_position, rand_object_type) -> void:
	var object_scene = load("res://World/Objects/Object.tscn")
	var object = object_scene.instance()
	object.position = _position
	object.object_type = rand_object_type
	add_child(object)
	if Network.local_player_id == 1:
		set_cellv(world_to_map(object.position), 2)


sync func match_timer() -> void: # setup of the timer to the end of this world
	var timer: Timer = Timer.new()
	timer.set_wait_time(match_time)
	timer.name = "match_timer"
	timer.set_one_shot(true) # set the timer to run only once
	# warning-ignore:return_value_discarded
	timer.connect("timeout",self,"_on_match_timer_timeout")
	get_parent().call_deferred("add_child", timer) # add the timer to the world. otherwise it won't run
	timer.autostart = true
	print("match timer set")
	get_tree().call_group("notify_players", "timer_set")

sync func _on_match_timer_timeout() -> void:
	print("match timer ended")
	for player in Network.players:
		Network.players[player]["score"] = get_parent().get_node("LowerGrid").count_cells(Network.players[player]["color_number"])
	print("score:", Network.players)
	# warning-ignore:return_value_discarded
	#get_tree().change_scene("res://GUI/End_Game_Screen.tscn")
	get_tree().change_scene("res://GUI/End_Game_Screen_v2.tscn")
