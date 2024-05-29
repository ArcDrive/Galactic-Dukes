extends Control

@export var ConsoleText: Node
@export var GeneralText: Node
@export var FederationText: Node

@export var Chat_Line: Node

@export var ChatBoxContainer: Node
@export var ChatBoxSpacer: Node

@export var tabs: Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_tab_clicked(tab):
	ConsoleText.visible = false
	GeneralText.visible = false
	FederationText.visible = false
	match tab:
		0:
			ConsoleText.visible = true
		1:
			GeneralText.visible = true
		2:
			FederationText.visible = true
		_:
			Global.print_console("Unkown tab '" + tab + "' clicked!")


func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if Rect2(ChatBoxContainer.global_position, ChatBoxContainer.size).has_point(event.position):
			ChatBoxSpacer.visible = false
		else:
			ChatBoxSpacer.visible = true


func _on_line_edit_text_submitted(new_text):
	match (tabs.current_tab):
		0:
			pass
		1:
			receive_message.rpc(new_text)
			Chat_Line.text = ""
		2:
			pass
		_:
			Global.print_console("Unkown tab '" + tabs.current_tab + "' when text submitted.")


@rpc("any_peer", "call_local")
func receive_message(message):
	var formatted_message = "[color=#0000ff]%s[/color]: [color=#FFFFFF]%s[/color]" % [Global.players[multiplayer.get_remote_sender_id()].username, message]
	GeneralText.append_text(formatted_message + "\n")
