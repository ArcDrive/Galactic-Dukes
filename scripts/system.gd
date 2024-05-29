extends Node2D

# define a signal that includes the system's index as an argument
signal system_clicked(index)

var dot
var ring
var text_highlight
var label

func _ready():
	# assuming the Area2D node's name is "Area2D"
	$Area2D.input_event.connect(_on_Area2D_input_event)

func _enter_tree():
	dot = $sprite_dot
	ring = $sprite_ring
	text_highlight = $"../text_highlight"
	label = $Label

func _on_Area2D_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_mask == MOUSE_BUTTON_MASK_LEFT:
		var index = int($Label.text)
		emit_signal("system_clicked", index)

func _process(_delta):
	if get_meta("is_highlighted"):
		return
	
	if text_highlight.text == label.text:
		dot.modulate = Color(1, 0, 1, 1)
	else:
		dot.modulate = Color(1, 1, 1, 1)



func _on_area_2d_mouse_entered():
	ring.visible = true


func _on_area_2d_mouse_exited():
	ring.visible = false
