extends Button

@export var world: Node2D

func _on_pressed():
	world.client_join($"../AddressEntry".text, $"../PortEntry".text, $"../Username Entry".text)
