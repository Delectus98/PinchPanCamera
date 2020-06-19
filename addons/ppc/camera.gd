extends Camera2D

#var points : Array = []
var point = {pos = Vector2(), start_pos = Vector2(), state = false}

var last_dist = 0
var current_dist = 0
var zoom_rate = 0.1
var zoom_started : bool = false
var drag_started = false
var input_count = 0

signal on_zoom(val)

func _ready():
	pass

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		point.pos = event.position
		
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		point.state = event.pressed
		point.pos = event.position
		if event.pressed:
			point.start_pos = event.position
			
	var count = 0
	if point.state:
		count = 1
	
	input_count = count
	
func get_camera_center():
	var vtrans = get_canvas_transform()
	var top_left = -vtrans.get_origin() / vtrans.get_scale()
	var vsize = get_viewport_rect().size
	return top_left + 0.5 * vsize/vtrans.get_scale()
