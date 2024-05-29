extends Node2D

@export var number_of_stars: int
@export var system_scene: PackedScene

var galaxy_gen = load("res://scripts/galaxy_generation.gd").new()

var stars
var system


func _ready():
	pass

func draw_stars(highlights = []):
	Global.print_console("Drawing Stars")
	for star in stars:
		system = system_scene.instantiate()
		system.position = star.position
		
		if star.index in highlights:
			var dot = system.get_node("sprite_dot")
			dot.modulate = Color(0, 1, 0, 1)
			system.set_meta("is_highlighted", true)
		else:
			system.set_meta("is_highlighted", false)
		
		var label = system.get_node("Label")
		label.text = str(star.index)
		system.z_index = 1
		
		system.system_clicked.connect(_on_System_clicked)
		
		add_child(system)


func draw_links():
	Global.print_console("Drawing Links")
	for star in stars:
		for linked_star_index in star.links:
			var line = Line2D.new()
			line.width = 2
			line.default_color = Color(1, 1, 1, 0.5)
			line.points = [star.position, stars[linked_star_index].position]
			add_child(line)


func _on_System_clicked(index):
	pass


func _generate_galaxy(num_stars):
	stars = galaxy_gen.generate_galaxy(num_stars)
	draw_stars()
	draw_links()


func send_stars(player_id):
	set_stars.rpc_id(player_id, stars)


@rpc("reliable")
func set_stars(new_stars):
	stars = new_stars
	draw_stars()
	draw_links()
