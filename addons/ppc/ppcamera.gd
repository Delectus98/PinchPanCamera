"""
  _____ _            _       _____            
 |  __ (_)          | |     |  __             
 | |__) | _ __   ___| |__   | |__) |_ _ _ __  
 |  ___/ | '_ | / __| '_ |  |  ___/ _` | '_ | 
 | |   | | | | | (__| | | | | |  | (_| | | | |
 |_|   |_|_| |_| ___|_| |_| |_|    __,_|_| |_|
   _____                               
  / ____|                              
 | |     __ _ _ __ ___   ___ _ __ __ _ 
 | |    / _` | '_ ` _ | / _ | '__/ _` |
 | |___| (_| | | | | | |  __/ | | (_| |
   _____ __,_|_| |_| |_| ___|_|   __,_|

A touchscreen optimized camera control system 
for common 2D top-down strategy games.

Licensed under MIT

v. 0.1

Author: Max Schmitt 
		from
		Divirad - Kepper, Lösing, Schmitt GbR
"""

extends Position2D
class_name PinchPanCamera, "icon.png"

export var enable : bool = true
export var natural_slide : bool = true
export var current : bool = true
export var smoothing : bool = false
export var smoothing_speed : int = 10
export var min_zoom_factor : float = 0.6
export var max_zoom_factor: float = 2
export var drag_deadzone_x : float = 0.1
export var drag_deadzone_y : float = 0.1
export var show_debug_icon : bool = false

export var limit_top : int = -10000000
export var limit_left : int = -10000000
export var limit_right : int = 10000000
export var limit_bottom : int = 10000000
export var limit_smoothed : bool = true

var shop
var start_position 
var already_pressed = false
var min_zoom : Vector2 = Vector2(0, 0)
var max_zoom : Vector2 = Vector2(0, 0)
var naturalizer = 1

var camera : Camera2D

signal zoom_in()
signal zoom_out()
signal just_pressed()
signal dragging()

signal input_number(num)

func _enter_tree():
	"""
	initializes all the export variables 
	"""
	
	min_zoom = Vector2(min_zoom_factor, min_zoom_factor)
	max_zoom = Vector2(max_zoom_factor, max_zoom_factor)
	
	var c = load("res://addons/ppc/camera.tscn")
	add_child(c.instance())
	camera = get_node("camera")
	
	camera.drag_margin_left = drag_deadzone_x
	camera.drag_margin_right = drag_deadzone_x
	camera.drag_margin_top = drag_deadzone_y
	camera.drag_margin_bottom = drag_deadzone_y
	
	camera.current = current
	camera.smoothing_enabled = smoothing
	camera.smoothing_speed = smoothing_speed
	
	set_limit(limit_top, limit_left, limit_right, limit_bottom, limit_smoothed);
	
	if show_debug_icon:
		var di = load("res://addons/ppc/testicon.tscn")
		add_child(di.instance())

func _process(_delta):
	if camera.drag_margin_left != drag_deadzone_x \
	and camera.drag_margin_right != drag_deadzone_x:
		camera.drag_margin_left = drag_deadzone_x
		camera.drag_margin_right = drag_deadzone_x
	
	if camera.drag_margin_top != drag_deadzone_y \
	and camera.drag_margin_bottom != drag_deadzone_y:
		camera.drag_margin_top = drag_deadzone_y
		camera.drag_margin_bottom = drag_deadzone_y
	
	if camera.current != current:
		camera.current = current
		
	if smoothing != camera.smoothing_enabled:
		camera.smoothing_enabled = smoothing

	if camera.smoothing_speed != smoothing_speed:
		camera.smoothing_speed = smoothing_speed

	if min_zoom != Vector2(min_zoom_factor, min_zoom_factor):
		min_zoom = Vector2(min_zoom_factor, min_zoom_factor)

	if max_zoom != Vector2(max_zoom_factor, max_zoom_factor):
		max_zoom = Vector2(max_zoom_factor, max_zoom_factor)
	
	if natural_slide and naturalizer != 1:
		naturalizer = 1
	elif !natural_slide and naturalizer != -1:
		naturalizer = -1

var required_pressed_button = false
var required_released_button = false
func _input(event):
	if !enable:
		return
	
	# Handle MouseWheel for Zoom
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP and event.is_pressed():
			emit_signal("zoom_in")
			if camera.zoom >= min_zoom:
				camera.zoom -= Vector2(0.1, 0.1)
		if event.button_index == BUTTON_WHEEL_DOWN and event.is_pressed():
			emit_signal("zoom_out")
			if camera.zoom <= max_zoom:
				camera.zoom += Vector2(0.1, 0.1)
		required_pressed_button = (event.is_pressed() && event.button_index == BUTTON_LEFT)
		required_released_button = (!event.is_pressed() && event.button_index == BUTTON_LEFT)
	
	# Handle Touch
	if required_pressed_button and !already_pressed:
		emit_signal("just_pressed")
		start_position = get_norm_coordinate() * naturalizer
		already_pressed = true
	if required_released_button:
		already_pressed = false

	# Handles ScreenDragging
	if already_pressed:
		if camera.input_count == 1:
			emit_signal("dragging")
			if natural_slide:
				position += get_movement_vector_from(get_local_mouse_position())
				start_position = get_local_mouse_position()
			else:
				var coord = get_movement_vector_from(-get_norm_coordinate())
				position += coord
	# Handles releasing
	if  camera.input_count == 0:
		position = camera.get_camera_center() 
		

func get_movement_vector_from(vec : Vector2) -> Vector2:
	"""
	calculates a vector for the movement
	"""
	return start_position - vec 

func get_norm_coordinate() -> Vector2:
	"""
	gets the normalized coordinate of a touch
	"""
	if natural_slide:
		return get_global_mouse_position() - camera.get_camera_center()
	else:
		return get_local_mouse_position() - camera.get_camera_center()
		
func invert_vector(vec : Vector2):
	"""
	inverts a vector
	"""
	return Vector2(-vec.x, -vec.y)
	
func set_limit(top, left, right, bottom, smoothed = true):
	camera.limit_top = limit_top
	camera.limit_left = limit_left
	camera.limit_right = limit_right
	camera.limit_bottom = limit_bottom
	camera.limit_smoothed = limit_smoothed

