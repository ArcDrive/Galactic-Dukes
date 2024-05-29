extends Node

var stars = []

var intersection_cache = []

func generate_galaxy(num_stars):
	#fill cache with empty arrays
	for i in range(num_stars):
		intersection_cache.append([])
	
	#generate_stars_on_grid()
	generate_random_stars(num_stars)
	link_stars()
	var galaxy_clusters = cluster_stars(num_stars)
	link_all_clusters(galaxy_clusters)
	connect_endpoints(find_endpoints(num_stars))
	
	return stars
	

func generate_stars_on_grid(num_stars):
	Global.print_console("Generating galaxy on grid")
	
	var inner_radius = 500
	var outer_radius = 1000
	var grid_size_w = 75 # Number of spokes
	var grid_size_l = 5   # Number of rings
	
	@warning_ignore("integer_division")
	var radial_step = (outer_radius - inner_radius) / grid_size_l
	var angular_step = 2 * PI / grid_size_w
	
	for i in range(num_stars):
		print("Placing star " + str(i))
		
		var star_placed = false
		while not star_placed:
			var angle = randi() % grid_size_w * angular_step
			var distance = inner_radius + randi() % grid_size_l * radial_step
			
			var new_star_position = Vector2(
				distance * cos(angle),
				distance * sin(angle)
			)
			
			var position_is_unique = true
			for star in stars:
				if star.position == new_star_position:  # Check if positions match
					position_is_unique = false
					break
			
			if position_is_unique:
				var new_star = { "index": i, "position": new_star_position, "links": [] }
				stars.append(new_star)
				star_placed = true

func generate_random_stars(num_stars):
	Global.print_console("Generating galaxy using random points")
	
	var inner_radius = 500
	var outer_radius = 1000
	var min_distance = 50
	
	var new_star_position
	
	for i in range(num_stars):
		
		print("Placing star " + str(i))
		
		var too_close = true
		
		while too_close:
			var angle = randf() * 2 * PI
			var distance = inner_radius + randf() * (outer_radius - inner_radius)
			
			new_star_position = Vector2(
				distance * cos(angle),
				distance * sin(angle)
			)
			
			too_close = false
			for star in stars:
				if new_star_position.distance_to(star.position) < min_distance:
					too_close = true
					break
		
		var new_star = { "index": i, "position": new_star_position, "links": [] }
		stars.append(new_star)

func link_stars():
	Global.print_console("Linking galaxy")
	var max_links = 3
	var additional_links

	for star in stars:
		if star.links.size() < 2:
			for i in range(2 - star.links.size()):
				var closest_star = get_closest_star(star, star.links + [star.index])
				if closest_star:
					link_two_stars(star, closest_star)
		additional_links = min(max_links - star.links.size(), randi() % max_links)
		for i in range(additional_links):
			var close_star = get_closest_star(star, star.links + [star.index])
			if close_star:
				link_two_stars(star, close_star)

func get_closest_star(star, exclude_indexes=[]):
	
	#print("Getting closest star. Star = " + str(star.index) + " || Exclude = " + str(exclude_indexes))
	
	var closest_star = null
	var closest_distance = INF
	for other_star in stars:
		if other_star.index not in exclude_indexes:
			var distance = star.position.distance_to(other_star.position)
			if distance < closest_distance:
				if !check_intersection(star, other_star):
					closest_star = other_star
					closest_distance = distance
	#print("Closes star is: " + str(closest_star))
	return closest_star

func link_two_stars(star1, star2):
	print("Linking star " + str(star1.index) + " to star " + str(star2.index))
	if star2 not in star1.links:
		star1.links.append(star2.index)
	if star1 not in star2.links:
		star2.links.append(star1.index)

func line_intersection(line1, line2):
	var p = line1[0]
	var p2 = line1[1]
	var q = line2[0]
	var q2 = line2[1]
	
	var r = p2 - p
	var s = q2 - q
	
	var denom = r.cross(s)
	if denom == 0:
		return false
	
	var t = (q - p).cross(s) / denom
	var u = (q - p).cross(r) / denom
	
	if (t >= 0 and t <= 1 and u >= 0 and u <= 1):
		return true
	else:
		return false

func check_intersection(star1, star2):
	if star2.index in intersection_cache[star1.index] or star1.index in intersection_cache[star2.index]:
		return true
	
	var new_line = [star1.position, star2.position]
	for star in stars:
		for link in star.links:
			var existing_line = [star.position, stars[link].position]
			if new_line[0] == existing_line[0] or new_line[0] == existing_line[1] or new_line[1] == existing_line[0] or new_line[1] == existing_line[1]:
				continue
			if line_intersection(existing_line, new_line):
				intersection_cache[star1.index].append(star2.index)
				intersection_cache[star2.index].append(star1.index)
				return true
	
	var rads = deg_to_rad(30)
	var vec_direction = star2.position - star1.position
	var vec2_direction
	
	for link in star1.links:
		vec2_direction = stars[link].position - star1.position
		if abs(vec_direction.angle_to(vec2_direction)) < rads:
			#print("Angle check returned false between stars " + str(star1.index) + " and " + str(star2.index))
			#print("The angle between the new link and the link from " + str(star1.index) + " to " + str(link) + " is " + str(rad_to_deg(vec_direction.angle_to(vec2_direction))))
			intersection_cache[star1.index].append(star2.index)
			intersection_cache[star2.index].append(star1.index)
			return true
	
	vec_direction = star1.position - star2.position
	
	for link in star2.links:
		vec2_direction = stars[link].position - star2.position
		if abs(vec_direction.angle_to(vec2_direction)) < rads:
			#print("Angle check returned false between stars " + str(star1.index) + " and " + str(star2.index))
			#print("The angle between the new link and the link from " + str(star2.index) + " to " + str(link) + " is " + str(rad_to_deg(vec_direction.angle_to(vec2_direction))))
			intersection_cache[star1.index].append(star2.index)
			intersection_cache[star2.index].append(star1.index)
			return true
	
	return false

