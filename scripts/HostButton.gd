extends Button

@export var world: Node2D


func _on_pressed():
	world.client_host($"../PortEntry".text, $"../Username Entry".text)
