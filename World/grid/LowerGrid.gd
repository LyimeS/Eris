extends TileMap

var max_cell

func _ready()-> void:
	print("lower_grid ready")
	
	for cell in get_used_cells():
		max_cell = cell
	print("max_cell: ", max_cell)
	get_parent().get_node("Grid").max_cell = max_cell
	
func count_cells(color_number: int) -> int:
	var colored_cells : int = 0
	
	for cell in get_used_cells():
		if get_cell(cell.x, cell.y) == color_number:
			colored_cells += 1
	return colored_cells