func cluster_stars(num_stars):
	Global.print_console("Sorting stars into clusters")
	var clusters = []
	var unvisited = range(num_stars)
	
	while unvisited.size() > 0:
		var cluster = []
		var queue = [unvisited[0]]
		
		while queue.size() > 0:
			var current = queue.pop_front()
			unvisited.erase(current)
			cluster.append(current)
			
			for link in stars[current].links:
				if link in unvisited and link not in queue:
					queue.append(link)
		clusters.append(cluster)
	print("Number of clusters: " + str(clusters.size()))
	return clusters

func link_clusters(clusters):
	if clusters.size() <= 1:
		return clusters
	
	var first_cluster = clusters[0]
	var closest_cluster = null
	var closest_cluster_index = -1
	var min_distance = INF
	
	# Find closest cluster
	for i in range(1, clusters.size()): # Skip first cluster
		var cluster = clusters[i]
		for star1_index in first_cluster:
			for star2_index in cluster:
				var distance = stars[star1_index].position.distance_to(stars[star2_index].position)
				if distance < min_distance:
					min_distance = distance
					closest_cluster = cluster
					closest_cluster_index = i
	
	if closest_cluster == null:
		print("ERROR IN LINK_CLUSTERS: No other clusters found")
		return clusters
	
	# Find closest pair of stars between two clusters
	min_distance = INF
	var star1_to_link = null
	var star2_to_link = null
	for star1_index in first_cluster:
		for star2_index in closest_cluster:
			if check_intersection(stars[star1_index], stars[star2_index]) == false:
				var distance = stars[star1_index].position.distance_to(stars[star2_index].position)
				if distance < min_distance:
					min_distance = distance
					star1_to_link = star1_index
					star2_to_link = star2_index
	
	# Link two stars
	if star1_to_link != null and star2_to_link != null:
		link_two_stars(stars[star1_to_link], stars[star2_to_link])
	
	# Merge two clusters
	clusters[0] = clusters[0] + closest_cluster
	clusters.remove_at(closest_cluster_index)
	
	return clusters

func link_all_clusters(clusters):
	Global.print_console("Linking clusters")
	while clusters.size() > 1:
		clusters = link_clusters(clusters)

func find_distance(src, dest, v):
	var queue = []
	var visited = []
	var pred = []
	var dist = []
	
	for i in range(v):
		visited.append(false)
		dist.append(INF)
		pred.append(-1)
	
	visited[src] = true
	dist[src] = 0
	queue.append(src)
	
	while queue.size() != 0:
		var u = queue.pop_front()
		for i in stars[u].links:
			if visited[i] == false:
				visited[i] = true
				dist[i] = dist[u] + 1
				pred[i] = u
				queue.append(i)
				
				if i == dest:
					return dist[dest]
	
	# if after exploring all reachable nodes we didn't find dest, then it's not connected
	return -1

func find_farthest_node(start_index, v):
	var max_distance = -1
	var farthest_node = -1
	
	for i in range(v):
		if i != start_index:  # avoid computing distance from the node to itself
			var distance = find_distance(start_index, i, v)
			if distance > max_distance:
				max_distance = distance
				farthest_node = i
				
	return farthest_node

func find_endpoints(v):
	var first_endpoint = find_farthest_node(0, v)
	var second_endpoint = find_farthest_node(first_endpoint, v)
	return [first_endpoint, second_endpoint]

func find_neighbors(start_index):
	var visited = []  # An array to keep track of visited nodes
	var queue = []  # A queue to keep track of nodes to visit
	var neighbors = []  # The resulting array of neighbor indexes
	
	visited.append(start_index)  # We start by visiting the root node
	queue.append(start_index)  # Add the root node to the queue
	neighbors.append(start_index)  # Add the root node to the neighbors
	
	while queue.size() != 0 and neighbors.size() < 10:  # We limit the neighbors to 10 nodes
		var current_index = queue.pop_front()  # Pop the first element from the queue
		var current_star = stars[current_index]
		
		for link in current_star.links:
			if link not in visited:  # Only if the node hasn't been visited
				visited.append(link)  # Mark it as visited
				queue.append(link)  # Add it to the queue
				neighbors.append(link)  # Add it to the neighbors
				if neighbors.size() >= 10:  # Stop when we have found 10 nodes
					break
					
	return neighbors

func connect_endpoints(points):
	var distance = stars[points[0]].position.distance_to(stars[points[1]].position)
	if distance > 1500:
		print("Galaxy is already connected.")
		return
	
	Global.print_console("Linking endpoints")
	
	var clusters = [
		find_neighbors(points[0]),
		find_neighbors(points[1])
	]
	
	link_clusters(clusters)
