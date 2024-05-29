extends Node

# Reference to the ConsoleText RichTextLabel.
var console_text : RichTextLabel = null

var host = null
var players = {}

func _ready():
	console_text = get_node("/root/world/CanvasLayer/Chatbox/VBoxContainer/ChatboxPanel/VBoxContainer/ConsoleText")

func print_console(message):
	
	var time = Time.get_time_dict_from_system()
	var timestamp = "[color=#808080][%02d:%02d:%02d][/color]" % [time["hour"], time["minute"], time["second"]]
	
	var formatted_message = timestamp + " [color=#ffffff]" + message + "[/color]"
	
	#print(formatted_message)  # This will print the message with the timestamp to the debug console without BBCode.
	
	if console_text:
		console_text.append_text(formatted_message + "\n")



