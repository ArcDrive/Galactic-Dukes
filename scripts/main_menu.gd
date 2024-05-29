extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$CanvasLayer/MainMenu/MarginContainer/VBoxContainer/HostButton.pressed.connect(_on_HostButton_pressed)
	$CanvasLayer/MainMenu/MarginContainer/VBoxContainer/JoinButton.pressed.connect(_on_JoinButton_pressed)

func _on_HostButton_pressed():
	get_tree().change_scene_to_file("res://scenes/server_main.tscn")

func _on_JoinButton_pressed():
	get_tree().change_scene_to_file("res://scenes/client_main.tscn")
